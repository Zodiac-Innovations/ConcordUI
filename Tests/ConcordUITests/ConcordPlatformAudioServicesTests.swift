import XCTest
@testable import ConcordUI

final class ConcordPlatformAudioServicesTests: XCTestCase {
    private final class ResultBox: @unchecked Sendable {
        var value: ConcordPlaybackResult?
    }

    private final class TestPlatform: ConcordPlatform, ConcordPlatformFileSupport, ConcordPlatformAudioSupport {
        var soundData: Data?
        var soundExtension: String?
        var soundSpeed: ConcordFloat?
        var soundCompletion: ConcordPlaybackCompletion?
        var spokenText: String?
        var speechSpeed: ConcordFloat?
        var speechCompletion: ConcordPlaybackCompletion?
        var soundCancelled = false
        var speechCancelled = false
        var resourceData: Data?

        func displayPresentation(_ presentation: ConcordPresentation) {}
        func refreshPresentation(_ presentation: ConcordPresentation) {}

        var canRetrieveResources: Bool { true }
        var canOpenResources: Bool { false }
        var canShareResources: Bool { false }
        func resourceShare(name: String, type: ConcordResourceType) -> Bool { false }
        func shareTextContent(_ text: String) -> Bool { false }
        func shareDataContent(_ data: Data, filename: String, mimeType: String) -> Bool { false }

        func resourceRetrieve(name: String, type: ConcordResourceType) -> Data? {
            resourceData
        }

        var canPlaySoundContent: Bool { true }
        var canSpeakTextContent: Bool { true }

        func playSoundContent(
            _ data: Data,
            fileExtension: String,
            speed: ConcordFloat,
            completion: @escaping ConcordPlaybackCompletion
        ) -> Bool {
            soundData = data
            soundExtension = fileExtension
            soundSpeed = speed
            soundCompletion = completion
            return true
        }

        func cancelSoundContent() {
            soundCancelled = true
        }

        func speakTextContent(
            _ text: String,
            speed: ConcordFloat,
            completion: @escaping ConcordPlaybackCompletion
        ) -> Bool {
            spokenText = text
            speechSpeed = speed
            speechCompletion = completion
            return true
        }

        func cancelSpeechContent() {
            speechCancelled = true
        }
    }

    func testSoundDefaultsToNormalSpeed() {
        let platform = TestPlatform()
        let data = Data([1, 2, 3])

        XCTAssertTrue(platform.playSound(data, fileExtension: ".WAV"))
        XCTAssertEqual(platform.soundData, data)
        XCTAssertEqual(platform.soundExtension, "wav")
        XCTAssertEqual(platform.soundSpeed, 1.0)
    }

    func testPortableSoundFormats() {
        let platform = TestPlatform()
        let data = Data([1, 2, 3])

        XCTAssertTrue(platform.playSound(data, fileExtension: "wav"))
        XCTAssertTrue(platform.playSound(data, fileExtension: "mp3"))
        XCTAssertTrue(platform.playSound(data, fileExtension: "m4a"))
        XCTAssertFalse(platform.playSound(data, fileExtension: "aac"))
        XCTAssertFalse(platform.playSound(data, fileExtension: "ogg"))
        XCTAssertFalse(platform.playSound(data, fileExtension: "flac"))
    }

    func testSoundFileRetrievesThenPlays() {
        let platform = TestPlatform()
        platform.resourceData = Data([4, 5, 6])

        XCTAssertTrue(platform.playSoundFile("Tone.wav", speed: 1.5))
        XCTAssertEqual(platform.soundData, Data([4, 5, 6]))
        XCTAssertEqual(platform.soundExtension, "wav")
        XCTAssertEqual(platform.soundSpeed, 1.5)

        XCTAssertTrue(platform.playSoundFile("scream.mp3"))
        XCTAssertEqual(platform.soundExtension, "mp3")
    }

    func testPortableSpeedRangeIsValidated() {
        let platform = TestPlatform()
        let data = Data([1])

        XCTAssertFalse(platform.playSound(data, fileExtension: "wav", speed: 0.49))
        XCTAssertFalse(platform.playSound(data, fileExtension: "wav", speed: 2.01))
        XCTAssertFalse(platform.speakText("Hello", speed: 0.49))
        XCTAssertFalse(platform.speakText("Hello", speed: 2.01))
    }

    func testSpeechDefaultsToNormalSpeed() {
        let platform = TestPlatform()

        XCTAssertTrue(platform.speakText("Hello ConcordUI"))
        XCTAssertEqual(platform.spokenText, "Hello ConcordUI")
        XCTAssertEqual(platform.speechSpeed, 1.0)
    }

    func testCancelCallsAreForwarded() {
        let platform = TestPlatform()

        platform.cancelSound()
        platform.cancelSpeech()

        XCTAssertTrue(platform.soundCancelled)
        XCTAssertTrue(platform.speechCancelled)
    }

    func testCompletionResultIsForwarded() {
        let platform = TestPlatform()
        let result = ResultBox()

        XCTAssertTrue(platform.speakText("Hello") { value in result.value = value })
        platform.speechCompletion?(.finished)

        XCTAssertEqual(result.value, .finished)
    }
}
