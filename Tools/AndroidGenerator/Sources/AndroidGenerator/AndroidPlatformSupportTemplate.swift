import Foundation

enum AndroidPlatformSupportTemplate {
    static func manifest(themeName: String) -> String {
        """
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <queries>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="http" />
        </intent>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="https" />
        </intent>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="mailto" />
        </intent>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="sms" />
        </intent>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="tel" />
        </intent>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="geo" />
        </intent>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="google.navigation" />
        </intent>
        <intent>
            <action android:name="android.settings.APPLICATION_DETAILS_SETTINGS" />
        </intent>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:mimeType="*/*" />
        </intent>
    </queries>

    <application
        android:name=".ConcordAndroidApplication"
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:roundIcon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:supportsRtl="true"
        android:theme="@style/\(themeName)">
        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.concordui.resources"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/concord_resource_paths" />
        </provider>
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:label="@string/app_name"
            android:theme="@style/\(themeName)"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
"""
    }

    static let resourcePaths = """
<?xml version="1.0" encoding="utf-8"?>
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <cache-path name="concord_resources" path="concord-resources/" />
</paths>
"""

    static func application(packageName: String) -> String {
        """
package \(packageName)

import android.app.Application

/** Initializes native Android services used by ConcordPlatform. */
class ConcordAndroidApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        ConcordPlatformInformation.initialize(this)
        ConcordSecureStorage.initialize(this)
        ConcordPlatformActions.initialize(this)
        ConcordResourceManager.initialize(this)
        ConcordNative.setPlatformEnvironment()
    }
}
"""
    }

    static func concordNative(packageName: String) -> String {
        """
package \(packageName)

object ConcordNative {
    init {
        System.loadLibrary("c++_shared")
        System.loadLibrary("ConcordUIAndroidApplication")
    }

    external fun setPlatformEnvironment()
    external fun start()
    external fun elementType(path: String): Int
    external fun elementText(path: String): String
    external fun childCount(path: String): Int
    external fun containerEdge(path: String): Double
    external fun justification(path: String): Int
    external fun isVisible(path: String): Boolean
}
"""
    }

    static func platformInformation(packageName: String) -> String {
        #"""
package __PACKAGE_TEMPLATE__

import android.content.Context
import android.content.res.Configuration
import android.os.Build
import java.util.Locale
import java.util.TimeZone

/** Native Android application, platform, device, and regional information. */
object ConcordPlatformInformation {
    private lateinit var applicationContext: Context

    @JvmStatic
    fun initialize(context: Context) {
        applicationContext = context.applicationContext
    }

    @JvmStatic
    fun appName(): String = runCatching {
        val info = applicationContext.applicationInfo
        applicationContext.packageManager.getApplicationLabel(info).toString()
    }.getOrDefault("Application")

    @JvmStatic
    fun appIdentifier(): String =
        if (::applicationContext.isInitialized) applicationContext.packageName else ""

    @Suppress("DEPRECATION")
    private fun packageInfo() =
        applicationContext.packageManager.getPackageInfo(applicationContext.packageName, 0)

    @JvmStatic
    fun appVersion(): String = runCatching {
        packageInfo().versionName ?: "0.0"
    }.getOrDefault("0.0")

    @JvmStatic
    fun appBuild(): String = runCatching {
        val info = packageInfo()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) info.longVersionCode.toString()
        else info.versionCode.toString()
    }.getOrDefault("0")

    @JvmStatic
    fun appCopyright(): String? = runCatching {
        applicationContext.getString(R.string.app_copyright).takeIf { it.isNotBlank() }
    }.getOrNull()

    @JvmStatic
    fun platformName(): String = "Android"

    @JvmStatic
    fun platformType(): String = "android"

    @JvmStatic
    fun platformVersion(): String = Build.VERSION.RELEASE.ifBlank { "Unknown" }

    @JvmStatic
    fun platformAPILevel(): String = Build.VERSION.SDK_INT.toString()

    @JvmStatic
    fun deviceModel(): String = Build.MODEL.ifBlank { "Unknown" }

    @JvmStatic
    fun deviceManufacturer(): String = Build.MANUFACTURER.ifBlank { "Unknown" }

    @JvmStatic
    fun localeIdentifier(): String {
        val locale = currentLocale()
        return locale.toLanguageTag().ifBlank { locale.toString() }.ifBlank { "Unknown" }
    }

    @JvmStatic
    fun languageCode(): String = currentLocale().language.ifBlank { "Unknown" }

    @JvmStatic
    fun timeZoneIdentifier(): String = TimeZone.getDefault().id.ifBlank { "Unknown" }

    @JvmStatic
    fun appearanceMode(): String {
        if (!::applicationContext.isInitialized) return "Unknown"
        return when (applicationContext.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK) {
            Configuration.UI_MODE_NIGHT_YES -> "Dark"
            Configuration.UI_MODE_NIGHT_NO -> "Light"
            else -> "Unspecified"
        }
    }

    @JvmStatic
    fun deviceClass(): String {
        if (!::applicationContext.isInitialized) return "Unknown"
        val configuration = applicationContext.resources.configuration
        if (configuration.smallestScreenWidthDp >= 600) return "Tablet"
        return when (configuration.screenLayout and Configuration.SCREENLAYOUT_SIZE_MASK) {
            Configuration.SCREENLAYOUT_SIZE_LARGE,
            Configuration.SCREENLAYOUT_SIZE_XLARGE -> "Tablet"
            else -> "Phone"
        }
    }

    @JvmStatic
    fun deviceType(): String {
        if (!::applicationContext.isInitialized) return "unknown"
        return if (applicationContext.resources.configuration.smallestScreenWidthDp >= 600) "pad" else "mobile"
    }

    @JvmStatic
    fun orientation(): String {
        if (!::applicationContext.isInitialized) return "none"
        return when (applicationContext.resources.configuration.orientation) {
            Configuration.ORIENTATION_LANDSCAPE -> "landscape"
            Configuration.ORIENTATION_PORTRAIT -> "portrait"
            else -> "none"
        }
    }

    private fun currentLocale(): Locale {
        if (!::applicationContext.isInitialized) return Locale.getDefault()
        val locales = applicationContext.resources.configuration.locales
        return if (!locales.isEmpty) locales[0] else Locale.getDefault()
    }
}
"""#
            .replacingOccurrences(of: "__PACKAGE_TEMPLATE__", with: packageName)
    }

    static func secureStorage(packageName: String) -> String {
        """
package \(packageName)

import android.content.Context
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

/** Native Android implementation backing ConcordUI secure storage. */
object ConcordSecureStorage {
    private const val KEY_ALIAS = "ConcordUI.SecureStorage.Key"
    private const val PREFERENCES = "ConcordUI.SecureStorage"
    private const val ANDROID_KEY_STORE = "AndroidKeyStore"
    private const val TRANSFORMATION = "AES/GCM/NoPadding"

    private lateinit var applicationContext: Context

    @JvmStatic
    fun initialize(context: Context) {
        applicationContext = context.applicationContext
    }

    @JvmStatic
    fun set(key: String, value: String): Boolean = runCatching {
        check(::applicationContext.isInitialized)
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.ENCRYPT_MODE, secretKey())
        val encrypted = cipher.doFinal(Base64.decode(value, Base64.NO_WRAP))
        val stored = Base64.encodeToString(cipher.iv + encrypted, Base64.NO_WRAP)
        applicationContext.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .edit()
            .putString(key, stored)
            .commit()
    }.getOrDefault(false)

    @JvmStatic
    fun get(key: String): String = runCatching {
        check(::applicationContext.isInitialized)
        val stored = applicationContext.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .getString(key, null) ?: return ""
        val combined = Base64.decode(stored, Base64.NO_WRAP)
        if (combined.size <= 12) return ""
        val iv = combined.copyOfRange(0, 12)
        val encrypted = combined.copyOfRange(12, combined.size)
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.DECRYPT_MODE, secretKey(), GCMParameterSpec(128, iv))
        Base64.encodeToString(cipher.doFinal(encrypted), Base64.NO_WRAP)
    }.getOrDefault("")

    @JvmStatic
    fun remove(key: String): Boolean = runCatching {
        check(::applicationContext.isInitialized)
        applicationContext.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .edit()
            .remove(key)
            .commit()
    }.getOrDefault(false)

    private fun secretKey(): SecretKey {
        val keyStore = KeyStore.getInstance(ANDROID_KEY_STORE).apply { load(null) }
        (keyStore.getKey(KEY_ALIAS, null) as? SecretKey)?.let { return it }

        val generator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, ANDROID_KEY_STORE)
        generator.init(
            KeyGenParameterSpec.Builder(
                KEY_ALIAS,
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
            )
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .setKeySize(256)
                .build()
        )
        return generator.generateKey()
    }
}
"""
    }

    static func platformActions(packageName: String) -> String {
        """
package \(packageName)

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Settings

/** Native Android implementation backing ConcordUI external platform actions. */
object ConcordPlatformActions {
    private lateinit var applicationContext: Context

    @JvmStatic
    fun initialize(context: Context) {
        applicationContext = context.applicationContext
    }

    @JvmStatic
    fun canLaunch(uri: String): Boolean = runCatching {
        check(::applicationContext.isInitialized)
        Intent(Intent.ACTION_VIEW, Uri.parse(uri))
            .resolveActivity(applicationContext.packageManager) != null
    }.getOrDefault(false)

    @JvmStatic
    fun launch(uri: String): Boolean = runCatching {
        check(::applicationContext.isInitialized)
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(uri)).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        if (intent.resolveActivity(applicationContext.packageManager) == null) return false
        applicationContext.startActivity(intent)
        true
    }.getOrDefault(false)

    @JvmStatic
    fun canOpenSettings(): Boolean = runCatching {
        check(::applicationContext.isInitialized)
        val intent = Intent(
            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
            Uri.parse("package:${applicationContext.packageName}")
        )
        intent.resolveActivity(applicationContext.packageManager) != null
    }.getOrDefault(false)

    @JvmStatic
    fun openSettings(): Boolean = runCatching {
        check(::applicationContext.isInitialized)
        val intent = Intent(
            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
            Uri.parse("package:${applicationContext.packageName}")
        ).apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) }
        if (intent.resolveActivity(applicationContext.packageManager) == null) return false
        applicationContext.startActivity(intent)
        true
    }.getOrDefault(false)
}
"""
    }

    static func resourceManager(packageName: String) -> String {
        """
package \(packageName)

import android.content.Context
import android.content.Intent
import android.webkit.MimeTypeMap
import androidx.core.content.FileProvider
import java.io.File

/** Locates packaged ConcordUI resources and opens copies through secure content URIs. */
object ConcordResourceManager {
    private lateinit var applicationContext: Context

    @JvmStatic
    fun initialize(context: Context) {
        applicationContext = context.applicationContext
    }

    @JvmStatic
    fun exists(name: String, type: String): Boolean =
        findAsset(name, type) != null

    @JvmStatic
    fun retrieve(name: String, type: String): String = runCatching {
        val path = findAsset(name, type) ?: return ""
        android.util.Base64.encodeToString(
            applicationContext.assets.open(path).use { it.readBytes() },
            android.util.Base64.NO_WRAP
        )
    }.getOrDefault("")

    @JvmStatic
    fun open(name: String, type: String): Boolean = runCatching {
        check(::applicationContext.isInitialized)
        val assetPath = findAsset(name, type) ?: return false
        val outputDirectory = File(applicationContext.cacheDir, "concord-resources")
        outputDirectory.mkdirs()
        val output = File(outputDirectory, assetPath.substringAfterLast('/'))
        applicationContext.assets.open(assetPath).use { input ->
            output.outputStream().use { input.copyTo(it) }
        }

        val uri = FileProvider.getUriForFile(
            applicationContext,
            "${applicationContext.packageName}.concordui.resources",
            output
        )
        val mimeType = MimeTypeMap.getSingleton()
            .getMimeTypeFromExtension(output.extension.lowercase())
            ?: "application/octet-stream"
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, mimeType)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        if (intent.resolveActivity(applicationContext.packageManager) == null) return false
        applicationContext.startActivity(intent)
        true
    }.getOrDefault(false)

    private fun findAsset(name: String, type: String): String? {
        if (!::applicationContext.isInitialized || !validName(name)) return null
        return candidates(name, type).firstOrNull { path ->
            runCatching {
                applicationContext.assets.open(path).use { }
                true
            }.getOrDefault(false)
        }
    }

    private fun candidates(name: String, type: String): List<String> = when {
        type == "text" -> listOf(
            "$name.txt",
            "Text/$name.txt",
            "Document/$name.txt",
            "Documents/$name.txt"
        )
        type == "pdf" -> listOf(
            "$name.pdf",
            "Document/$name.pdf",
            "Documents/$name.pdf"
        )
        type == "image" -> listOf(
            "$name.png",
            "$name.jpeg",
            "$name.jpg",
            "Image/$name.png",
            "Image/$name.jpeg",
            "Image/$name.jpg",
            "Images/$name.png",
            "Images/$name.jpeg",
            "Images/$name.jpg"
        )
        type.startsWith("custom:") -> {
            val extension = type.substringAfter("custom:").trim().trimStart('.').lowercase()
            if (extension.isEmpty()) emptyList() else listOf(
                "$name.$extension",
                "Document/$name.$extension",
                "Documents/$name.$extension",
                "Image/$name.$extension",
                "Images/$name.$extension",
                "Text/$name.$extension"
            )
        }
        else -> emptyList()
    }

    private fun validName(name: String): Boolean =
        name.isNotBlank() && !name.contains('/') && !name.contains('\\\\')
}
"""
    }

    static func swiftPlatformSupport(packageName: String) -> String {
        let jniPrefix = packageName.replacingOccurrences(of: ".", with: "_")
        let javaPackagePath = packageName.replacingOccurrences(of: ".", with: "/")
        return """
import Android
import ConcordUI
import Foundation

nonisolated(unsafe) private var concordAndroidPlatformJNIEnvironment: UnsafeMutablePointer<JNIEnv?>?

@_cdecl("Java_\(jniPrefix)_ConcordNative_setPlatformEnvironment")
public func concordAndroidSetPlatformEnvironment(
    environment: UnsafeMutablePointer<JNIEnv?>,
    receiver: jobject
) {
    concordAndroidPlatformJNIEnvironment = environment
}

extension ConcordAndroidPlatform {
    private func platformInformation(_ method: String) -> String? {
        callPlatformString(
            className: "\(javaPackagePath)/ConcordPlatformInformation",
            method: method,
            strings: []
        )
    }

    var appName: String { platformInformation("appName") ?? "Application" }
    var appIdentifier: String { platformInformation("appIdentifier") ?? "" }
    var appCopyright: String? { platformInformation("appCopyright") }
    var appVersion: String { platformInformation("appVersion") ?? "0.0" }
    var appBuild: String { platformInformation("appBuild") ?? "0" }
    var platformName: String { platformInformation("platformName") ?? "Android" }
    var platformVersion: String { platformInformation("platformVersion") ?? "Unknown" }
    var platformAPILevel: Int? { platformInformation("platformAPILevel").flatMap(Int.init) }
    var deviceModel: String { platformInformation("deviceModel") ?? "Unknown" }
    var deviceManufacturer: String { platformInformation("deviceManufacturer") ?? "Unknown" }
    var localeIdentifier: String { platformInformation("localeIdentifier") ?? "Unknown" }
    var languageCode: String { platformInformation("languageCode") ?? "Unknown" }
    var timeZoneIdentifier: String { platformInformation("timeZoneIdentifier") ?? "Unknown" }
    var appearanceMode: String { platformInformation("appearanceMode") ?? "Unknown" }
    var deviceClass: String { platformInformation("deviceClass") ?? "Unknown" }
    var platformType: ConcordPlatformType {
        ConcordPlatformType(rawValue: platformInformation("platformType") ?? "") ?? .unknown
    }
    var deviceType: ConcordDeviceType {
        ConcordDeviceType(rawValue: platformInformation("deviceType") ?? "") ?? .unknown
    }
    var orientation: ConcordOrientation {
        ConcordOrientation(rawValue: platformInformation("orientation") ?? "") ?? .none
    }

    @discardableResult
    func setSecureData(_ data: Data, forKey key: String) -> Bool {
        callPlatformBoolean(
            className: "\(javaPackagePath)/ConcordSecureStorage",
            method: "set",
            strings: [key, data.base64EncodedString()]
        )
    }

    func secureData(forKey key: String) -> Data? {
        guard let encoded = callPlatformString(
            className: "\(javaPackagePath)/ConcordSecureStorage",
            method: "get",
            strings: [key]
        ), !encoded.isEmpty else { return nil }
        return Data(base64Encoded: encoded)
    }

    @discardableResult
    func removeSecureValue(forKey key: String) -> Bool {
        callPlatformBoolean(
            className: "\(javaPackagePath)/ConcordSecureStorage",
            method: "remove",
            strings: [key]
        )
    }

    func resourceExists(name: String, type: ConcordResourceType) -> Bool {
        callPlatformBoolean(
            className: "\(javaPackagePath)/ConcordResourceManager",
            method: "exists",
            strings: [name, resourceTypeIdentifier(type)]
        )
    }

    func resourceRetrieve(name: String, type: ConcordResourceType) -> Data? {
        guard let encoded = callPlatformString(
            className: "\(javaPackagePath)/ConcordResourceManager",
            method: "retrieve",
            strings: [name, resourceTypeIdentifier(type)]
        ), !encoded.isEmpty else { return nil }
        return Data(base64Encoded: encoded)
    }

    @discardableResult
    func resourceOpen(name: String, type: ConcordResourceType) -> Bool {
        callPlatformBoolean(
            className: "\(javaPackagePath)/ConcordResourceManager",
            method: "open",
            strings: [name, resourceTypeIdentifier(type)]
        )
    }

    private func resourceTypeIdentifier(_ type: ConcordResourceType) -> String {
        switch type {
        case .text: return "text"
        case .pdf: return "pdf"
        case .image: return "image"
        case .custom(let value): return "custom:\\(value)"
        }
    }

    func canLaunchURL(_ url: URL) -> Bool {
        callActionBoolean(method: "canLaunch", strings: [url.absoluteString])
    }

    @discardableResult
    func launchURL(_ url: URL) -> Bool {
        callActionBoolean(method: "launch", strings: [url.absoluteString])
    }

    var canComposeEmail: Bool {
        callActionBoolean(method: "canLaunch", strings: ["mailto:concordui@example.com"])
    }

    @discardableResult
    func composeEmail(to: [String], subject: String?, body: String?) -> Bool {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = to.joined(separator: ",")
        var items: [URLQueryItem] = []
        if let subject, !subject.isEmpty { items.append(URLQueryItem(name: "subject", value: subject)) }
        if let body, !body.isEmpty { items.append(URLQueryItem(name: "body", value: body)) }
        components.queryItems = items.isEmpty ? nil : items
        guard let value = components.string else { return false }
        return callActionBoolean(method: "launch", strings: [value])
    }

    var canComposeMessage: Bool {
        callActionBoolean(method: "canLaunch", strings: ["sms:5555555555"])
    }

    @discardableResult
    func composeMessage(to: [String], body: String?) -> Bool {
        var components = URLComponents()
        components.scheme = "sms"
        components.path = to.joined(separator: ",")
        if let body, !body.isEmpty {
            components.queryItems = [URLQueryItem(name: "body", value: body)]
        }
        guard let value = components.string else { return false }
        return callActionBoolean(method: "launch", strings: [value])
    }

    var canDialPhone: Bool {
        callActionBoolean(method: "canLaunch", strings: ["tel:5555555555"])
    }

    @discardableResult
    func dialPhone(_ number: String) -> Bool {
        let normalized = number.filter { $0.isNumber || $0 == "+" || $0 == "*" || $0 == "#" }
        guard !normalized.isEmpty else { return false }
        return callActionBoolean(method: "launch", strings: ["tel:\\(normalized)"])
    }

    var canOpenMap: Bool {
        callActionBoolean(method: "canLaunch", strings: ["geo:0,0?q=ConcordUI"])
    }

    @discardableResult
    func openMap(latitude: Double, longitude: Double, label: String?) -> Bool {
        let coordinate = "\\(latitude),\\(longitude)"
        let query = label?.isEmpty == false ? "\\(coordinate)(\\(label!))" : coordinate
        return callActionBoolean(method: "launch", strings: ["geo:\\(coordinate)?q=\\(encoded(query))"])
    }

    @discardableResult
    func openMap(address: String) -> Bool {
        callActionBoolean(method: "launch", strings: ["geo:0,0?q=\\(encoded(address))"])
    }

    @discardableResult
    func searchMap(_ query: String) -> Bool {
        callActionBoolean(method: "launch", strings: ["geo:0,0?q=\\(encoded(query))"])
    }

    var canOpenDirections: Bool {
        callActionBoolean(method: "canLaunch", strings: ["google.navigation:q=0,0"])
    }

    @discardableResult
    func openDirections(toLatitude latitude: Double, longitude: Double, label: String?) -> Bool {
        callActionBoolean(method: "launch", strings: ["google.navigation:q=\\(latitude),\\(longitude)"])
    }

    @discardableResult
    func openDirections(toAddress address: String) -> Bool {
        callActionBoolean(method: "launch", strings: ["google.navigation:q=\\(encoded(address))"])
    }

    var canOpenApplicationSettings: Bool {
        callActionBoolean(method: "canOpenSettings", strings: [])
    }

    @discardableResult
    func openApplicationSettings() -> Bool {
        callActionBoolean(method: "openSettings", strings: [])
    }

    private func encoded(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
    }

    private func callActionBoolean(method: String, strings: [String]) -> Bool {
        callPlatformBoolean(
            className: "\(javaPackagePath)/ConcordPlatformActions",
            method: method,
            strings: strings
        )
    }

    private func callPlatformBoolean(className: String, method: String, strings: [String]) -> Bool {
        guard let environment = concordAndroidPlatformJNIEnvironment,
              let functions = environment.pointee?.pointee else { return false }
        let clazz = className.withCString { functions.FindClass(environment, $0) }
        guard let clazz else { return false }
        defer { functions.DeleteLocalRef(environment, clazz) }

        let signature = "(" + String(repeating: "Ljava/lang/String;", count: strings.count) + ")Z"
        let methodID = method.withCString { methodName in
            signature.withCString { methodSignature in
                functions.GetStaticMethodID(environment, clazz, methodName, methodSignature)
            }
        }
        guard let methodID else { return false }

        let localStrings: [jstring] = strings.map { value in
            value.withCString { functions.NewStringUTF(environment, $0)! }
        }
        defer { for value in localStrings { functions.DeleteLocalRef(environment, value) } }
        var arguments = localStrings.map { value -> jvalue in
            var argument = jvalue(); argument.l = value; return argument
        }
        let result: jboolean = arguments.withUnsafeMutableBufferPointer { buffer in
            functions.CallStaticBooleanMethodA(environment, clazz, methodID, buffer.baseAddress)
        }
        return result != 0
    }

    private func callPlatformString(className: String, method: String, strings: [String]) -> String? {
        guard let environment = concordAndroidPlatformJNIEnvironment,
              let functions = environment.pointee?.pointee else { return nil }
        let clazz = className.withCString { functions.FindClass(environment, $0) }
        guard let clazz else { return nil }
        defer { functions.DeleteLocalRef(environment, clazz) }

        let signature = "(" + String(repeating: "Ljava/lang/String;", count: strings.count) + ")Ljava/lang/String;"
        let methodID = method.withCString { methodName in
            signature.withCString { methodSignature in
                functions.GetStaticMethodID(environment, clazz, methodName, methodSignature)
            }
        }
        guard let methodID else { return nil }

        let localStrings: [jstring] = strings.map { value in
            value.withCString { functions.NewStringUTF(environment, $0)! }
        }
        defer { for value in localStrings { functions.DeleteLocalRef(environment, value) } }
        var arguments = localStrings.map { value -> jvalue in
            var argument = jvalue(); argument.l = value; return argument
        }
        guard let object = arguments.withUnsafeMutableBufferPointer({ buffer in
            functions.CallStaticObjectMethodA(environment, clazz, methodID, buffer.baseAddress)
        }) else { return nil }
        defer { functions.DeleteLocalRef(environment, object) }

        let value = unsafeBitCast(object, to: jstring.self)
        guard let chars = functions.GetStringUTFChars(environment, value, nil) else { return nil }
        defer { functions.ReleaseStringUTFChars(environment, value, chars) }
        return String(cString: chars)
    }
}
"""
    }
}
