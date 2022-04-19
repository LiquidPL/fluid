package pw.liquid.fluid

import android.content.ContentResolver
import android.content.Context
import android.content.ContentUris
import android.os.BatteryManager
import android.os.Build
import android.provider.MediaStore
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

class MainMethodCallHandler(private var context: Context) : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "getAudioFiles") {
            val audioFiles = getAudioFiles();

            result.success(audioFiles);
        } else {
            result.notImplemented();
        }
    }

    private fun getAudioFiles(): List<Map<String, Any>> {
        val collection =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                MediaStore.Audio.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
            } else {
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
            }

        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
        )

        var selection = "${MediaStore.Audio.Media.IS_RINGTONE}=0 " +
            "AND ${MediaStore.Audio.Media.IS_NOTIFICATION}=0 " +
            "AND ${MediaStore.Audio.Media.IS_MUSIC}=1"

        val sortOrder = "${MediaStore.Audio.Media.DISPLAY_NAME} ASC"

        val query = context.contentResolver.query(
            collection,
            projection,
            selection,
            null,
            sortOrder,
        )

        val audioList = mutableListOf<Map<String, Any>>()

        query?.use { cursor ->
            var idColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
            var titleColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)
            var artistColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)
            var durationColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)


            while (cursor.moveToNext()) {
                audioList += hashMapOf(
                    "title" to cursor.getString(titleColumn),
                    "uri" to ContentUris.withAppendedId(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, cursor.getInt(idColumn).toLong()).toString(),
                    "artist" to cursor.getString(artistColumn),
                    "duration" to cursor.getInt(durationColumn),
               )
            }
        }

        return audioList
    }
}
