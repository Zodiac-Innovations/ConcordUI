import Foundation

let concordProjectInfoFileName = "ConcordUI.info"

struct ValidationError: LocalizedError {
    let message: String
    init(_ message: String) { self.message = message }
    var errorDescription: String? { message }
}

func printSuccess(_ message: String) {
    print("\u{001B}[0;32m\(message)\u{001B}[0m")
}

struct ConcordProjectInfo {
    let formatVersion: String
    let name: String
    let displayName: String
    let key: String
    let version: String
    let build: Int
    let copyright: String
    let repo: String
    let branch: String

    var projectName: String { name }
}

func concordProjectInfo(at projectURL: URL) -> ConcordProjectInfo? {
    let infoURL = projectURL.appendingPathComponent(concordProjectInfoFileName)
    guard let contents = try? String(contentsOf: infoURL, encoding: .utf8) else { return nil }
    let values = concordProjectInfoValues(contents)
    let repo = values["repo"] ?? "https://github.com/Zodiac-Innovations/ConcordUI.git"
    let branch = values["branch"] ?? "main"

    guard
        let formatVersion = values["formatVersion"], !formatVersion.isEmpty,
        formatVersion == "1",
        let name = values["name"], !name.isEmpty,
        let displayName = values["displayName"], !displayName.isEmpty,
        let key = values["key"], !key.isEmpty,
        let version = values["version"], !version.isEmpty,
        let buildText = values["build"],
        let build = Int(buildText), build > 0,
        let copyright = values["copyright"], !copyright.isEmpty,
        isValidConcordRepository(repo), isValidConcordBranch(branch)
    else { return nil }

    return ConcordProjectInfo(
        formatVersion: formatVersion,
        name: name,
        displayName: displayName,
        key: key,
        version: version,
        build: build,
        copyright: copyright,
        repo: repo,
        branch: branch
    )
}

private func isValidConcordRepository(_ value: String) -> Bool {
    guard let url = URLComponents(string: value),
          let scheme = url.scheme, ["https", "ssh"].contains(scheme),
          url.host != nil,
          !value.contains("\""), !value.contains("\n") else { return false }
    return true
}

private func isValidConcordBranch(_ value: String) -> Bool {
    value.range(of: #"^[A-Za-z0-9][A-Za-z0-9._/-]*$"#, options: .regularExpression) != nil
        && !value.contains("..") && !value.hasSuffix("/")
}

func concordProjectInfoValues(_ contents: String) -> [String: String] {
    var values: [String: String] = [:]
    for rawLine in contents.split(separator: "\n") {
        let line = String(rawLine).trimmingCharacters(in: .whitespacesAndNewlines)
        let separator = line.firstIndex(of: "=")
        guard let separator else { continue }
        let name = String(line[..<separator]).trimmingCharacters(in: .whitespaces)
        let value = String(line[line.index(after: separator)...]).trimmingCharacters(in: .whitespaces)
        values[name] = value
    }
    return values
}

func isValidProjectKey(_ key: String) -> Bool {
    let components = key.split(separator: ".", omittingEmptySubsequences: false)
    guard components.count >= 2 else { return false }

    return components.allSatisfy { component in
        guard let first = component.first, first.isLetter, first.isLowercase else { return false }
        return component.allSatisfy { character in
            (character.isLetter && character.isLowercase) || character.isNumber || character == "_"
        }
    }
}

func meaningfulDirectoryContents(at url: URL) throws -> [String] {
    try FileManager.default.contentsOfDirectory(atPath: url.path).filter { $0 != ".DS_Store" }
}

func prepareGeneratedDirectory(_ url: URL, deletingExistingContents: Bool) throws {
    let fileManager = FileManager.default

    if directoryExists(url) {
        if deletingExistingContents {
            print("Deleting existing \(url.lastPathComponent) project, including hidden and generated files")
            try fileManager.removeItem(at: url)
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
            return
        }

        let contents = try meaningfulDirectoryContents(at: url)
        if !contents.isEmpty {
            throw ValidationError("\(url.lastPathComponent) folder is not empty. Refusing to overwrite an existing \(url.lastPathComponent) project. Use --delete to regenerate it.")
        }
        return
    }

    try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
}

func directoryExists(_ url: URL) -> Bool {
    var isDirectory: ObjCBool = false
    return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
}

func swiftTypeName(from projectName: String) -> String {
    let parts = projectName.split { character in
        !character.isLetter && !character.isNumber
    }

    var typeName = parts
        .map { part in
            guard let first = part.first else { return "" }
            return first.uppercased() + part.dropFirst()
        }
        .joined()

    if typeName.isEmpty {
        typeName = "ConcordUIProject"
    } else if typeName.first?.isNumber == true {
        typeName = "Project" + typeName
    }

    return typeName
}

func androidPackageComponent(from projectName: String) -> String {
    let lowered = projectName.lowercased().filter { $0.isLetter || $0.isNumber }
    if lowered.isEmpty { return "concorduiapp" }
    if lowered.first?.isNumber == true { return "app\(lowered)" }
    return lowered
}

