//
//  PresentationShowcaseGroupedSection.swift
//  ConcordUI Presentation Showcase
//
//  Shared navigation helpers used by the Presentation-focused examples.
//

import ConcordUI

nonisolated extension PresentationShowcaseApplication {
    func presentationHomeButton() -> ConcordButton {
        ConcordButton("Home") {
            self.showHome()
        }
        .centerJustified()
    }
}
