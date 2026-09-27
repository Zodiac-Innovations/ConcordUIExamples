//
//  HelloConcordUIApplication.swift
//  HelloConcordUI
//

import ConcordUI

nonisolated public final class HelloConcordUIApplication: ConcordApplication {

    public override func startApplication() {
        mainVenue.size(640, 240)
        elementFontSize = 34

        let firstPresentation = ConcordPresentation {
            ConcordVStack([
                ConcordSpacer(),
                ConcordText("HelloConcordUI")
                    .centerJustified()
                    .fillWidth(),
                ConcordSpacer(),
            ])
            .fillSize()
        }

        displayMainPresentation(firstPresentation)
    }
}