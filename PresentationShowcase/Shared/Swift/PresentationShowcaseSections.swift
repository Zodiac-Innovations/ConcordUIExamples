//
//  PresentationShowcaseSections.swift
//  ConcordUI Presentation Showcase
//
//  Shared Presentation-focused support types.
//

import Foundation
import ConcordUI

nonisolated enum PresentationShowcaseStringData {
    static func binding(_ data: ConcordStringData) -> ConcordBinding<String?> {
        ConcordBinding<String?>(
            get: { data.value },
            set: { data.value = $0 ?? "" }
        )
    }

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

nonisolated final class PresentationShowcaseLifecycleState {
    var starts: Int = 0
    var finishes: Int = 0
}

nonisolated final class PresentationShowcaseLifecyclePresentation: ConcordPresentation {
    private let lifecycleState: PresentationShowcaseLifecycleState

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

    override func startPresentation() {
        lifecycleState.starts += 1
    }

    override func finishPresentation() {
        lifecycleState.finishes += 1
    }
}
