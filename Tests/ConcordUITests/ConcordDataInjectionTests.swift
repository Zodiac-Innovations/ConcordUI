import Testing
@testable import ConcordUI

private final class DataInjectionTestPlatform: ConcordPlatform {
    var displayedPresentation: ConcordPresentation?

    func displayPresentation(_ presentation: ConcordPresentation) {
        displayedPresentation = presentation
    }

    func refreshPresentation(_ presentation: ConcordPresentation) {}
}

@Test("Venue registered display inherits persistent currentData")
func venueRegisteredDisplayInheritsCurrentData() {
    let platform = DataInjectionTestPlatform()
    let persistent = ConcordStringData("persistent")
    let application = ConcordApplication(platform: platform)
    let venue = application.createAuxiliaryVenue(currentData: persistent)

    var builderData: (any ConcordDataProtocol)?
    venue.registerPresentation(tag: 1) { data in
        builderData = data
        return ConcordPresentation(data: ConcordStringData("builder default"))
    }

    let presentation = venue.displayPresentation(tag: 1)

    #expect(builderData === persistent)
    #expect(presentation?.data === persistent)
    #expect(venue.currentData === persistent)
    #expect(platform.displayedPresentation === presentation)
}

@Test("Venue explicit injected data does not replace currentData")
func venueInjectedDataDoesNotReplaceCurrentData() {
    let platform = DataInjectionTestPlatform()
    let persistent = ConcordStringData("persistent")
    let injected = ConcordStringData("injected")
    let application = ConcordApplication(platform: platform)
    let venue = application.createAuxiliaryVenue(currentData: persistent)

    var builderData: (any ConcordDataProtocol)?
    venue.registerPresentation(tag: 1) { data in
        builderData = data
        return ConcordPresentation()
    }

    let presentation = venue.displayPresentation(tag: 1, data: injected)

    #expect(builderData === injected)
    #expect(presentation?.data === injected)
    #expect(venue.currentData === persistent)

    (presentation?.data as? ConcordStringData)?.value = "changed in presentation"
    #expect(injected.value == "changed in presentation")
    #expect(persistent.value == "persistent")
}

@Test("Main Venue inherits Application currentData")
func mainVenueInheritsApplicationCurrentData() {
    let platform = DataInjectionTestPlatform()
    let persistent = ConcordStringData("application persistent")
    let application = ConcordApplication(platform: platform, currentData: persistent)

    var builderData: (any ConcordDataProtocol)?
    application.mainVenue.registerPresentation(tag: 10) { data in
        builderData = data
        return ConcordPresentation(data: ConcordStringData("builder default"))
    }

    let presentation = application.mainVenue.displayPresentation(tag: 10)

    #expect(builderData === persistent)
    #expect(presentation?.data === persistent)
    #expect(application.currentData === persistent)
    #expect(application.mainVenue.currentData === persistent)
}

@Test("Main Venue explicit data does not replace Application currentData")
func mainVenueInjectedDataDoesNotReplaceApplicationCurrentData() {
    let platform = DataInjectionTestPlatform()
    let persistent = ConcordStringData("application persistent")
    let injected = ConcordStringData("application injected")
    let application = ConcordApplication(platform: platform, currentData: persistent)

    var builderData: (any ConcordDataProtocol)?
    application.mainVenue.registerPresentation(tag: 10) { data in
        builderData = data
        return ConcordPresentation()
    }

    let presentation = application.mainVenue.displayPresentation(tag: 10, data: injected)

    #expect(builderData === injected)
    #expect(presentation?.data === injected)
    #expect(application.currentData === persistent)
    #expect(application.mainVenue.currentData === persistent)
}
