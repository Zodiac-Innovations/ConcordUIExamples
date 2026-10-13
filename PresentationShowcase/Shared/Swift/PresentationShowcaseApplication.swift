//
//  PresentationShowcaseApplication.swift
//  ConcordUI Presentation Showcase
//
//  Created by Steve Sheets on 8/16/26.
//
//  Demonstrates Presentation behavior independently of Venue behavior.
//

//  Purpose: Demonstrate the functional UI and data owned by a ConcordPresentation.
//  Screens: Home opens Basic Presentation, Presentation Data, Display Options,
//  Lifecycle, and Secondary Venue Presentation. These cover metadata and element
//  trees, an editable shared string, presentation font defaults with element
//  overrides, lifecycle counters, and a presentation in a separate venue.
//  Controls: Home returns from each main-venue example. Edit the string and revisit
//  Presentation Data to see the reused data object. Leave and reopen Lifecycle to
//  see start and finish counts. Secondary Venue Presentation opens its registered
//  Home; Close Venue closes it and restores the previous mobile screen.

import Foundation
import ConcordUI

/// Root ConcordUI application for the Presentation Showcase.
nonisolated public final class PresentationShowcaseApplication: ConcordApplication {

    let sharedPresentationData = ConcordStringData("Shared Presentation Data")
    let lifecycleState = PresentationShowcaseLifecycleState()

    /// Initializes the application with the native platform and showcase theme.
    public init(platform: any ConcordPlatform) {
        super.init(
            platform: platform,
            theme: ConcordTheme(frameColor: .secondary)
        )
    }

    /// Displays the Home menu for the presentation examples.
    public override func startApplication() {
        displayMainPresentation(homePresentation())
    }

    /// Builds and displays the main menu presentation.
    func showHome() {
        displayMainPresentation(homePresentation())
    }
}
