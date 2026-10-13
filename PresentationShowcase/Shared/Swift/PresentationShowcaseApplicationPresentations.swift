//
//  PresentationShowcaseApplicationPresentations.swift
//  ConcordUI Presentation Showcase
//
//  Presentation examples for construction, metadata, data, display options,
//  lifecycle, and hosting a Presentation in a Secondary Venue.
//

//  Purpose: Build the Presentation Showcase screens described in the application.
//  Screens: Home links to metadata, editable data, display options, lifecycle, and
//  secondary-venue examples. Each main example provides a Home button; the
//  secondary venue provides Close Venue. The data screen binds its text editor to
//  the application's reused data, and Lifecycle displays shared callback counts.

import Foundation
import ConcordUI

/// Builds presentation examples and their navigation.
nonisolated extension PresentationShowcaseApplication {

    private static var secondaryPresentationVenueID: String { "presentationshowcase.secondary" }

    /// Builds the menu for the presentation examples and secondary venue.
    func homePresentation() -> ConcordPresentation {
        ConcordPresentation(name: "Presentation Showcase Home") {
            ConcordVStack([
                ConcordLabel("ConcordUI Presentation Showcase")
                    .bold()
                    .centerJustified(),
                ConcordLabel("Explore the functional UI behavior owned by a Presentation.")
                    .italic()
                    .centerJustified(),
                ConcordDivider(),

                ConcordButton("Basic Presentation") {
                    self.displayMainPresentation(self.basicPresentation())
                }
                .centerJustified(),

                ConcordButton("Presentation Data") {
                    self.displayMainPresentation(self.dataPresentation())
                }
                .centerJustified(),

                ConcordButton("Display Options") {
                    self.displayMainPresentation(self.displayOptionsPresentation())
                }
                .centerJustified(),

                ConcordButton("Lifecycle") {
                    self.displayMainPresentation(self.lifecyclePresentation())
                }
                .centerJustified(),

                ConcordButton("Secondary Venue Presentation") {
                    let venue = self.prepareSecondaryPresentationVenue()
                    _ = venue.displayHome()
                }
                .centerJustified(),

                ConcordSpacer(),
                ConcordLabel(self.platform.appVersionBuild)
                    .italic()
                    .centerJustified()
            ])
        }
    }

    /// Creates and registers the Secondary Venue once. Creating it alone does not make
    /// anything visible; displayHome() realizes the Venue using its registered Home.
    private func prepareSecondaryPresentationVenue() -> ConcordSecondaryVenue {
        if let venue = secondaryVenue(id: Self.secondaryPresentationVenueID) {
            return venue
        }

        let venue = createSecondaryVenue(
            id: Self.secondaryPresentationVenueID,
            config: ConcordVenueConfig(
                kind: .secondary,
                name: "Presentation Showcase Secondary",
                closable: true,
                initialSize: ConcordVenueSize(520, 420),
                minSize: ConcordVenueSize(360, 280),
                maxSize: ConcordVenueSize(900, 720)
            )
        )

        venue.registerHome { _ in
            ConcordPresentation(name: "Secondary Venue Home") {
                ConcordVStack([
                    ConcordLabel("Secondary Venue Home")
                        .bold()
                        .centerJustified(),
                    ConcordLabel("Venue ID: \(venue.id)")
                        .centerJustified(),
                    ConcordLabel("Every Venue can register and display its own Home Presentation.")
                        .italic(),
                    ConcordLabel("On desktop this Presentation is hosted in its own window. On mobile it is displayed over the previously visible Venue."),
                    ConcordDivider(),
                    ConcordLabel("closeVenue() closes the desktop window or pops the mobile screen and restores the previous Venue and Presentation."),
                    ConcordSpacer(),
                    ConcordButton("Close Venue") {
                        venue.closeVenue()
                    }
                    .centerJustified()
                ])
                .fillSize()
            }
        }

        return venue
    }

    /// Builds the metadata and element-tree explanation with Home navigation.
    func basicPresentation() -> ConcordPresentation {
        ConcordPresentation(
            tag: 101,
            name: "Basic Presentation"
        ) {
            ConcordVStack([
                ConcordLabel("Basic Presentation")
                    .bold()
                    .centerJustified(),
                ConcordLabel("A Presentation owns the Element tree that defines one functional user interface.")
                    .italic(),
                ConcordDivider(),

                ConcordVStack([
                    ConcordLabel("Presentation Metadata")
                        .bold(),
                    ConcordLabel("Name: Basic Presentation"),
                    ConcordLabel("Tag: 101"),
                    ConcordLabel("The Presentation also has a stable UUID identity while that instance exists.")
                        .italic()
                ])
                .boxed(),

                ConcordVStack([
                    ConcordLabel("Element Tree")
                        .bold(),
                    ConcordLabel("The root Element tree is built when the Presentation starts and is released when it finishes."),
                    ConcordLabel("This keeps Presentation UI construction separate from the Venue that hosts it.")
                        .italic()
                ])
                .boxed(),

                ConcordSpacer(),
                self.presentationHomeButton()
            ])
        }
    }

    /// Builds an editable presentation using the application's reused string data.
    func dataPresentation() -> ConcordPresentation {
        let data = sharedPresentationData

        return ConcordPresentation(
            name: "Presentation Data",
            data: data
        ) {
            ConcordVStack([
                ConcordLabel("Presentation Data")
                    .bold()
                    .centerJustified(),
                ConcordLabel("A Presentation can own data independently of its Element tree.")
                    .italic(),
                ConcordDivider(),

                PresentationShowcaseStringData.editableBlock(data),

                ConcordLabel("Navigate Home and return. This application reuses the same data object, so the edited value remains available to the next Presentation instance.")
                    .italic(),

                ConcordSpacer(),
                self.presentationHomeButton()
            ])
        }
    }

    /// Builds an example of presentation font defaults and element-level overrides.
    func displayOptionsPresentation() -> ConcordPresentation {
        ConcordPresentation(
            name: "Display Options",
            displayOptions: ConcordDisplayOptions(
                elementFont: .monospaced,
                elementFontSize: 22
            )
        ) {
            ConcordVStack([
                ConcordLabel("Presentation Display Options")
                    .bold()
                    .centerJustified(),
                ConcordLabel("A Presentation may override display information for its Element tree."),
                ConcordDivider(),

                ConcordVStack([
                    ConcordLabel("Presentation Override")
                        .bold(),
                    ConcordLabel("This Presentation requests monospaced 22-point text."),
                    ConcordLabel("Individual Elements can still override those Presentation defaults.")
                        .systemFont()
                        .fontSize(13)
                ])
                .boxed(),

                ConcordSpacer(),
                self.presentationHomeButton()
            ])
        }
    }

    /// Builds a presentation that counts lifecycle callbacks using shared state.
    func lifecyclePresentation() -> ConcordPresentation {
        PresentationShowcaseLifecyclePresentation(state: lifecycleState) {
            ConcordVStack([
                ConcordLabel("Presentation Lifecycle")
                    .bold()
                    .centerJustified(),
                ConcordLabel("startPresentation() runs before the Element tree is built. finishPresentation() runs before the Presentation is replaced.")
                    .italic(),
                ConcordDivider(),

                ConcordVStack([
                    ConcordLabel("Lifecycle Counts")
                        .bold(),
                    ConcordLabel("Starts: \(self.lifecycleState.starts)"),
                    ConcordLabel("Finishes: \(self.lifecycleState.finishes)"),
                    ConcordLabel("Leave this Presentation and return to see both lifecycle callbacks reflected in the counters.")
                        .italic()
                ])
                .boxed(),

                ConcordSpacer(),
                self.presentationHomeButton()
            ])
        }
    }
}
