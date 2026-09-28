import Foundation

/// Adds ConcordUI shared resources to the standard generated Android app module.
enum AndroidResourceProjectTemplate {
    static func appBuildGradle(
        packageName: String,
        version: String,
        build: Int
    ) -> String {
        AndroidProjectTemplate.appBuildGradle(
            packageName: packageName,
            version: version,
            build: build
        )
            .replacingOccurrences(
                of: "jniLibs.srcDir(\"build/generated/jniLibs\")",
                with: """
                jniLibs.srcDir("build/generated/jniLibs")
                assets.srcDir("../../Shared/Files")
                """
            )
    }
}
