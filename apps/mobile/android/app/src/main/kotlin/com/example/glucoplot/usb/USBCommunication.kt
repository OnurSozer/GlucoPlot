package com.example.glucoplot.usb

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.UsbConstants
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbDeviceConnection
import android.hardware.usb.UsbEndpoint
import android.hardware.usb.UsbInterface
import android.hardware.usb.UsbManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.locks.ReentrantLock

class USBCommunication(private val context: Context) {
    private val TAG = "USBCommunication"
    private val ACTION_USB_PERMISSION = "com.example.glucoplot.USB_PERMISSION"

    // STM32 device identifiers
    private val STM32_VENDOR_ID = 0x0483  // STMicroelectronics
    private val STM32_PRODUCT_ID = 0x5740 // Virtual COM Port

    // Utility function to convert signed bytes to unsigned string representation
    private fun ByteArray.toUnsignedString(): String {
        return this.joinToString(", ") { (it.toInt() and 0xFF).toString() }
    }

    private var methodChannel: MethodChannel? = null
    private var usbManager: UsbManager? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private var isConnected = false
    private var pendingPermissionDevice: UsbDevice? = null
    private var permissionCheckRunnable: Runnable? = null

    // USB Serial Communication
    private var usbConnection: UsbDeviceConnection? = null
    private var usbInterface: UsbInterface? = null
    private var inEndpoint: UsbEndpoint? = null
    private var outEndpoint: UsbEndpoint? = null
    private var readingExecutor: ExecutorService? = null
    private val isReading = AtomicBoolean(false)

    // Synchronization for USB communication
    private val usbLock = ReentrantLock()
    private var sendExecutor: ExecutorService? = null

    // USB permission receiver
    private val usbReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            Log.d(TAG, "=== USB RECEIVER CALLED ===")
            Log.d(TAG, "USB receiver got intent: ${intent.action}")

            when (intent.action) {
                ACTION_USB_PERMISSION -> {
                    Log.d(TAG, "Processing USB permission intent")
                    synchronized(this) {
                        val device: UsbDevice? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            intent.getParcelableExtra(UsbManager.EXTRA_DEVICE, UsbDevice::class.java)
                        } else {
                            @Suppress("DEPRECATION")
                            intent.getParcelableExtra(UsbManager.EXTRA_DEVICE)
                        }

                        val permissionGranted = intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)

                        Log.d(TAG, "Permission granted: $permissionGranted, device: ${device?.deviceName}")

                        if (permissionGranted) {
                            device?.let {
                                Log.d(TAG, "USB permission granted for device: ${it.deviceName}")
                                connectToDevice(it)
                            }
                        } else {
                            Log.d(TAG, "USB permission denied")
                            notifyConnectionStatusChanged("Disconnected")
                        }
                    }
                }
                UsbManager.ACTION_USB_DEVICE_ATTACHED -> {
                    Log.d(TAG, "USB device attached")
                    notifyConnectionStatusChanged("Connecting")
                    checkAndConnectToDevice()
                }
                UsbManager.ACTION_USB_DEVICE_DETACHED -> {
                    Log.d(TAG, "USB device detached")
                    stopPermissionChecking()
                    disconnectDevice()
                }
            }
        }
    }

    fun initialize(methodChannel: MethodChannel) {
        this.methodChannel = methodChannel
        usbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager
        registerUsbReceivers()

        // Check for already connected devices after a short delay
        mainHandler.postDelayed({
            checkAndConnectToDevice()
        }, 1000)
    }

    fun cleanup() {
        stopPermissionChecking()
        disconnectDevice()
        unregisterUsbReceivers()

        sendExecutor?.shutdown()
        sendExecutor = null
    }

    fun requestPermission() {
        Log.d(TAG, "Request permission called")
        checkAndConnectToDevice()
    }

    fun sendData(data: ByteArray) {
        if (!isConnected || usbConnection == null) {
            Log.e(TAG, "Cannot send data - device not connected")
            notifyDataSent(false, "Device not connected")
            return
        }

        if (outEndpoint == null || inEndpoint == null) {
            Log.e(TAG, "Cannot send data - missing endpoints")
            notifyDataSent(false, "Missing endpoints")
            return
        }

        if (sendExecutor == null) {
            sendExecutor = Executors.newSingleThreadExecutor()
        }

        sendExecutor?.execute {
            usbLock.lock()
            try {
                Log.d(TAG, "Sending data: ${data.toUnsignedString()}")

                val maxRetries = 3
                var retryCount = 0
                var success = false

                while (retryCount < maxRetries && !success) {
                    val sentBytes = usbConnection?.bulkTransfer(outEndpoint, data, data.size, 1000)

                    if (sentBytes == null || sentBytes < 0) {
                        Log.e(TAG, "Failed to send data, attempt ${retryCount + 1}")
                        retryCount++
                        continue
                    }

                    Log.d(TAG, "Data sent successfully: $sentBytes bytes")

                    mainHandler.post {
                        notifyDataSent(true, "Sent ${data.size} bytes")
                    }
                    success = true
                }

                if (!success) {
                    Log.e(TAG, "Failed to send data after $maxRetries attempts")
                    mainHandler.post {
                        notifyDataSent(false, "Failed to send data after $maxRetries attempts")
                    }
                }

            } catch (e: Exception) {
                Log.e(TAG, "Error in sendData: ${e.message}")
                mainHandler.post {
                    notifyDataSent(false, "Error: ${e.message}")
                }
            } finally {
                usbLock.unlock()
            }
        }
    }

    fun startReading() {
        if (isReading.get()) {
            Log.d(TAG, "Already reading, skipping start")
            return
        }

        if (usbConnection == null || inEndpoint == null) {
            Log.e(TAG, "Cannot start reading - connection or IN endpoint is null")
            return
        }

        Log.d(TAG, "=== Starting continuous reading ===")

        isReading.set(true)

        readingExecutor = Executors.newSingleThreadExecutor()
        readingExecutor?.execute {
            val buffer = ByteArray(4096)
            val timeout = 500

            while (isReading.get() && usbConnection != null && inEndpoint != null) {
                try {
                    val bytesRead = usbConnection?.bulkTransfer(inEndpoint, buffer, buffer.size, timeout)

                    if (bytesRead != null && bytesRead > 0) {
                        val receivedData = buffer.copyOf(bytesRead)
                        Log.d(TAG, "Data received: ${bytesRead} bytes: ${receivedData.toUnsignedString()}")

                        val dataString = receivedData.toUnsignedString()
                        mainHandler.post {
                            notifyDataReceived(dataString)
                        }

                    } else if (bytesRead == null || bytesRead < 0) {
                        // Timeout is normal, just continue polling
                        Thread.sleep(5)
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error reading data: ${e.message}")
                    Thread.sleep(20)
                }
            }

            Log.d(TAG, "Continuous reading stopped")

            if (isConnected) {
                Log.w(TAG, "Read loop exited while connected - notifying Flutter")
                mainHandler.post {
                    notifyConnectionStatusChanged("Disconnected")
                }
                isConnected = false
            }
        }
    }

    fun stopReading() {
        Log.d(TAG, "Stopping continuous reading")
        isReading.set(false)

        readingExecutor?.shutdown()
        readingExecutor = null
    }

    private fun configureSerialDevice() {
        if (usbConnection == null) return

        Thread {
            try {
                Log.d(TAG, "Configuring device for serial communication")

                val buffer = ByteArray(0)

                // Set DTR + RTS
                usbConnection?.controlTransfer(0x21, 0x22, 0x03, 0, buffer, 0, 1000)

                Log.d(TAG, "Device configuration completed")
            } catch (e: Exception) {
                Log.e(TAG, "Error configuring device: ${e.message}")
            }
        }.start()
    }

    private fun registerUsbReceivers() {
        Log.d(TAG, "Registering USB receivers")

        val filter = IntentFilter().apply {
            addAction(ACTION_USB_PERMISSION)
            addAction(UsbManager.ACTION_USB_DEVICE_ATTACHED)
            addAction(UsbManager.ACTION_USB_DEVICE_DETACHED)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(usbReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            context.registerReceiver(usbReceiver, filter)
        }

        Log.d(TAG, "USB receivers registered")
    }

    private fun unregisterUsbReceivers() {
        try {
            context.unregisterReceiver(usbReceiver)
        } catch (e: Exception) {
            Log.e(TAG, "Error unregistering USB receiver: ${e.message}")
        }
    }

    private fun checkAndConnectToDevice() {
        Log.d(TAG, "Checking for USB devices...")

        usbManager?.let { manager ->
            val deviceList = manager.deviceList

            if (deviceList.isEmpty()) {
                Log.d(TAG, "No USB devices found")
                return
            }

            // Look for STM32 device
            for ((_, device) in deviceList) {
                Log.d(TAG, "Found device: ${device.deviceName}, VendorId: ${device.vendorId}, ProductId: ${device.productId}")

                // Check if it's our STM32 device
                if (device.vendorId == STM32_VENDOR_ID && device.productId == STM32_PRODUCT_ID) {
                    if (manager.hasPermission(device)) {
                        Log.d(TAG, "Permission already granted, connecting...")
                        connectToDevice(device)
                    } else {
                        Log.d(TAG, "Requesting permission for device...")
                        requestPermissionForDevice(device)
                    }
                    return
                }
            }

            Log.d(TAG, "STM32 device not found")
        }
    }

    private fun requestPermissionForDevice(device: UsbDevice) {
        Log.d(TAG, "Creating permission request for ${device.deviceName}")

        pendingPermissionDevice = device
        notifyConnectionStatusChanged("Connecting")

        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val intent = Intent(ACTION_USB_PERMISSION)

        val permissionIntent = PendingIntent.getBroadcast(
            context,
            0,
            intent,
            flags
        )

        usbManager?.requestPermission(device, permissionIntent)
        Log.d(TAG, "Permission request sent")

        // Start polling for permission status
        startPermissionChecking()
    }

    private fun startPermissionChecking() {
        permissionCheckRunnable?.let { mainHandler.removeCallbacks(it) }

        var pollCount = 0
        val maxPollCount = 30  // 30 seconds timeout

        permissionCheckRunnable = object : Runnable {
            override fun run() {
                pendingPermissionDevice?.let { device ->
                    usbManager?.let { manager ->
                        pollCount++

                        when {
                            manager.hasPermission(device) -> {
                                Log.d(TAG, "Permission granted (detected via polling)")
                                stopPermissionChecking()
                                connectToDevice(device)
                                pendingPermissionDevice = null
                            }
                            !manager.deviceList.containsValue(device) -> {
                                Log.d(TAG, "Device disconnected while waiting for permission")
                                stopPermissionChecking()
                                pendingPermissionDevice = null
                                notifyConnectionStatusChanged("Disconnected")
                            }
                            pollCount > maxPollCount -> {
                                Log.d(TAG, "Permission timeout after ${pollCount} polls")
                                stopPermissionChecking()
                                pendingPermissionDevice = null
                                notifyConnectionStatusChanged("Disconnected")
                            }
                            else -> {
                                Log.d(TAG, "Waiting for permission... (poll #${pollCount})")
                                mainHandler.postDelayed(this, 1000)
                            }
                        }
                    }
                }
            }
        }

        mainHandler.postDelayed(permissionCheckRunnable!!, 2000)
    }

    private fun stopPermissionChecking() {
        permissionCheckRunnable?.let {
            mainHandler.removeCallbacks(it)
            permissionCheckRunnable = null
        }
    }

    private fun connectToDevice(device: UsbDevice) {
        Log.d(TAG, "Connecting to device: ${device.deviceName}")

        try {
            usbConnection = usbManager?.openDevice(device)

            if (usbConnection == null) {
                Log.e(TAG, "Failed to open device connection")
                notifyConnectionStatusChanged("Disconnected")
                return
            }

            // Find CDC_DATA interface with BULK endpoints
            var selectedInterface: UsbInterface? = null
            var selectedInEndpoint: UsbEndpoint? = null
            var selectedOutEndpoint: UsbEndpoint? = null

            for (interfaceIndex in 0 until device.interfaceCount) {
                val iface = device.getInterface(interfaceIndex)

                if (iface.interfaceClass == UsbConstants.USB_CLASS_CDC_DATA) {
                    var tempInEndpoint: UsbEndpoint? = null
                    var tempOutEndpoint: UsbEndpoint? = null

                    for (endpointIndex in 0 until iface.endpointCount) {
                        val endpoint = iface.getEndpoint(endpointIndex)

                        if (endpoint.type == UsbConstants.USB_ENDPOINT_XFER_BULK) {
                            if (endpoint.direction == UsbConstants.USB_DIR_IN) {
                                tempInEndpoint = endpoint
                            } else if (endpoint.direction == UsbConstants.USB_DIR_OUT) {
                                tempOutEndpoint = endpoint
                            }
                        }
                    }

                    if (tempInEndpoint != null && tempOutEndpoint != null) {
                        selectedInterface = iface
                        selectedInEndpoint = tempInEndpoint
                        selectedOutEndpoint = tempOutEndpoint
                        Log.d(TAG, "Found CDC_DATA interface with BULK endpoints")
                        break
                    }
                }
            }

            // Fallback: try any interface with BULK endpoints
            if (selectedInterface == null) {
                for (interfaceIndex in 0 until device.interfaceCount) {
                    val iface = device.getInterface(interfaceIndex)
                    var tempInEndpoint: UsbEndpoint? = null
                    var tempOutEndpoint: UsbEndpoint? = null

                    for (endpointIndex in 0 until iface.endpointCount) {
                        val endpoint = iface.getEndpoint(endpointIndex)

                        if (endpoint.type == UsbConstants.USB_ENDPOINT_XFER_BULK) {
                            if (endpoint.direction == UsbConstants.USB_DIR_IN) {
                                tempInEndpoint = endpoint
                            } else if (endpoint.direction == UsbConstants.USB_DIR_OUT) {
                                tempOutEndpoint = endpoint
                            }
                        }
                    }

                    if (tempInEndpoint != null && tempOutEndpoint != null) {
                        selectedInterface = iface
                        selectedInEndpoint = tempInEndpoint
                        selectedOutEndpoint = tempOutEndpoint
                        break
                    }
                }
            }

            if (selectedInterface == null) {
                Log.e(TAG, "No interface with BULK endpoints found")
                notifyConnectionStatusChanged("Disconnected")
                return
            }

            if (usbConnection?.claimInterface(selectedInterface, true) == true) {
                usbInterface = selectedInterface
                inEndpoint = selectedInEndpoint
                outEndpoint = selectedOutEndpoint

                if (inEndpoint != null && outEndpoint != null) {
                    isConnected = true
                    Log.d(TAG, "Device connected successfully")

                    configureSerialDevice()
                    startReading()

                    notifyConnectionStatusChanged("Connected")
                } else {
                    Log.e(TAG, "Missing required endpoints")
                    disconnectDevice()
                }
            } else {
                Log.e(TAG, "Failed to claim interface")
                disconnectDevice()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error connecting to device: ${e.message}")
            disconnectDevice()
        }
    }

    private fun disconnectDevice() {
        Log.d(TAG, "Disconnecting device")

        stopReading()

        try {
            usbInterface?.let { usbConnection?.releaseInterface(it) }
            usbConnection?.close()
        } catch (e: Exception) {
            Log.e(TAG, "Error during disconnect: ${e.message}")
        }

        usbConnection = null
        usbInterface = null
        inEndpoint = null
        outEndpoint = null
        isConnected = false
        pendingPermissionDevice = null

        notifyConnectionStatusChanged("Disconnected")
    }

    private fun notifyConnectionStatusChanged(status: String) {
        Log.d(TAG, "Notifying Flutter: connection status = $status")

        mainHandler.post {
            methodChannel?.invokeMethod("onConnectionStatusChanged", status)
        }
    }

    private fun notifyDataReceived(data: String) {
        mainHandler.post {
            methodChannel?.invokeMethod("onDataReceived", data)
        }
    }

    private fun notifyDataSent(success: Boolean, message: String) {
        mainHandler.post {
            val result = mapOf(
                "success" to success,
                "message" to message
            )
            methodChannel?.invokeMethod("onDataSent", result)
        }
    }
}
