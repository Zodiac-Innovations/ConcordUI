//
//  ConcordPlatformAudioServices.swift
//  ConcordUI
//
//  Native sound playback and text-to-speech services.
//

import Foundation

public enum ConcordPlaybackResult: Sendable, Equatable {
    case finished
    case cancelled
    case failed
}

public typealias ConcordPlaybackCompletion = @Sendable (ConcordPlaybackResult) -> Void

/// Optional platform support for native sound playback and text-to-speech.
/// ConcordUI intentionally allows one active sound and one active speech operation at a time.
public protocol ConcordPlatformAudioSupport: AnyObject {
    var canPlaySoundContent: Bool { get }
    var canSpeakTextContent: Bool { get }

    @discardableResult
    func playSoundContent(
        _ data: Data,
        fileExtension: String,
        speed: ConcordFloat,
        completion: @escaping ConcordPlaybackCompletion
    ) -> Bool

    func cancelSoundContent()

    @discardableResult
    func speakTextContent(
        _ text: String,
        speed: ConcordFloat,
        completion: @escaping ConcordPlaybackCompletion
    ) -> Bool

    func cancelSpeechContent()
}

public extension ConcordPlatform {
    private var audioSupport: (any ConcordPlatformAudioSupport)? {
        self as? any ConcordPlatformAudioSupport
    }

    var canPlaySound: Bool { audioSupport?.canPlaySoundContent ?? false }
    var canSpeakText: Bool { audioSupport?.canSpeakTextContent ?? false }

    /// Plays encoded audio held in memory. ConcordUI's portable encoded sound formats are
    /// WAV, MP3, and M4A.
    @discardableResult
    func playSound(
        _ data: Data,
        fileExtension: String,
        speed: ConcordFloat = 1.0,
        completion: @escaping ConcordPlaybackCompletion = { _ in }
    ) -> Bool {
        guard let support = audioSupport,
              canPlaySound,
              !data.isEmpty,
              isPortablePlaybackSpeed(speed),
              let ext = normalizedAudioExtension(fileExtension) else { return false }
        return support.playSoundContent(data, fileExtension: ext, speed: speed, completion: completion)
    }

    /// Retrieves an application resource file and plays it using the native audio system.
    @discardableResult
    func playSoundFile(
        _ filename: String,
        speed: ConcordFloat = 1.0,
        completion: @escaping ConcordPlaybackCompletion = { _ in }
    ) -> Bool {
        let url = URL(fileURLWithPath: filename)
        let ext = url.pathExtension.lowercased()
        guard !ext.isEmpty,
              normalizedAudioExtension(ext) != nil,
              let data = retrieveDataFile(filename) else { return false }
        return playSound(data, fileExtension: ext, speed: speed, completion: completion)
    }

    /// Stops the currently playing sound. If playback was active, its completion receives `.cancelled`.
    func cancelSound() {
        audioSupport?.cancelSoundContent()
    }

    /// Speaks text using the platform's native text-to-speech service.
    @discardableResult
    func speakText(
        _ text: String,
        speed: ConcordFloat = 1.0,
        completion: @escaping ConcordPlaybackCompletion = { _ in }
    ) -> Bool {
        guard let support = audioSupport,
              canSpeakText,
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              isPortablePlaybackSpeed(speed) else { return false }
        return support.speakTextContent(text, speed: speed, completion: completion)
    }

    /// Stops the currently spoken text. If speech was active, its completion receives `.cancelled`.
    func cancelSpeech() {
        audioSupport?.cancelSpeechContent()
    }

    private func isPortablePlaybackSpeed(_ speed: ConcordFloat) -> Bool {
        speed >= 0.5 && speed <= 2.0
    }

    private func normalizedAudioExtension(_ value: String) -> String? {
        let ext = value
            .trimmingCharacters(in: CharacterSet(charactersIn: ".").union(.whitespacesAndNewlines))
            .lowercased()
        return ["wav", "mp3", "m4a"].contains(ext) ? ext : nil
    }
}
