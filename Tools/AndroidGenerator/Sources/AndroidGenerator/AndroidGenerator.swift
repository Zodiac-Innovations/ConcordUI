import Foundation
import Darwin

@main
struct AndroidGeneratorMain {
    static func main() {
        let args = Array(CommandLine.arguments.dropFirst())
        guard let projectIndex = args.firstIndex(of: "--project"),
              projectIndex + 1 < args.count else {
            fputs("Usage: concordui-android-generate --project PATH [--delete]\n", stderr)
            exit(2)
        }
        let project = URL(fileURLWithPath: args[projectIndex + 1]).standardizedFileURL
        do {
            var generator = AndroidGenerator(root: project, delete: args.contains("--delete"))
            try generator.run()
        } catch {
            fputs("Android project generation failed: \(error.localizedDescription)\n", stderr)
            exit(1)
        }
    }
}

struct AndroidGenerator {
    let root: URL
    var delete: Bool

    mutating func run() throws {
        print("Command Start")
        print("[10%] Validating ConcordUI project")

        let fileManager = FileManager.default
        let projectURL = root
        guard fileManager.fileExists(atPath: projectURL.appendingPathComponent("ConcordUI.info").path) else {
            throw ValidationError("ConcordUI.info was not found in \(projectURL.path).")
        }

        guard let projectInfo = concordProjectInfo(at: projectURL) else {
            throw ValidationError("\(concordProjectInfoFileName) must contain formatVersion, name, displayName, key, version, build, and copyright values.")
        }
        guard isValidProjectKey(projectInfo.key) else {
            throw ValidationError("The project key in \(concordProjectInfoFileName) is invalid.")
        }

        let sharedURL = projectURL.appendingPathComponent("Shared", isDirectory: true)
        let sharedSwiftURL = sharedURL.appendingPathComponent("Swift", isDirectory: true)
        let androidURL = projectURL.appendingPathComponent("Android", isDirectory: true)
        let packageURL = projectURL.appendingPathComponent("Package.swift")
        let packageResolvedURL = projectURL.appendingPathComponent("Package.resolved")
        let swiftBuildURL = projectURL.appendingPathComponent(".build", isDirectory: true)

        guard directoryExists(sharedURL) else {
            throw ValidationError("This ConcordUI project is missing its required Shared folder.")
        }

        let projectName = projectInfo.projectName
        let applicationType = swiftTypeName(from: projectName) + "Application"
        let applicationFile = sharedSwiftURL.appendingPathComponent("\(applicationType).swift")
        guard fileManager.fileExists(atPath: applicationFile.path) else {
            throw ValidationError("Shared application file was not found at \(applicationFile.path).")
        }

        if delete {
            if fileManager.fileExists(atPath: packageURL.path) {
                try fileManager.removeItem(at: packageURL)
            }
            if fileManager.fileExists(atPath: packageResolvedURL.path) {
                try fileManager.removeItem(at: packageResolvedURL)
            }
            if fileManager.fileExists(atPath: swiftBuildURL.path) {
                try fileManager.removeItem(at: swiftBuildURL)
            }
        }
        guard !fileManager.fileExists(atPath: packageURL.path) else {
            throw ValidationError("Package.swift already exists at the ConcordUI project root. Refusing to overwrite it.")
        }

        try prepareGeneratedDirectory(androidURL, deletingExistingContents: delete)

        print("[25%] Preparing Android Studio project")

        let packageComponent = androidPackageComponent(from: projectName)
        let packageName = "\(projectInfo.key).\(packageComponent)"
        let packagePath = packageName.replacingOccurrences(of: ".", with: "/")
        let themeName = "Theme.\(swiftTypeName(from: projectName))"
        let gradleJavaHome = try androidStudioGradleJavaHome(fileManager: fileManager)

        // A globally scrollable host gives its child an unbounded vertical constraint.
        // That prevents Compose weight-based ConcordSpacer values from consuming the
        // remaining height of a fill-size root VStack. Keep fill-size roots in the
        // finite viewport; retain scrolling for content-sized root presentations.
        let oldHost = [
            "                    val hostModifier = Modifier",
            "                        .fillMaxSize()",
            "                        .safeDrawingPadding()",
            "                        .imePadding()",
            "                        .padding(horizontal = 10.dp)",
            "                        .verticalScroll(rememberScrollState())",
            "                    Box(modifier = hostModifier, contentAlignment = Alignment.TopStart) {",
            "                        key(revision) {",
            "                            ConcordElement(\"\", false, revision, { revision += 1 })",
            "                        }",
            "                    }"
        ].joined(separator: "\n")
        let newHost = [
            "                    val hostModifier = Modifier",
            "                        .fillMaxSize()",
            "                        .safeDrawingPadding()",
            "                        .imePadding()",
            "                        .padding(horizontal = 10.dp)",
            "                    val scrollState = rememberScrollState()",
            "                    Box(modifier = hostModifier, contentAlignment = Alignment.TopStart) {",
            "                        key(revision) {",
            "                            if (ConcordNative.heightRule(\"\") == 3) {",
            "                                ConcordElement(\"\", false, revision, { revision += 1 })",
            "                            } else {",
            "                                Box(",
            "                                    modifier = Modifier.fillMaxSize().verticalScroll(scrollState),",
            "                                    contentAlignment = Alignment.TopStart",
            "                                ) {",
            "                                    ConcordElement(\"\", false, revision, { revision += 1 })",
            "                                }",
            "                            }",
            "                        }",
            "                    }"
        ].joined(separator: "\n")
        let generatedMainActivity = AndroidRendererTemplate.mainActivity(packageName: packageName)
            .replacingOccurrences(of: oldHost, with: newHost)

        let files: [(String, String)] = [
            ("settings.gradle.kts", AndroidProjectTemplate.settingsGradle(projectName: projectName)),
            ("build.gradle.kts", AndroidProjectTemplate.topLevelBuildGradle),
            ("gradle.properties", AndroidProjectTemplate.gradleProperties),
            ("gradle/libs.versions.toml", AndroidProjectTemplate.gradleVersionCatalog),
            (".idea/gradle.xml", AndroidStudioTemplate.gradleSettings),
            (".idea/runConfigurations/app.xml", AndroidStudioTemplate.appRunConfiguration),
            (".gradle/config.properties", AndroidStudioTemplate.gradleLocalJavaHome(gradleJavaHome)),
            ("build-swift.sh", AndroidProjectTemplate.buildSwift()),
            ("app/build.gradle.kts", AndroidResourceProjectTemplate.appBuildGradle(
                    packageName: packageName,
                    version: projectInfo.version,
                    build: projectInfo.build
                )),
            ("app/src/main/AndroidManifest.xml", AndroidPlatformSupportTemplate.manifest(themeName: themeName)),
            (
                "app/src/main/res/values/strings.xml",
                AndroidProjectTemplate.strings(
                    displayName: projectInfo.displayName,
                    copyright: projectInfo.copyright
                )
            ),
            ("app/src/main/res/values/themes.xml", AndroidProjectTemplate.themes(themeName: themeName)),
            ("app/src/main/res/xml/concord_resource_paths.xml", AndroidPlatformSupportTemplate.resourcePaths),
            ("app/src/main/java/\(packagePath)/ConcordNative.kt", AndroidBannerTemplate.concordNative(packageName: packageName)),
            ("app/src/main/java/\(packagePath)/ConcordAndroidApplication.kt", AndroidBannerTemplate.application(packageName: packageName)),
            ("app/src/main/java/\(packagePath)/ConcordPlatformInformation.kt", AndroidPlatformSupportTemplate.platformInformation(packageName: packageName)),
            ("app/src/main/java/\(packagePath)/ConcordSecureStorage.kt", AndroidPlatformSupportTemplate.secureStorage(packageName: packageName)),
            ("app/src/main/java/\(packagePath)/ConcordPlatformActions.kt", AndroidPlatformSupportTemplate.platformActions(packageName: packageName)),
            ("app/src/main/java/\(packagePath)/ConcordResourceManager.kt", AndroidFileSharingTemplate.resourceManager(packageName: packageName)),
            ("app/src/main/java/\(packagePath)/ConcordPrintManager.kt", AndroidPrintingTemplate.printManager(packageName: packageName)),
            ("app/src/main/java/\(packagePath)/ConcordAudioManager.kt", AndroidAudioTemplate.audioManager(packageName: packageName)),
            ("app/src/main/java/\(packagePath)/ConcordBannerManager.kt", AndroidBannerTemplate.bannerManager(packageName: packageName)),
            ("app/src/main/java/\(packagePath)/MainActivity.kt", generatedMainActivity),
            ("SwiftBridge/ConcordAndroidBridge.swift", AndroidVenueTemplate.swiftBridge(applicationType: applicationType, packageName: packageName)),
            ("SwiftBridge/ConcordAndroidPlatformSupport.swift", AndroidBannerTemplate.swiftPlatformSupport(packageName: packageName))
        ]

        do {
            print("[40%] Writing Android project files")

            try AndroidProjectTemplate.packageSwift(applicationType: applicationType, repository: projectInfo.repo, branch: projectInfo.branch).write(
                to: packageURL,
                atomically: true,
                encoding: .utf8
            )

            for (relativePath, contents) in files {
                let fileURL = androidURL.appendingPathComponent(relativePath)
                try fileManager.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
                try contents.write(to: fileURL, atomically: true, encoding: .utf8)
            }

            let sourceAppIconURL = projectURL.appendingPathComponent(
                "Shared/Icons/appicon-1024.png"
            )
            let generatedAppIconURL = androidURL.appendingPathComponent(
                "app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"
            )
            guard fileManager.fileExists(atPath: sourceAppIconURL.path) else {
                throw ValidationError(
                    "Shared/Icons/appicon-1024.png was not found. " +
                    "Recreate the ConcordUI project or restore its app icon."
                )
            }
            try fileManager.createDirectory(
                at: generatedAppIconURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try fileManager.copyItem(
                at: sourceAppIconURL,
                to: generatedAppIconURL
            )

            print("[60%] Generating Gradle wrapper")
            print("       Gradle output follows while this step is running.")
            try installGradleWrapper(into: androidURL)
            print("[80%] Gradle wrapper generated")

            print("[90%] Finalizing executable permissions")
            try makeExecutable(androidURL.appendingPathComponent("build-swift.sh"))
            try makeExecutable(androidURL.appendingPathComponent("gradlew"))
        } catch let error as ValidationError {
            try? fileManager.removeItem(at: packageURL)
            try? fileManager.removeItem(at: androidURL)
            try? fileManager.createDirectory(at: androidURL, withIntermediateDirectories: true)
            throw error
        } catch {
            try? fileManager.removeItem(at: packageURL)
            try? fileManager.removeItem(at: androidURL)
            try? fileManager.createDirectory(at: androidURL, withIntermediateDirectories: true)
            throw ValidationError("Could not create Android project: \(error.localizedDescription)")
        }

        printSuccess("[100%] Command completed")
        printSuccess("Created Android Studio project at \(androidURL.path)")
        printSuccess("Created Swift package manifest at \(packageURL.path)")
        print("Open the Android folder in Android Studio and run the app target.")
        print("Android application identifier: \(packageName)")
    }

    private func androidStudioGradleJavaHome(fileManager: FileManager) throws -> String {
        let embeddedJDK = "/Applications/Android Studio.app/Contents/jbr/Contents/Home"
        if fileManager.fileExists(atPath: embeddedJDK) {
            return embeddedJDK
        }

        if let javaHome = ProcessInfo.processInfo.environment["JAVA_HOME"],
           !javaHome.isEmpty,
           fileManager.fileExists(atPath: javaHome) {
            return javaHome
        }

        throw ValidationError("A Gradle JDK could not be found. Install Android Studio with its embedded JDK or set JAVA_HOME before running `concordui android create`.")
    }

    private func installGradleWrapper(into androidURL: URL) throws {
        let process = Process()
        process.currentDirectoryURL = androidURL
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [
            "gradle", "wrapper",
            "--gradle-version", "9.5.0",
            "--console=plain",
            "--no-daemon",
            "--no-configuration-cache"
        ]

        process.standardInput = FileHandle.nullDevice
        process.standardOutput = FileHandle.standardOutput
        process.standardError = FileHandle.standardError

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            throw ValidationError("Gradle is required once to generate the wrapper. Install Gradle with Homebrew, then rerun `concordui android create`.")
        }

        print("       Gradle process exited with status \(process.terminationStatus).")

        guard process.terminationStatus == 0 else {
            throw ValidationError("Gradle wrapper generation failed. Review the Gradle output above, correct the reported issue, and rerun `concordui android create`.")
        }

        for relativePath in [
            "gradlew",
            "gradlew.bat",
            "gradle/wrapper/gradle-wrapper.jar",
            "gradle/wrapper/gradle-wrapper.properties"
        ] {
            guard FileManager.default.fileExists(atPath: androidURL.appendingPathComponent(relativePath).path) else {
                throw ValidationError("Gradle reported success but did not create \(relativePath).")
            }
        }
    }

    private func makeExecutable(_ url: URL) throws {
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: url.path)
    }
}
