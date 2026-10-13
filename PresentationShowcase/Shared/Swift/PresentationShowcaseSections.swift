//
//  PresentationShowcaseSections.swift
//  ConcordUI Presentation Showcase
//
//  Shared Presentation-focused support types.
//

//  Purpose: Provide the data and lifecycle support used by Presentation Showcase.
//  Sections: The editable data block contains a bound text field and a value label.
//  The lifecycle presentation increments shared start and finish counters so the
//  Lifecycle screen can show what happens when you leave it and return.

import Foundation
import ConcordUI

/// Provides binding and editor helpers for shared presentation string data.
nonisolated enum PresentationShowcaseStringData {
    /// Creates a two-way optional-string binding, storing an empty string for nil.
    static func binding(_ data: ConcordStringData) -> ConcordBinding<String?> {
        ConcordBinding<String?>(
            get: { data.value },
            set: { data.value = $0 ?? "" }
        )
    }

    /// Builds the string editor and current-value label for presentation-owned data.
    static func editableBlock(_ data: ConcordStringData) -> ConcordVStack {
        ConcordVStack([
            ConcordLabel("Presentation-Owned Data")
                .bold(),
            ConcordTextElement(
                .normal,
                label: "String",
                value: binding(data)
            )
            .placeholder("Edit presentation data"),
            ConcordLabel("Current value: \(data.value)")
                .italic()
        ])
        .boxed()
    }
}

/// Stores lifecycle counts across successive presentation instances.
nonisolated final class PresentationShowcaseLifecycleState {
    var starts: Int = 0
    var finishes: Int = 0
}

/// Counts start and finish callbacks for the Lifecycle example.
nonisolated final class PresentationShowcaseLifecyclePresentation: ConcordPresentation {
    private let lifecycleState: PresentationShowcaseLifecycleState

    /// Initializes the lifecycle presentation with shared counters and content.
    init(
        state: PresentationShowcaseLifecycleState,
        _ content: @escaping ConcordElementBuilder
    ) {
        self.lifecycleState = state
        super.init(
            name: "Lifecycle Presentation",
            content
        )
    }

    /// Records a presentation start before the framework builds its element tree.
    override func startPresentation() {
        lifecycleState.starts += 1
    }

    /// Records a presentation finish before the framework releases its element tree.
    override func finishPresentation() {
        lifecycleState.finishes += 1
    }
}
