import Foundation

/// Extends the standard generated Android platform support with native sharing.
enum AndroidFileSharingTemplate {
    static func resourceManager(packageName: String) -> String {
        var source = AndroidPlatformSupportTemplate.resourceManager(packageName: packageName)
        guard let closingBrace = source.lastIndex(of: "}") else { return source }

        let addition = """

    @JvmStatic
    fun canShare(): Boolean = ::applicationContext.isInitialized

    @JvmStatic
    fun share(name: String, type: String): Boolean = runCatching {
        val assetPath = findAsset(name, type) ?: return false
        val outputDirectory = File(applicationContext.cacheDir, "concord-resources")
        outputDirectory.mkdirs()
        val output = File(outputDirectory, assetPath.substringAfterLast('/'))
        applicationContext.assets.open(assetPath).use { input ->
            output.outputStream().use { input.copyTo(it) }
        }
        shareFile(output, MimeTypeMap.getSingleton()
            .getMimeTypeFromExtension(output.extension.lowercase())
            ?: "application/octet-stream")
    }.getOrDefault(false)

    @JvmStatic
    fun shareText(text: String): Boolean = runCatching {
        check(::applicationContext.isInitialized)
        val intent = Intent(Intent.ACTION_SEND).apply {
            type = "text/plain"
            putExtra(Intent.EXTRA_TEXT, text)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        applicationContext.startActivity(
            Intent.createChooser(intent, null).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        )
        true
    }.getOrDefault(false)

    @JvmStatic
    fun shareData(encoded: String, filename: String, mimeType: String): Boolean = runCatching {
        check(::applicationContext.isInitialized)
        if (filename.isBlank() || filename.contains('/') || filename.contains('\\\\')) return false
        val bytes = android.util.Base64.decode(encoded, android.util.Base64.NO_WRAP)
        val outputDirectory = File(applicationContext.cacheDir, "concord-resources")
        outputDirectory.mkdirs()
        val output = File(outputDirectory, filename)
        output.writeBytes(bytes)
        shareFile(output, mimeType.ifBlank { "application/octet-stream" })
    }.getOrDefault(false)

    private fun shareFile(file: File, mimeType: String): Boolean {
        val uri = FileProvider.getUriForFile(
            applicationContext,
            "${applicationContext.packageName}.concordui.resources",
            file
        )
        val intent = Intent(Intent.ACTION_SEND).apply {
            type = mimeType
            putExtra(Intent.EXTRA_STREAM, uri)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        applicationContext.startActivity(
            Intent.createChooser(intent, null).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        )
        return true
    }
"""

        source.insert(contentsOf: addition, at: closingBrace)
        return source
    }

    static func swiftPlatformSupport(packageName: String) -> String {
        let javaPackagePath = packageName.replacingOccurrences(of: ".", with: "/")
        return AndroidPlatformSupportTemplate.swiftPlatformSupport(packageName: packageName) + """


extension ConcordAndroidPlatform: ConcordPlatformFileSupport {
    var canRetrieveResources: Bool { true }
    var canOpenResources: Bool { true }
    var canShareResources: Bool {
        callPlatformBoolean(
            className: "\(javaPackagePath)/ConcordResourceManager",
            method: "canShare",
            strings: []
        )
    }

    @discardableResult
    func resourceShare(name: String, type: ConcordResourceType) -> Bool {
        callPlatformBoolean(
            className: "\(javaPackagePath)/ConcordResourceManager",
            method: "share",
            strings: [name, resourceTypeIdentifier(type)]
        )
    }

    @discardableResult
    func shareTextContent(_ text: String) -> Bool {
        callPlatformBoolean(
            className: "\(javaPackagePath)/ConcordResourceManager",
            method: "shareText",
            strings: [text]
        )
    }

    @discardableResult
    func shareDataContent(_ data: Data, filename: String, mimeType: String) -> Bool {
        callPlatformBoolean(
            className: "\(javaPackagePath)/ConcordResourceManager",
            method: "shareData",
            strings: [data.base64EncodedString(), filename, mimeType]
        )
    }
}
"""
    }
}
