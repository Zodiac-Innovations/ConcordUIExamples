//
//  ElementShowcaseApplication.swift
//  ConcordUI Element Showcase
//
//  Created by Steve Sheets on 8/16/26.
//

import Foundation
import ConcordUI

/// Demonstrates the currently implemented ConcordUI element families.
///
/// Each element family is presented on its own presentation. The home
/// presentation provides navigation between the examples.
nonisolated public final class ElementShowcaseApplication: ConcordApplication {

    // MARK: - Presentations

    var homePresentation: ConcordPresentation?
    var stackPresentation: ConcordPresentation?
    var platformSpecificPresentation: ConcordPresentation?
    var labelPresentation: ConcordPresentation?
    var buttonPresentation: ConcordPresentation?
    var textPresentation: ConcordPresentation?
    var booleanPresentation: ConcordPresentation?
    var numericPresentation: ConcordPresentation?
    var valuesPresentation: ConcordPresentation?
    var selectionPresentation: ConcordPresentation?
    var displayPresentation: ConcordPresentation?
    var otherPresentation: ConcordPresentation?

    // MARK: - Shared Binding Values

    var boundTextValue: String? = "Shared text"
    var boundBoolValue: Bool? = true
    var boundIntValue: ConcordInt? = 25
    var boundFloatValue: ConcordFloat? = 0.5
    var boundDateValue: Date? = Date()
    var boundSelectionString: String? = "Green"
    var boundSelectionIndex: ConcordInt? = 1
    var boundStateTag: String? = "CA"
    var boundMonthTag: ConcordInt? = 8

    // MARK: - Initialization

    public init(platform: any ConcordPlatform) {
        super.init(
            platform: platform,
            theme: ConcordTheme(frameColor: .secondary)
        )
    }

    // MARK: - Navigation

    /// Creates the common Home button displayed at the bottom of example presentations.
    func makeHome() -> ConcordButton {
        ConcordButton("Home") {
            guard let homePresentation = self.homePresentation else { return }
            self.displayMainPresentation(homePresentation)
        }
        .centerJustified()
    }

    /// Creates a home-screen button that opens an example presentation.
    func elementButton(_ text: String, _ presentation: ConcordPresentation?) -> ConcordButton {
        ConcordButton(text) {
            guard let presentation else { return }
            self.displayMainPresentation(presentation)
        }
        .centerJustified()
    }

    /// Creates the related manual Raster and automatic overlapping-images examples.
    func makeRasterPresentation() -> ConcordPresentation {
        let images: [ConcordImageData] = [
            .asset("greycat"),
            .asset("lenna"),
            .asset("hindenburg"),
            .asset("lunch"),
            .asset("kiss"),
        ]

        return ConcordPresentation {
            ConcordVStack([
                ConcordLabel("Raster & Overlapping Images").bold().centerJustified(),
                ConcordLabel("Raster provides manual placement; overlapping images builds adaptive layouts on it.").italic(),
                ConcordVStack([
                    ConcordLabel("Manual Image Placement and Z Order").bold(),
                    ConcordRasterElement(width: 320, height: 220)
                        .drawImage(
                            .asset("lenna"),
                            in: ConcordRect(x: 15, y: 20, width: 150, height: 150),
                            zOrder: 1,
                            contentMode: .fill
                        )
                        .drawImage(
                            .asset("greycat"),
                            in: ConcordRect(x: 150, y: 55, width: 150, height: 150),
                            zOrder: 2,
                            contentMode: .fill
                        )
                        .drawImage(
                            .asset("kiss"),
                            in: ConcordRect(x: 120, y: 10, width: 90, height: 90),
                            zOrder: 3
                        )
                        .fillWidth()
                        .fixedHeight(220)
                        .centerJustified()
                        .boxed(cornerRadius: 8),
                    ConcordLabel("The Kiss image has the highest Z order, followed by the cat and Lenna images."),
                    ConcordDivider(),
                    ConcordLabel("Stacked").bold(),
                    ConcordOverlappingImagesElement(
                        .stacked,
                        images: images,
                        width: 320,
                        height: 220
                    )
                    .fillWidth()
                    .fixedHeight(220)
                    .centerJustified()
                    .boxed(cornerRadius: 8),
                    ConcordDivider(),
                    ConcordLabel("Top Left to Bottom Right").bold(),
                    ConcordOverlappingImagesElement(
                        .topLeftToBottomRight,
                        images: images,
                        width: 320,
                        height: 220
                    )
                    .fillWidth()
                    .fixedHeight(220)
                    .centerJustified()
                    .boxed(cornerRadius: 8),
                    ConcordDivider(),
                    ConcordLabel("Top Right to Bottom Left").bold(),
                    ConcordOverlappingImagesElement(
                        .topRightToBottomLeft,
                        images: images,
                        width: 320,
                        height: 220
                    )
                    .fillWidth()
                    .fixedHeight(220)
                    .centerJustified()
                    .boxed(cornerRadius: 8),
                    ConcordDivider(),
                    ConcordLabel("Bottom Left to Top Right").bold(),
                    ConcordOverlappingImagesElement(
                        .bottomLeftToTopRight,
                        images: images,
                        width: 320,
                        height: 220
                    )
                    .fillWidth()
                    .fixedHeight(220)
                    .centerJustified()
                    .boxed(cornerRadius: 8),
                    ConcordDivider(),
                    ConcordLabel("Bottom Right to Top Left").bold(),
                    ConcordOverlappingImagesElement(
                        .bottomRightToTopLeft,
                        images: images,
                        width: 320,
                        height: 220
                    )
                    .fillWidth()
                    .fixedHeight(220)
                    .centerJustified()
                    .boxed(cornerRadius: 8),
                    ConcordLabel("All automatic layouts recalculate their placement when the view changes size.")
                ]).boxed(),
                self.makeHome()
            ])
        }
    }

    // MARK: - Result Helpers

    /// Updates a named result label within a presentation.
    func showResult(_ text: String, presentation: ConcordPresentation?, name: String) {
        guard let result = presentation?.element(name: name) as? ConcordLabel else { return }
        result.text = text
    }

    func optionalText(_ value: String?) -> String {
        value ?? "nil"
    }

    func boolText(_ value: Bool?) -> String {
        value.map { $0 ? "true" : "false" } ?? "nil"
    }

    func intText(_ value: ConcordInt?) -> String {
        value.map { String($0) } ?? "nil"
    }

    func floatText(_ value: ConcordFloat?) -> String {
        value.map { String($0) } ?? "nil"
    }

    func indexText(_ value: Int?) -> String {
        value.map { String($0) } ?? "nil"
    }

    // MARK: - Application

    public override func startApplication() {

        // MARK: Stack Examples

        stackPresentation = ConcordPresentation {
            ConcordVStack([
                ConcordLabel("Stack Examples").bold().centerJustified(),
                ConcordLabel("Horizontal, vertical, adaptive, nested, and spacer-based layout examples.").italic(),
                ConcordVStack([
                    ConcordHStack([
                        ConcordLabel("Left"),
                        ConcordSpacer(),
                        ConcordLabel("Right")
                    ]),
                    ConcordLabel("HStack with expanding Spacer"),
                    ConcordHStack([
                        ConcordButton("One") {},
                        ConcordButton("Two") {},
                        ConcordButton("Three") {}
                    ]),
                    ConcordDivider(),
                    ConcordHStack([
                        ConcordVStack([
                            ConcordLabel("Nested A").bold(),
                            ConcordLabel("A1"),
                            ConcordLabel("A2")
                        ]).boxed(),
                        ConcordSpacer(),
                        ConcordVStack([
                            ConcordLabel("Nested B").bold(),
                            ConcordLabel("B1"),
                            ConcordLabel("B2")
                        ]).boxed()
                    ]),
                    ConcordDivider(),
                    ConcordLabel("ABStack: side by side in landscape, stacked in portrait"),
                    ConcordABStack(
                        a: ConcordVStack([
                            ConcordLabel("Region A").bold(),
                            ConcordLabel("Primary content")
                        ]).boxed(),
                        b: ConcordVStack([
                            ConcordLabel("Region B").bold(),
                            ConcordLabel("Secondary content")
                        ]).boxed()
                    ),
                    ConcordSpacer().fixedHeight(20),
                    ConcordLabel("20 point Spacer above this label")
                ]
                + self.isIOSList([
                    ConcordDivider(), ConcordLabel("iOS-specific stack content")
                ])
                + self.isAndroidList([
                    ConcordDivider(), ConcordLabel("Android-specific stack content")
                ])
                + self.isMacList([
                    ConcordDivider(), ConcordLabel("macOS-specific stack content")
                ])
                + self.isWindowList([
                    ConcordDivider(), ConcordLabel("Windows-specific stack content")
                ])).boxed(),
                self.makeHome()
            ])
        }

        // MARK: Platform Specific UI

        platformSpecificPresentation = ConcordPresentation {
            ConcordVStack(
                [
                    ConcordLabel("Platform Specific UI").bold().centerJustified(),
                    ConcordLabel("Conditional element lists create a native layout for the current platform.")
                        .italic(),
                    ConcordLabel(self.platform.platformType.rawValue)
                        .label("Current Platform")
                        .centerJustified(),
                    ConcordDivider()
                ]
                + self.isIOSList([
                    ConcordVStack([
                        ConcordLabel("iOS Mobile Layout").bold(),
                        ConcordHStack([
                            ConcordButton("Back") {},
                            ConcordSpacer(),
                            ConcordButton("Done") {}
                        ]),
                        ConcordLabel("A compact, touch-oriented single-column interface."),
                        ConcordBoolElement(.toggle, label: "Use Face ID", value: true)
                    ]).boxed()
                ])
                + self.isAndroidList([
                    ConcordVStack([
                        ConcordLabel("Android Material Layout").bold(),
                        ConcordLabel("Primary actions remain prominent in a vertical flow."),
                        ConcordButton("Primary Action") {},
                        ConcordButton("Secondary Action") {},
                        ConcordBoolElement(.checkbox, label: "Use device security", value: true)
                    ]).boxed()
                ])
                + self.isMacList([
                    ConcordLabel("macOS Desktop Layout").bold(),
                    ConcordABStack(
                        a: ConcordVStack([
                            ConcordLabel("Sidebar").bold(),
                            ConcordButton("General") {},
                            ConcordButton("Advanced") {}
                        ]).boxed(),
                        b: ConcordVStack([
                            ConcordLabel("Detail").bold(),
                            ConcordLabel("Desktop content uses two persistent regions."),
                            ConcordButton("Apply") {}
                        ]).boxed()
                    )
                ])
                + self.isWindowList([
                    ConcordVStack([
                        ConcordLabel("Windows Desktop Layout").bold(),
                        ConcordHStack([
                            ConcordButton("File") {},
                            ConcordButton("Edit") {},
                            ConcordButton("View") {}
                        ]),
                        ConcordLabel("Desktop commands and workspace content share one view.")
                    ]).boxed()
                ])
                + isListOnFlag(self.platform.deviceType == .pad, [
                    ConcordLabel("Additional pad-specific content selected with isListOnFlag.")
                        .italic()
                        .boxed()
                ])
                + [ConcordSpacer(), self.makeHome()]
            )
        }

        // MARK: Label Examples

        labelPresentation = ConcordPresentation {
            ConcordVStack([
                ConcordLabel("Label Examples").bold().centerJustified(),
                ConcordLabel("Basic text and semantic label/value presentation.").italic(),
                ConcordVStack([
                    ConcordLabel("Basic Styles").bold(),
                    ConcordLabel("Normal Label"),
                    ConcordLabel("John").label("Name"),
                    ConcordLabel("Bold Label").bold(),
                    ConcordLabel("Italic Label").italic(),
                    ConcordLabel("Underlined Label").underline(),
                    ConcordLabel("Bold Italic Underlined").bold().italic().underline(),
                    ConcordDivider(),
                    ConcordLabel("Fonts").bold(),
                    ConcordLabel("System Font").systemFont(),
                    ConcordLabel("Monospaced Font").monospacedFont(),
                    ConcordLabel("Explicit Monospaced Font").font(.monospaced),
                    ConcordDivider(),
                    ConcordLabel("Colors").bold(),
                    ConcordLabel("Semantic accent foreground").foregroundColor(.accent),
                    ConcordLabel("Semantic success foreground").foregroundColor(.success),
                    ConcordLabel("Background + frame")
                        .foregroundColor(.black)
                        .backgroundColor(.rgba(0.90, 0.95, 1.0))
                        .frameColor(.accent)
                        .boxed(),
                    ConcordDivider(),
                    ConcordLabel("Sizing and Justification").bold(),
                    ConcordLabel("Fixed Width").fixedWidth(200).boxed(),
                    ConcordLabel("Fixed Width and Height").fixedSize(width: 250, height: 50).boxed(),
                    ConcordLabel("Fill Width").fillWidth().boxed(),
                    ConcordLabel("Left Justified").leftJustified(),
                    ConcordLabel("Center Justified").centerJustified(),
                    ConcordLabel("Right Justified").rightJustified(),
                    ConcordDivider(),
                    ConcordLabel("This is a long label intended to test wrapping across the available width.")
                ]).boxed(),
                self.makeHome()
            ])
        }

        // MARK: Button Examples

        let titledActions = [
            ConcordTitleAction("First Action") {
                self.showResult(
                    "First titled action selected",
                    presentation: self.buttonPresentation,
                    name: "buttonResult"
                )
            },
            ConcordTitleAction("Second Action") {
                self.showResult(
                    "Second titled action selected",
                    presentation: self.buttonPresentation,
                    name: "buttonResult"
                )
            },
            ConcordTitleAction("Third Action") {
                self.showResult(
                    "Third titled action selected",
                    presentation: self.buttonPresentation,
                    name: "buttonResult"
                )
            }
        ]

        buttonPresentation = ConcordPresentation(action: { event in
            if event.type == .buttonActivate {
                self.showResult(
                    "Handled by Presentation: \(event.element.name)",
                    presentation: self.buttonPresentation,
                    name: "buttonResult"
                )
            }
        }) {
            ConcordVStack([
                ConcordLabel("Button Examples").bold().centerJustified(),
                ConcordLabel("Actions can be local or bubble to the Presentation.").italic(),
                ConcordVStack([
                    ConcordLabel("Local Actions").bold(),
                    ConcordLabel("No button pressed")
                        .named("buttonResult")
                        .bold()
                        .centerJustified()
                        .boxed(),
                    ConcordButton("Event Closure", action: { event in
                        self.showResult(
                            "Event Closure: \(event.type)",
                            presentation: self.buttonPresentation,
                            name: "buttonResult"
                        )
                    })
                    .named("eventButton")
                    .centerJustified(),
                    ConcordButton("Simple Closure") {
                        self.showResult(
                            "Simple Closure pressed",
                            presentation: self.buttonPresentation,
                            name: "buttonResult"
                        )
                    }
                    .centerJustified(),
                    ConcordDivider(),
                    ConcordLabel("Button Flavors").bold(),
                    ConcordButton(
                        "Text followed by icon",
                        flavor: .textIcon,
                        icon: .information
                    ) {
                        self.showResult(
                            "Text + Icon pressed",
                            presentation: self.buttonPresentation,
                            name: "buttonResult"
                        )
                    }
                    .centerJustified(),
                    ConcordDivider(),
                    ConcordLabel("Presentation Bubbling and State").bold(),
                    ConcordButton("No Local Action").named("fallbackButton"),
                    ConcordButton("Disabled Button") {
                        self.showResult(
                            "ERROR: disabled button activated",
                            presentation: self.buttonPresentation,
                            name: "buttonResult"
                        )
                    }
                    .enabled(false),
                    ConcordDivider(),
                    ConcordLabel("Title Actions").bold(),
                    ConcordLabel("Vertical List"),
                    ConcordTitleActionElement(.vlist, actions: titledActions),
                    ConcordLabel("Horizontal Stack"),
                    ConcordTitleActionElement(.stack, actions: titledActions),
                    ConcordLabel("Popup"),
                    ConcordTitleActionElement(
                        .popup,
                        actions: titledActions,
                        label: "Choose Action",
                        image: .icon(.settings)
                    )
                ]).boxed(),
                self.makeHome()
            ])
        }

        // MARK: Text Examples

        let sharedTextBinding = ConcordBinding<String?>(
            get: { self.boundTextValue },
            set: { self.boundTextValue = $0 }
        )

        textPresentation = ConcordPresentation {
            ConcordVStack([
                ConcordLabel("Text Examples").bold().centerJustified(),
                ConcordLabel("Text entry, binding, callbacks, and validation.").italic(),
                ConcordVStack([
                    ConcordLabel("Basic Text").bold(),
                    ConcordTextElement(.normal, label: "Name", value: "John")
                        .placeholder("Enter a name")
                        .textColor(.accent),
                    ConcordTextElement(.normal, label: "City", value: nil)
                        .placeholder("Enter a city"),
                    ConcordTextElement(.password, label: "Password", value: nil)
                        .placeholder("Enter password"),
                    ConcordDivider(),
                    ConcordLabel("Shared Binding").bold(),
                    ConcordTextElement(.normal, label: "Bound Text A", value: sharedTextBinding),
                    ConcordTextElement(.normal, label: "Bound Text B", value: sharedTextBinding),
                    ConcordDivider(),
                    ConcordLabel("Change Callback").bold(),
                    ConcordTextElement(.normal, label: "Callback Text", value: "Original")
                        .onChange { oldValue, newValue in
                            self.showResult(
                                "Text: \(self.optionalText(oldValue)) → \(self.optionalText(newValue))",
                                presentation: self.textPresentation,
                                name: "textResult"
                            )
                        },
                    ConcordLabel("Text callback waiting")
                        .named("textResult")
                        .italic()
                        .boxed(),
                    ConcordDivider(),
                    ConcordLabel("Validation").bold(),
                    ConcordTextElement(.normal, label: "Letters Only", value: "Steve")
                        .regex("^[A-Za-z]+$", error: "Only letters are allowed"),
                    ConcordTextElement(.normal, label: "Numbers Only", value: "ABC")
                        .regex("^[0-9]+$")
                        .help("Uses ConcordString.invalidText when invalid.")
                ]).boxed(),
                self.makeHome()
            ])
        }

        // MARK: Boolean Examples

        let sharedBoolBinding = ConcordBinding<Bool?>(
            get: { self.boundBoolValue },
            set: { self.boundBoolValue = $0 }
        )

        booleanPresentation = ConcordPresentation {
            ConcordVStack([
                ConcordLabel("Boolean Examples").bold().centerJustified(),
                ConcordLabel("Toggle, checkbox, radio, binding, and change callbacks.").italic(),
                ConcordVStack([
                    ConcordLabel("Shared Binding").bold(),
                    ConcordBoolElement(.toggle, label: "Bound Toggle", value: sharedBoolBinding)
                        .controlOnRight(),
                    ConcordBoolElement(.checkbox, label: "Bound Checkbox", value: sharedBoolBinding),
                    ConcordBoolElement(.radio, label: "Bound Radio", value: sharedBoolBinding).nameYesNo(),
                    ConcordDivider(),
                    ConcordLabel("Indeterminate Values").bold(),
                    ConcordBoolElement(.toggle, label: "Indeterminate Toggle", value: nil),
                    ConcordBoolElement(.checkbox, label: "Indeterminate Checkbox", value: nil),
                    ConcordBoolElement(.radio, label: "Indeterminate Radio", value: nil).nameYesNo(),
                    ConcordDivider(),
                    ConcordLabel("Change Callback").bold(),
                    ConcordBoolElement(.toggle, label: "Callback Toggle", value: true)
                        .onChange { oldValue, newValue in
                            self.showResult(
                                "Bool: \(self.boolText(oldValue)) → \(self.boolText(newValue))",
                                presentation: self.booleanPresentation,
                                name: "boolResult"
                            )
                        },
                    ConcordLabel("Boolean callback waiting")
                        .named("boolResult")
                        .italic()
                        .boxed()
                ]).boxed(),
                self.makeHome()
            ])
        }

        // MARK: Numeric Examples

        let sharedIntBinding = ConcordBinding<ConcordInt?>(
            get: { self.boundIntValue },
            set: { self.boundIntValue = $0 }
        )
        let sharedFloatBinding = ConcordBinding<ConcordFloat?>(
            get: { self.boundFloatValue },
            set: { self.boundFloatValue = $0 }
        )

        numericPresentation = ConcordPresentation {
            ConcordVStack([
                ConcordLabel("Numeric Examples").bold().centerJustified(),
                ConcordLabel("Integer and floating-point input, stepper, slider, and combo flavors.").italic(),
                ConcordVStack([
                    ConcordLabel("ConcordInt Flavors").bold(),
                    ConcordIntElement(.input, label: "Integer Input", value: 42)
                        .placeholder("Enter an integer"),
                    ConcordIntElement(.stepper, label: "Integer Stepper", value: 5)
                        .range(0...10, step: 1),
                    ConcordIntElement(.slider, label: "Integer Slider", value: 25)
                        .range(0...100, step: 5),
                    ConcordIntElement(.combo, label: "Integer Combo", value: 50)
                        .range(0...100, step: 5),
                    ConcordDivider(),
                    ConcordLabel("ConcordInt Shared Binding").bold(),
                    ConcordIntElement(.input, label: "Bound Integer", value: sharedIntBinding)
                        .range(0...100),
                    ConcordIntElement(.slider, label: "Bound Integer Slider", value: sharedIntBinding)
                        .range(0...100),
                    ConcordDivider(),
                    ConcordLabel("ConcordFloat Flavors").bold(),
                    ConcordFloatElement(.input, label: "Float Input", value: 3.14159)
                        .placeholder("Enter a decimal"),
                    ConcordFloatElement(.stepper, label: "Float Stepper", value: 2.5)
                        .range(0.0...10.0, step: 0.5),
                    ConcordFloatElement(.slider, label: "Float Slider", value: 0.25)
                        .range(0.0...1.0, step: 0.05),
                    ConcordFloatElement(.combo, label: "Float Combo", value: 0.5)
                        .range(0.0...1.0, step: 0.1),
                    ConcordFloatElement(.slider, label: "Bound Float", value: sharedFloatBinding)
                        .range(0.0...1.0, step: 0.05)
                ]).boxed(),
                self.makeHome()
            ])
        }

        // MARK: Date and Time Examples

        let sharedDateBinding = ConcordBinding<Date?>(
            get: { self.boundDateValue },
            set: { self.boundDateValue = $0 }
        )
        let calendar = Calendar.current
        let minimumDate = calendar.date(byAdding: .year, value: -100, to: Date()) ?? Date.distantPast
        let maximumDate = calendar.date(byAdding: .year, value: 10, to: Date()) ?? Date.distantFuture

        valuesPresentation = ConcordPresentation {
            ConcordVStack([
                ConcordLabel("Date & Time Examples").bold().centerJustified(),
                ConcordLabel("Date, time, and date-time controls all use Foundation Date.").italic(),
                ConcordVStack([
                    ConcordLabel("Date").bold(),
                    ConcordDateElement(.picker, label: "Native Date", value: sharedDateBinding)
                        .range(from: minimumDate, through: maximumDate)
                        .help("Picker flavor uses the platform-native compact date editor."),
                    ConcordLabel("Date Components").bold(),
                    ConcordDateElement(.components, label: "", value: sharedDateBinding)
                        .help("Components flavor exposes the native component-oriented date editor."),
                    ConcordDateElement(.picker, label: "Read-only Date", value: sharedDateBinding)
                        .readOnly(),
                    ConcordDivider(),
                    ConcordLabel("Time").bold(),
                    ConcordTimeElement(.picker, label: "Native Time", value: sharedDateBinding),
                    ConcordLabel("Time Components").bold(),
                    ConcordTimeElement(.components, label: "", value: sharedDateBinding),
                    ConcordTimeElement(.picker, label: "Read-only Time", value: sharedDateBinding)
                        .readOnly(),
                    ConcordDivider(),
                    ConcordLabel("Date + Time").bold(),
                    ConcordDateTimeElement(.picker, label: "Date and Time", value: sharedDateBinding)
                        .onChange { _, _ in
                            self.showResult(
                                "Shared Date changed",
                                presentation: self.valuesPresentation,
                                name: "dateResult"
                            )
                        },
                    ConcordLabel("DateTime Components").bold(),
                    ConcordDateTimeElement(.components, label: "", value: sharedDateBinding),
                    ConcordLabel("Date callback waiting")
                        .named("dateResult")
                        .italic()
                        .boxed(),
                    ConcordDivider(),
                    ConcordLabel("Validation").bold(),
                    ConcordDateElement(.picker, label: "Required Date", value: nil)
                        .required()
                        .help("Required validation remains quiet until Presentation validation is invoked.")
                ]).boxed(),
                self.makeHome()
            ])
        }

        // MARK: Selection Examples

        let colorBinding = ConcordBinding<String?>(
            get: { self.boundSelectionString },
            set: { self.boundSelectionString = $0 }
        )
        let indexBinding = ConcordBinding<ConcordInt?>(
            get: { self.boundSelectionIndex },
            set: { self.boundSelectionIndex = $0 }
        )
        let stateBinding = ConcordBinding<String?>(
            get: { self.boundStateTag },
            set: { self.boundStateTag = $0 }
        )
        let monthBinding = ConcordBinding<ConcordInt?>(
            get: { self.boundMonthTag },
            set: { self.boundMonthTag = $0 }
        )

        let colors = ["Red", "Green", "Blue"]
        let states = [
            ConcordStringTaggedItem("California", tag: "CA"),
            ConcordStringTaggedItem("Maryland", tag: "MD"),
            ConcordStringTaggedItem("Virginia", tag: "VA")
        ]
        let months = [
            ConcordIntTaggedItem("January", tag: 1),
            ConcordIntTaggedItem("February", tag: 2),
            ConcordIntTaggedItem("March", tag: 3),
            ConcordIntTaggedItem("April", tag: 4),
            ConcordIntTaggedItem("May", tag: 5),
            ConcordIntTaggedItem("June", tag: 6),
            ConcordIntTaggedItem("July", tag: 7),
            ConcordIntTaggedItem("August", tag: 8),
            ConcordIntTaggedItem("September", tag: 9),
            ConcordIntTaggedItem("October", tag: 10),
            ConcordIntTaggedItem("November", tag: 11),
            ConcordIntTaggedItem("December", tag: 12)
        ]

        selectionPresentation = ConcordPresentation {
            ConcordVStack([
                ConcordLabel("Selection Examples").bold().centerJustified(),
                ConcordLabel("Binding semantics are separate from presentation flavor.").italic(),
                ConcordVStack([
                    ConcordLabel("Plain Selections").bold(),
                    ConcordStringSelectionElement(
                        .popup,
                        label: "String / Popup",
                        items: colors,
                        value: colorBinding
                    )
                    .onChange { index, text in
                        self.showResult(
                            "String: index \(self.indexText(index)), \(text ?? "nil")",
                            presentation: self.selectionPresentation,
                            name: "selectionResult"
                        )
                    },
                    ConcordIndexSelectionElement(
                        .segmented,
                        label: "Index / Segmented",
                        items: ["Small", "Medium", "Large"],
                        value: indexBinding
                    ),
                    ConcordDivider(),
                    ConcordLabel("Tagged Selections").bold(),
                    ConcordStringTaggedSelectionElement(
                        .radio,
                        label: "String Tag / Radio",
                        items: states,
                        value: stateBinding
                    )
                    .showTag(),
                    ConcordIntTaggedSelectionElement(
                        .spinner,
                        label: "Int Tag / Spinner",
                        items: months,
                        value: monthBinding
                    )
                    .showTag()
                    .onChange { index, text, tag in
                        self.showResult(
                            "Month: index \(self.indexText(index)), \(text ?? "nil"), tag \(self.intText(tag))",
                            presentation: self.selectionPresentation,
                            name: "selectionResult"
                        )
                    },
                    ConcordLabel("Selection callback waiting")
                        .named("selectionResult")
                        .italic()
                        .boxed(),
                    ConcordDivider(),
                    ConcordLabel("List Presentation").bold(),
                    ConcordStringSelectionElement(
                        .list,
                        label: "List Flavor",
                        items: ["Alpha", "Beta", "Gamma"],
                        value: "Beta"
                    )
                ]).boxed(),
                self.makeHome()
            ])
        }

        // MARK: Image and Icon Examples

        displayPresentation = ConcordPresentation {
            let settingsData = ConcordImageData.icon(.settings)

            return ConcordVStack([
                ConcordLabel("Image & Icon Examples").bold().centerJustified(),
                ConcordLabel("ConcordImage displays portable ConcordImageData from assets or semantic icons.").italic(),
                ConcordVStack([
                    ConcordLabel("Application Icon").bold(),
                    ConcordImage(self.platform.appIcon)
                        .fixedSize(width: 128, height: 128)
                        .centerJustified()
                        .accessibility("Application Icon"),
                    ConcordDivider(),
                    ConcordLabel("Standard Icons").bold(),
                    ConcordHStack([
                        ConcordImage(.icon(.app)).accessibility("Application"),
                        ConcordImage(.icon(.home)).accessibility("Home"),
                        ConcordImage(settingsData)
                            .accessibility("Settings")
                            .foregroundColor(.accent),
                        ConcordImage.icon(.information).accessibility("Information"),
                        ConcordImage.icon(.search).accessibility("Search"),
                        ConcordImage.icon(.add).accessibility("Add"),
                        ConcordImage.icon(.check).accessibility("Check")
                    ]),
                    ConcordDivider(),
                    ConcordLabel("Image Assets").bold(),
                    ConcordImage("greycat")
                        .fixedSize(width: 200, height: 150)
                        .centerJustified()
                        .accessibility("Grey cat"),
                    ConcordLabel("Named image assets use ConcordImage(\"AssetName\") or ConcordImage(.asset(\"AssetName\")).")
                ]).boxed(),
                self.makeHome()
            ])
        }

        // MARK: Other Examples

        otherPresentation = ConcordPresentation {
            ConcordVStack([
                ConcordLabel("Other Examples").bold().centerJustified(),
                ConcordLabel("Additional display elements and capabilities.").italic(),
                ConcordVStack([
                    ConcordLabel("Progress").bold(),
                    ConcordProgressElement(.bar, label: "25%", value: 0.25),
                    ConcordProgressElement(.bar, label: "75%", value: 0.75),
                    ConcordProgressElement(.spinner, label: "Working"),
                    ConcordProgressElement(.bar, label: "Fluent update", value: 0).progress(0.5),
                    ConcordDivider(),
                    ConcordLabel("Horizontal Line").bold(),
                    ConcordLabel("The line below is a ConcordLine used as a simple layout separator."),
                    ConcordLine(),
                    ConcordLabel("Content after the horizontal line."),
                    ConcordDivider(),
                    ConcordLabel("Expanders").bold(),
                    ConcordExpander(
                        .triangle,
                        label: "Triangle Expander",
                        elements: [
                            ConcordLabel("Triangle child one"),
                            ConcordLabel("Triangle child two")
                        ],
                        expanded: true
                    ),
                    ConcordExpander(
                        .checkbox,
                        label: "Checkbox Expander",
                        elements: [
                            ConcordLabel("Checkbox child one"),
                            ConcordLabel("Checkbox child two")
                        ]
                    )
                    .controlOnRight(false)
                ]).boxed(),
                self.makeHome()
            ])
        }

        // MARK: Home

        homePresentation = ConcordPresentation {
            ConcordVStack([
                ConcordLabel("ConcordUI Element Showcase").bold().centerJustified(),
                ConcordLabel("Explore the currently implemented ConcordUI element families.")
                    .italic()
                    .centerJustified(),
                ConcordDivider(),
                self.elementButton("Stacks", self.stackPresentation),
                self.elementButton("Platform Specific UI", self.platformSpecificPresentation),
                self.elementButton("Labels", self.labelPresentation),
                self.elementButton("Buttons", self.buttonPresentation),
                self.elementButton("Text", self.textPresentation),
                self.elementButton("Booleans", self.booleanPresentation),
                self.elementButton("Numerics", self.numericPresentation),
                self.elementButton("Date & Time", self.valuesPresentation),
                self.elementButton("Selections", self.selectionPresentation),
                self.elementButton("Images & Icons", self.displayPresentation),
                ConcordButton("Raster & Overlapping Images") {
                    self.displayMainPresentation(self.makeRasterPresentation())
                }
                .centerJustified(),
                self.elementButton("Others", self.otherPresentation),
                ConcordSpacer(),
                ConcordLabel(self.platform.appVersionBuild).italic().centerJustified()
            ])
        }

        if let homePresentation {
            displayMainPresentation(homePresentation)
        }
    }
}
