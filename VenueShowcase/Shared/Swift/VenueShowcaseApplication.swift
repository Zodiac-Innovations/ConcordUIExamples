//
//  VenueShowcaseApplication.swift
//  VenueShowcase
//

//  Purpose: Demonstrate main, secondary, and attached modal ConcordUI venues.
//  Screens: The main venue shows its identity and opens the Tools secondary venue.
//  Tools has two registered presentations, Tools and Overview, sharing one venue.
//  Dialog and sheet examples display their owning venue's identity and modal flavor.
//  Controls: Open Tools Venue displays its first presentation. Switch Presentation
//  alternates the two Tools presentations. Show Dialog and Show Sheet create a
//  modal attached to the venue containing the button; Dismiss closes that modal.
//  Close Tools Venue removes the secondary venue. Desktop uses separate windows
//  and modal flavors; mobile uses secondary navigation and modal screens.

import ConcordUI

/// Manages the main, Tools, and attached modal venue demonstrations.
nonisolated public final class VenueShowcaseApplication: ConcordApplication {
    private static let toolsVenueID = "venueshowcase.tools"
    private static let toolsPrimaryTag = 101
    private static let toolsAlternateTag = 102

    /// Displays the main venue and its secondary-venue and modal controls.
    public override func startApplication() {
        showMainVenue()
    }

    /// Displays the main venue identity and buttons for secondary and modal venues.
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

                    ConcordButton("Open Tools Venue") {
                        let venue = self.prepareToolsVenue()
                        _ = venue.displayPresentation(tag: Self.toolsPrimaryTag)
                    }
                    .centerJustified(),

                    ConcordButton("Show Dialog") {
                        self.showModal(.dialog, attachedTo: self.mainVenue)
                    }
                    .centerJustified(),

                    ConcordButton("Show Sheet") {
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
                    ConcordText("Tools — Presentation One")
                        .centerJustified(),
                    ConcordText("Use this venue to open an attached dialog or sheet.")
                        .centerJustified(),
                    ConcordButton("Switch Presentation") {
                        _ = venue.displayPresentation(tag: Self.toolsAlternateTag)
                    }
                    .centerJustified(),
                    ConcordButton("Show Dialog") {
                        self.showModal(.dialog, attachedTo: venue)
                    }
                    .centerJustified(),
                    ConcordButton("Show Sheet") {
                        self.showModal(.sheet, attachedTo: venue)
                    }
                    .centerJustified(),
                    ConcordButton("Close Tools Venue") {
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
                    ConcordText("Overview — Presentation Two")
                        .centerJustified(),
                    ConcordText("Different content, same secondary venue.")
                        .centerJustified(),
                    ConcordButton("Switch Presentation") {
                        _ = venue.displayPresentation(tag: Self.toolsPrimaryTag)
                    }
                    .centerJustified(),
                    ConcordButton("Show Dialog") {
                        self.showModal(.dialog, attachedTo: venue)
                    }
                    .centerJustified(),
                    ConcordButton("Show Sheet") {
                        self.showModal(.sheet, attachedTo: venue)
                    }
                    .centerJustified(),
                    ConcordButton("Close Tools Venue") {
                        self.removeSecondaryVenue(id: Self.toolsVenueID)
                    }
                    .centerJustified(),
                ])
                .fillSize()
            }
        }

        return venue
    }

    /// Creates and displays an attached dialog or sheet with a Dismiss button.
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
                    ConcordButton("Dismiss") {
                        modal.dismiss()
                    }
                    .centerJustified(),
                ])
                .fillSize()
            }
        )
    }
}
