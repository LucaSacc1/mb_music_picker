package com.mumble.mb_music_picker

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.database.Cursor
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.provider.MediaStore
import androidx.annotation.NonNull
import androidx.loader.content.CursorLoader
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.io.File

/** MbMusicPickerPlugin */
class MbMusicPickerPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {

    val PICK_MUSIC = 316

    var act: Activity? = null

    private lateinit var channel: MethodChannel
    lateinit var result: Result

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "mb_music_picker")
        channel.setMethodCallHandler(this)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.act = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(activityPluginBinding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
        act = null
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        this.result = result
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else {
            when (call.method) {
                "openMusicSelection" -> {
                    val intent = Intent(Intent.ACTION_PICK, MediaStore.Audio.Media.EXTERNAL_CONTENT_URI)
                    act?.startActivityForResult(intent, PICK_MUSIC)
                }
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == PICK_MUSIC) {
            if (resultCode == Activity.RESULT_OK) {
                if (data != null) {
                    val uri = data.data
                    if (uri != null) {
                        val mmr = MediaMetadataRetriever()
                        mmr.setDataSource(act, uri)
                        var title = mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE)
                        var artist = mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST)

                        val path = _getRealPathFromURI(act!!, uri)

                        if (path != null) {
                            if (title == null) {
                                title = getNameFromPath(path)
                                if (title == null) {
                                    title = "No Title"
                                }
                            }

                            if (artist == null) {
                                artist = "No Artist"
                            }

                            val map = mutableMapOf<String, String>()
                            map["identifier"] = path
                            map["title"] = title
                            map["artist"] = artist
                            map["asset_url"] = path
                            result.success(map)
                        } else {
                            return false
                        }
                    }
                    return true
                }
            }
        }
        return false
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    fun getNameFromPath(path: String): String? {
        var fileName: String = ""
        val file = File(path)
        if (file.exists()) {
            fileName = file.name
            val index_point = fileName.indexOf(".")
            fileName = fileName.substring(0, index_point)
        }

        return fileName
    }

    private fun _getRealPathFromURI(context: Context, contentUri: Uri): String? {
        val proj = arrayOf(MediaStore.Audio.Media.DATA)
        val loader = CursorLoader(context, contentUri, proj, null, null, null)
        val cursor: Cursor? = loader.loadInBackground()
        if (cursor != null) {
            val column_index: Int = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA)
            cursor.moveToFirst()
            return cursor.getString(column_index)
        }

        return null
    }
}
