import Foundation

/// The canonical renderer already implements venue lifecycle behavior.
/// Keep this entry point for callers that generate the Android Swift bridge.
enum AndroidVenueTemplate {
    static func swiftBridge(applicationType: String, packageName: String) -> String {
        AndroidRendererTemplate.swiftBridge(
            applicationType: applicationType,
            packageName: packageName
        )
    }
}
