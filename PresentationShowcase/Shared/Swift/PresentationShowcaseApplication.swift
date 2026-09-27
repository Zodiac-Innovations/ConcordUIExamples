//
//  PresentationShowcaseApplication.swift
//  ConcordUI Presentation Showcase
//
//  Created by Steve Sheets on 8/16/26.
//
//  Demonstrates Presentation behavior independently of Venue behavior.
//

import Foundation
import ConcordUI

/// Root ConcordUI application for the Presentation Showcase.
nonisolated public final class PresentationShowcaseApplication: ConcordApplication {

    let sharedPresentationData = ConcordStringData("Shared Presentation Data")
    let lifecycleState = PresentationShowcaseLifecycleState()

    public init(platform: any ConcordPlatform) {
        super.init(
            platform: platform,
            theme: ConcordTheme(frameColor: .secondary)
        )
    }

    public override func startApplication() {
        displayMainPresentation(homePresentation())
    }

    func showHome() {
        displayMainPresentation(homePresentation())
    }
}
