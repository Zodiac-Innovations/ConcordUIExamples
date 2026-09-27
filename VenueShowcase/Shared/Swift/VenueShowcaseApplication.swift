//
//  VenueShowcaseApplication.swift
//  VenueShowcase
//

import ConcordUI

nonisolated public final class VenueShowcaseApplication: ConcordApplication {
    private static let toolsVenueID = "venueshowcase.tools"
    private static let toolsPrimaryTag = 101
    private static let toolsAlternateTag = 102

    public override func startApplication() {
        showMainVenue()
    }

    private func showMainVenue() {
        mainVenue.displayPresentation(
            ConcordPresentation {
                ConcordVStack([
                    ConcordText("Venue Showcase")
                        .centerJustified(),

                    ConcordText("Current Venue: \(self.mainVenue.id)")
                        .centerJustified(),

                    ConcordText("Kind: Main")
                        .centerJustified(),

                    ConcordButton("Create Tools Venue") {
                        _ = self.prepareToolsVenue()
                    }
                    .centerJustified(),

                    ConcordButton("Find Tools Venue") {
                        let message = self.secondaryVenue(id: Self.toolsVenueID) == nil
                            ? "Tools Venue not found"
                            : "Tools Venue found"
                        _ = self.platform.banner(message)
                    }
                    .centerJustified(),

                    ConcordButton("Display Tools Presentation") {
                        let venue = self.prepareToolsVenue()
                        _ = venue.displayPresentation(tag: Self.toolsPrimaryTag)
                    }
                    .centerJustified(),

                    ConcordButton("Display Alternate Tools Presentation") {
                        let venue = self.prepareToolsVenue()
                        _ = venue.displayPresentation(tag: Self.toolsAlternateTag)
                    }
                    .centerJustified(),

                    ConcordButton("Remove Tools Venue") {
                        self.removeSecondaryVenue(id: Self.toolsVenueID)
                    }
                    .centerJustified(),

                    ConcordButton("Show Dialog from Main Venue") {
                        self.showModal(.dialog, attachedTo: self.mainVenue)
                    }
                    .centerJustified(),

                    ConcordButton("Show Sheet from Main Venue") {
                        self.showModal(.sheet, attachedTo: self.mainVenue)
                    }
                    .centerJustified(),
                ])
                .fillSize()
            }
        )
    }

    /// Creates the Secondary Venue only when it does not already exist.
    /// Creation and registration do not display the Venue.
    private func prepareToolsVenue() -> ConcordSecondaryVenue {
        if let existing = secondaryVenue(id: Self.toolsVenueID) {
            return existing
        }

        let venue = createSecondaryVenue(
            id: Self.toolsVenueID,
            config: ConcordVenueConfig(
                kind: .secondary,
                name: "Venue Showcase Tools",
                closable: true,
                initialSize: ConcordVenueSize(500, 400),
                minSize: ConcordVenueSize(300, 250),
                maxSize: ConcordVenueSize(800, 700)
            )
        )

        venue.registerPresentation(tag: Self.toolsPrimaryTag) { _ in
            ConcordPresentation {
                ConcordVStack([
                    ConcordText("Secondary Venue")
                        .centerJustified(),
                    ConcordText("ID: \(venue.id)")
                        .centerJustified(),
                    ConcordText("Presentation One")
                        .centerJustified(),
                    ConcordButton("Show Attached Dialog") {
                        self.showModal(.dialog, attachedTo: venue)
                    }
                    .centerJustified(),
                    ConcordButton("Show Attached Sheet") {
                        self.showModal(.sheet, attachedTo: venue)
                    }
                    .centerJustified(),
                    ConcordButton("Remove Venue and Return") {
                        self.removeSecondaryVenue(id: Self.toolsVenueID)
                    }
                    .centerJustified(),
                ])
                .fillSize()
            }
        }

        venue.registerPresentation(tag: Self.toolsAlternateTag) { _ in
            ConcordPresentation {
                ConcordVStack([
                    ConcordText("Secondary Venue")
                        .centerJustified(),
                    ConcordText("ID: \(venue.id)")
                        .centerJustified(),
                    ConcordText("Presentation Two")
                        .centerJustified(),
                    ConcordButton("Show Attached Dialog") {
                        self.showModal(.dialog, attachedTo: venue)
                    }
                    .centerJustified(),
                    ConcordButton("Show Attached Sheet") {
                        self.showModal(.sheet, attachedTo: venue)
                    }
                    .centerJustified(),
                    ConcordButton("Remove Venue and Return") {
                        self.removeSecondaryVenue(id: Self.toolsVenueID)
                    }
                    .centerJustified(),
                ])
                .fillSize()
            }
        }

        return venue
    }

    private func showModal(
        _ flavor: ConcordModalVenueFlavor,
        attachedTo owner: ConcordVenue
    ) {
        let modal = owner.createModalVenue(flavor: flavor)
            .venue(name: flavor == .dialog ? "Modal Dialog" : "Modal Sheet")
            .size(420, 280)

        modal.displayPresentation(
            ConcordPresentation {
                ConcordVStack([
                    ConcordText("Modal Venue")
                        .centerJustified(),
                    ConcordText("Attached to: \(owner.id)")
                        .centerJustified(),
                    ConcordText(
                        flavor == .dialog
                            ? "Desktop flavor: Dialog"
                            : "Desktop flavor: Sheet"
                    )
                    .centerJustified(),
                    ConcordText("On mobile this appears as a modal screen.")
                        .centerJustified(),
                    ConcordButton("Dismiss Modal") {
                        modal.dismiss()
                    }
                    .centerJustified(),
                ])
                .fillSize()
            }
        )
    }
}
