//
//  ConcordString.swift
//  ConcordUI
//
//  Created by Steve Sheets on 8/18/26.
//
//  Defines common string constants used throughout ConcordUI.
//

/// Namespace for common user-visible strings supplied by ConcordUI.
///
/// ConcordUI-owned UI text should be defined here rather than hard-coded in
/// elements, presentations, validation, or platform implementations so these
/// values can be localized centrally in the future.
public enum ConcordString {

    public static let ok = "OK"
    public static let cancel = "Cancel"
    public static let yes = "Yes"
    public static let no = "No"
    public static let done = "Done"
    public static let next = "Next"
    public static let previous = "Previous"
    public static let back = "Back"

    public static let trueText = "True"
    public static let falseText = "False"

    public static let help = "Help"
    public static let special = "Special"
    public static let links = "Links"
    public static let settings = "Settings"
    public static let tba = "TBA"
    public static let about = "About"
    public static let acknowledgements = "Acknowledgements"
    public static let licenseAgreement = "License Agreement"
    public static let welcome = "Welcome"
    public static let getStarted = "Get Started"
    public static let whatsNew = "What's New"
    public static let faq = "FAQ"
    public static let questionPrefix = "Q:"
    public static let answerPrefix = "A:"
    public static let continueText = "Continue"
    public static let pageSetup = "Page Setup…"
    public static let print = "Print…"

    public static let on = "On"
    public static let off = "Off"
    public static let undecided = "Undecided"

    public static let application = "Application"
    public static let unknown = "Unknown"
    public static let nilValue = "nil"
    public static let unavailableValue = "—"

    public static func helpTitle(_ appName: String) -> String {
        "\(appName) \(help)"
    }

    public static func welcomeTitle(_ appName: String) -> String {
        "\(welcome) to \(appName)"
    }

    public static func aboutTitle(_ appName: String) -> String {
        "\(about) \(appName)"
    }

    public static func faqTitle(_ appName: String) -> String {
        "\(faq) for \(appName)"
    }

    public static func whatsNewTitle(_ appName: String) -> String {
        "\(whatsNew) in \(appName)"
    }

    public static func versionBuild(version: String, build: String) -> String {
        "Version \(version) (\(build))"
    }

    public static let error = "Error"
    public static let warning = "Warning"
    public static let success = "Success"
    public static let invalidText = "Invalid Text"
    public static let required = "Required"
}
