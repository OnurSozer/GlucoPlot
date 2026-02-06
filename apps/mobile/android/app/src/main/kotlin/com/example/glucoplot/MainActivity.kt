package com.example.glucoplot

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.glucoplot.usb.USBCommunication

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.glucoplot.app/usb"
    private lateinit var usbCommunication: USBCommunication

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize USB communication
        usbCommunication = USBCommunication(this)

        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "checkForDevice" -> {
                    usbCommunication.requestPermission()
                    result.success(null)
                }
                "send" -> {
                    val data = call.argument<List<Int>>("data")
                    if (data != null) {
                        val byteArray = data.map { it.toByte() }.toByteArray()
                        usbCommunication.sendData(byteArray)
                        result.success(byteArray.size)
                    } else {
                        result.error("INVALID_ARGUMENT", "Data is required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // Initialize USB communication with method channel
        usbCommunication.initialize(methodChannel)
    }

    override fun onDestroy() {
        super.onDestroy()
        usbCommunication.cleanup()
    }
}
