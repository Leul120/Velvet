package com.velvet.velvet_mobile

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.OpenableColumns
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val channelName = "velvet/secure_picker"
    private var pendingResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Block screenshots and screen recording of exclusive chat / profile content.
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pickFile" -> {
                        if (pendingResult != null) {
                            result.error("BUSY", "Picker already open", null)
                            return@setMethodCallHandler
                        }
                        pendingResult = result
                        val mime = call.argument<String>("mime") ?: "*/*"
                        val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
                            type = mime
                            addCategory(Intent.CATEGORY_OPENABLE)
                            putExtra(Intent.EXTRA_MIME_TYPES, call.argument<List<String>>("mimes")?.toTypedArray())
                        }
                        startActivityForResult(Intent.createChooser(intent, "Select file"), REQ_PICK)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != REQ_PICK) return
        val result = pendingResult
        pendingResult = null
        if (result == null) return
        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            result.success(null)
            return
        }
        try {
            val uri = data.data!!
            val name = queryName(uri) ?: "upload.bin"
            val out = File(cacheDir, "pick_${System.currentTimeMillis()}_$name")
            contentResolver.openInputStream(uri).use { input ->
                FileOutputStream(out).use { output -> input!!.copyTo(output) }
            }
            result.success(mapOf("path" to out.absolutePath, "name" to name))
        } catch (e: Exception) {
            result.error("PICK_FAILED", e.message, null)
        }
    }

    private fun queryName(uri: Uri): String? {
        contentResolver.query(uri, null, null, null, null)?.use { cursor ->
            val idx = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            if (idx >= 0 && cursor.moveToFirst()) return cursor.getString(idx)
        }
        return uri.lastPathSegment
    }

    companion object {
        private const val REQ_PICK = 9911
    }
}
