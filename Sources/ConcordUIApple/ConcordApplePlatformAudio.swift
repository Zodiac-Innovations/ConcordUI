//
//  ConcordApplePlatformAudio.swift
//  ConcordUIApple
//

import AVFoundation
import ConcordUI
import Foundation

private let concordAppleAudioController = ConcordAppleAudioController()

private final class ConcordAppleAudioController: NSObject, AVAudioPlayerDelegate, AVSpeechSynthesizerDelegate, @unchecked Sendable {
    private var audioPlayer: AVAudioPlayer?
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var soundCompletion: ConcordPlaybackCompletion?
    private var speechCompletion: ConcordPlaybackCompletion?

    override init() {
        super.init()
        speechSynthesizer.delegate = self
    }

    var canPlaySound: Bool { true }
    var canSpeakText: Bool { true }

    @discardableResult
    func playSound(
        _ data: Data,
        fileExtension: String,
        speed: ConcordFloat,
        completion: @escaping ConcordPlaybackCompletion
    ) -> Bool {
        cancelSound()

        #if os(iOS) || os(tvOS) || os(visionOS)
        // Configure application audio for audible playback, but do not make a
        // session-configuration problem masquerade as an audio decode failure.
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("ConcordUI audio session warning: \(error)")
        }
        #endif

        do {
            let player = try AVAudioPlayer(
                data: data,
                fileTypeHint: appleAudioFileTypeHint(for: fileExtension)
            )
            player.delegate = self
            player.enableRate = true
            player.rate = Float(speed)
            soundCompletion = completion
            audioPlayer = player

            guard player.prepareToPlay(), player.play() else {
                audioPlayer = nil
                soundCompletion = nil
                completion(.failed)
                return false
            }
            return true
        } catch {
            print("ConcordUI audio player error (\(fileExtension)): \(error)")
            audioPlayer = nil
            soundCompletion = nil
            completion(.failed)
            return false
        }
    }

    private func appleAudioFileTypeHint(for fileExtension: String) -> String? {
        switch fileExtension.lowercased() {
        case "mp3":
            return AVFileType.mp3.rawValue
        case "wav":
            return AVFileType.wav.rawValue
        case "m4a":
            return AVFileType.m4a.rawValue
        default:
            return nil
        }
    }

    func cancelSound() {
        guard let player = audioPlayer else { return }
        player.stop()
        audioPlayer = nil
        let completion = soundCompletion
        soundCompletion = nil
        completion?(.cancelled)
    }

    @discardableResult
    func speakText(_ text: String, speed: ConcordFloat, completion: @escaping ConcordPlaybackCompletion) -> Bool {
        cancelSpeech()
        let utterance = AVSpeechUtterance(string: text)
        let requestedRate = AVSpeechUtteranceDefaultSpeechRate * Float(speed)
        utterance.rate = min(max(requestedRate, AVSpeechUtteranceMinimumSpeechRate), AVSpeechUtteranceMaximumSpeechRate)
        speechCompletion = completion
        speechSynthesizer.speak(utterance)
        return true
    }

    func cancelSpeech() {
        guard speechSynthesizer.isSpeaking || speechCompletion != nil else { return }
        let completion = speechCompletion
        speechCompletion = nil
        _ = speechSynthesizer.stopSpeaking(at: .immediate)
        completion?(.cancelled)
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard player === audioPlayer else { return }
        audioPlayer = nil
        let completion = soundCompletion
        soundCompletion = nil
        completion?(flag ? .finished : .failed)
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        guard player === audioPlayer else { return }
        if let error {
            print("ConcordUI audio decode error: \(error)")
        }
        audioPlayer = nil
        let completion = soundCompletion
        soundCompletion = nil
        completion?(.failed)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let completion = speechCompletion
        speechCompletion = nil
        completion?(.finished)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        let completion = speechCompletion
        speechCompletion = nil
        completion?(.cancelled)
    }
}

extension ConcordApplePlatform: ConcordPlatformAudioSupport {
    public var canPlaySoundContent: Bool { concordAppleAudioController.canPlaySound }
    public var canSpeakTextContent: Bool { concordAppleAudioController.canSpeakText }

    @discardableResult
    public func playSoundContent(_ data: Data, fileExtension: String, speed: ConcordFloat, completion: @escaping ConcordPlaybackCompletion) -> Bool {
        concordAppleAudioController.playSound(
            data,
            fileExtension: fileExtension,
            speed: speed,
            completion: completion
        )
    }

    public func cancelSoundContent() { concordAppleAudioController.cancelSound() }

    @discardableResult
    public func speakTextContent(_ text: String, speed: ConcordFloat, completion: @escaping ConcordPlaybackCompletion) -> Bool {
        concordAppleAudioController.speakText(text, speed: speed, completion: completion)
    }

    public func cancelSpeechContent() { concordAppleAudioController.cancelSpeech() }
}
