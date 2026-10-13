//
//  HelloConcordUIApplication.swift
//  HelloConcordUI
//

//  Purpose: Show the smallest shared ConcordUI application on Apple and Android.
//  Screen: A single main presentation centers the HelloConcordUI greeting between
//  spacers, using a larger application font and a requested desktop venue size.
//  Controls: There are no buttons or editable controls; this is the starting point
//  for understanding application startup, a presentation, and its element tree.

import ConcordUI

/// Hosts the minimal greeting presentation in the main venue.
nonisolated public final class HelloConcordUIApplication: ConcordApplication {

    /// Sets the venue size and font, then displays the centered greeting.
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