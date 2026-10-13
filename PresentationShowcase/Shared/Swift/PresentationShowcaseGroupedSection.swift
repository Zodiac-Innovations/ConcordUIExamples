//
//  PresentationShowcaseGroupedSection.swift
//  ConcordUI Presentation Showcase
//
//  Shared navigation helpers used by the Presentation-focused examples.
//

//  Purpose: Share navigation between the Presentation Showcase example screens.
//  Control: The Home button calls the application to rebuild and display the main
//  menu, keeping the example presentations consistent.

import ConcordUI

/// Provides shared navigation for the presentation examples.
nonisolated extension PresentationShowcaseApplication {
    /// Creates the common Home button for the presentation examples.
    func presentationHomeButton() -> ConcordButton {
        ConcordButton("Home") {
            self.showHome()
        }
        .centerJustified()
    }
}
