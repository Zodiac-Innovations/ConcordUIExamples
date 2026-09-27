//
//  PresentationShowcaseApplicationPresentations.swift
//  ConcordUI Presentation Showcase
//
//  Presentation examples for construction, metadata, data, display options,
//  lifecycle, and hosting a Presentation in a Secondary Venue.
//

import Foundation
import ConcordUI

nonisolated extension PresentationShowcaseApplication {

    private static var secondaryPresentationVenueID: String { "presentationshowcase.secondary" }

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
