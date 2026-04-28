package com.lavego.carwash

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterFragmentActivity() {
    private val logTag = "CarWashPermissions"
    private val permissionChannelName = "com.example.car_wash/permissions"
    private val mapsConfigChannelName = "com.example.car_wash/maps_config"
    private val requestLocationPermissionCode = 1000
    private val requestGalleryPermissionCode = 1001
    private val requestCameraPermissionCode = 1002

    private var pendingResult: MethodChannel.Result? = null
    private var pendingPermissions: Array<String>? = null
    private var acceptAnyGrant = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            permissionChannelName,
        ).setMethodCallHandler { call, result ->
            Log.d(logTag, "Received method call: ${call.method}")
            when (call.method) {
                "requestLocationPermission" -> requestPermissions(
                    permissions = locationPermissions(),
                    requestCode = requestLocationPermissionCode,
                    acceptAnyGrant = true,
                    result = result,
                )

                "requestGalleryPermission" -> requestPermissions(
                    permissions = galleryPermissions(),
                    requestCode = requestGalleryPermissionCode,
                    acceptAnyGrant = Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE,
                    result = result,
                )

                "requestCameraPermission" -> requestPermissions(
                    permissions = arrayOf(Manifest.permission.CAMERA),
                    requestCode = requestCameraPermissionCode,
                    acceptAnyGrant = false,
                    result = result,
                )

                "openAppSettings" -> {
                    openAppSettings()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            mapsConfigChannelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasUsableGoogleMapsApiKey" -> result.success(hasUsableGoogleMapsApiKey())
                else -> result.notImplemented()
            }
        }
    }

    private fun hasUsableGoogleMapsApiKey(): Boolean {
        val apiKey = googleMapsApiKey()
        return !apiKey.isNullOrBlank() && apiKey != "YOUR_GOOGLE_MAPS_API_KEY"
    }

    private fun googleMapsApiKey(): String? {
        val applicationInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.getApplicationInfo(
                packageName,
                PackageManager.ApplicationInfoFlags.of(PackageManager.GET_META_DATA.toLong()),
            )
        } else {
            @Suppress("DEPRECATION")
            packageManager.getApplicationInfo(packageName, PackageManager.GET_META_DATA)
        }

        return applicationInfo.metaData?.getString("com.google.android.geo.API_KEY")
    }

    private fun requestPermissions(
        permissions: Array<String>,
        requestCode: Int,
        acceptAnyGrant: Boolean,
        result: MethodChannel.Result,
    ) {
        if (pendingResult != null) {
            result.error(
                "permission_in_progress",
                "Another permission request is already in progress.",
                null,
            )
            return
        }

        val isAlreadyGranted = if (acceptAnyGrant) {
            permissions.any(::isPermissionGranted)
        } else {
            permissions.all(::isPermissionGranted)
        }

        Log.d(
            logTag,
            "Requesting permissions=${permissions.joinToString()} requestCode=$requestCode alreadyGranted=$isAlreadyGranted",
        )

        if (isAlreadyGranted) {
            Log.d(logTag, "Permissions already granted for requestCode=$requestCode")
            result.success("granted")
            return
        }

        pendingResult = result
        pendingPermissions = permissions
        this.acceptAnyGrant = acceptAnyGrant

        ActivityCompat.requestPermissions(this, permissions, requestCode)
    }

    private fun locationPermissions(): Array<String> {
        return arrayOf(
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION,
        )
    }

    private fun galleryPermissions(): Array<String> {
        // Android 14 can grant access to selected photos only, which is enough
        // for the profile photo picker flow.
        return when {
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE -> arrayOf(
                Manifest.permission.READ_MEDIA_IMAGES,
                Manifest.permission.READ_MEDIA_VISUAL_USER_SELECTED,
            )

            Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU -> arrayOf(
                Manifest.permission.READ_MEDIA_IMAGES,
            )

            else -> arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE)
        }
    }

    private fun isPermissionGranted(permission: String): Boolean {
        return ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        if (
            requestCode != requestLocationPermissionCode &&
            requestCode != requestGalleryPermissionCode &&
            requestCode != requestCameraPermissionCode
        ) {
            super.onRequestPermissionsResult(requestCode, permissions, grantResults)
            return
        }

        val result = pendingResult
        val requestedPermissions = pendingPermissions
        val shouldAcceptAnyGrant = acceptAnyGrant

        pendingResult = null
        pendingPermissions = null
        acceptAnyGrant = false

        if (result == null || requestedPermissions == null) {
            super.onRequestPermissionsResult(requestCode, permissions, grantResults)
            return
        }

        if (grantResults.isEmpty()) {
            result.success("denied")
            return
        }

        val isGranted = if (shouldAcceptAnyGrant) {
            requestedPermissions.any(::isPermissionGranted)
        } else {
            requestedPermissions.all(::isPermissionGranted)
        }

        if (isGranted) {
            Log.d(logTag, "Permissions granted for requestCode=$requestCode")
            result.success("granted")
            return
        }

        val permanentlyDenied = requestedPermissions.any {
            !ActivityCompat.shouldShowRequestPermissionRationale(this, it)
        }

        Log.d(
            logTag,
            "Permissions denied for requestCode=$requestCode permanentlyDenied=$permanentlyDenied grantResults=${grantResults.joinToString()}",
        )

        result.success(if (permanentlyDenied) "permanentlyDenied" else "denied")
    }

    private fun openAppSettings() {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            data = Uri.fromParts("package", packageName, null)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(intent)
    }
}
