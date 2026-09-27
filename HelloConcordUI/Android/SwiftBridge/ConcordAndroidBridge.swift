import Android
import ConcordUI
import SharedApplication
import Foundation

final class ConcordAndroidPlatform: ConcordPlatform, ConcordVenuePlatformLifecycle {
    private(set) var currentPresentation: ConcordPresentation?
    private var previousPresentationsByVenueID: [String: ConcordPresentation] = [:]

    func displayPresentation(_ presentation: ConcordPresentation) {
        currentPresentation = presentation
    }

    func displayPresentation(_ presentation: ConcordPresentation, in venue: ConcordVenue) {
        if venue.config.kind == .secondary,
           currentPresentation !== presentation,
           let previous = currentPresentation,
           previousPresentationsByVenueID[venue.id] == nil {
            previousPresentationsByVenueID[venue.id] = previous
        }
        displayPresentation(presentation)
    }

    func refreshPresentation(_ presentation: ConcordPresentation) {
        currentPresentation = presentation
    }

    func refreshPresentation(_ presentation: ConcordPresentation, in venue: ConcordVenue) {
        refreshPresentation(presentation)
    }

    func closeVenue(_ venue: ConcordVenue) {
        restorePreviousPresentation(for: venue, discardIfNotVisible: false)
    }

    func dismissVenue(_ venue: ConcordVenue) {
        restorePreviousPresentation(for: venue, discardIfNotVisible: true)
    }

    private func restorePreviousPresentation(
        for venue: ConcordVenue,
        discardIfNotVisible: Bool
    ) {
        guard venue.config.kind == .secondary else { return }

        guard let venuePresentation = venue.currentPresentation,
              currentPresentation === venuePresentation else {
            if discardIfNotVisible {
                previousPresentationsByVenueID.removeValue(forKey: venue.id)
            }
            return
        }

        if let previous = previousPresentationsByVenueID.removeValue(forKey: venue.id) {
            displayPresentation(previous)
        } else if let mainPresentation = venue.application?.mainVenue.currentPresentation {
            displayPresentation(mainPresentation)
        }
    }

    func element(at path: String) -> ConcordElement? {
        guard var element = currentPresentation?.root else { return nil }
        guard !path.isEmpty else { return element }
        for component in path.split(separator: "/") {
            guard let index = Int(component), let container = element as? ConcordContainer,
                  container.elements.indices.contains(index) else { return nil }
            element = container.elements[index]
        }
        return element
    }
}

nonisolated(unsafe) private var androidPlatform: ConcordAndroidPlatform?
nonisolated(unsafe) private var androidApplication: HelloConcordUIApplication?

private func swiftString(_ value: jstring, environment: UnsafeMutablePointer<JNIEnv?>) -> String {
    guard let chars = environment.pointee!.pointee.GetStringUTFChars(environment, value, nil) else { return "" }
    defer { environment.pointee!.pointee.ReleaseStringUTFChars(environment, value, chars) }
    return String(cString: chars)
}
private func javaString(_ value: String, environment: UnsafeMutablePointer<JNIEnv?>) -> jstring {
    value.withCString { environment.pointee!.pointee.NewStringUTF(environment, $0)! }
}
private func element(_ path: jstring, environment: UnsafeMutablePointer<JNIEnv?>) -> ConcordElement? {
    androidPlatform?.element(at: swiftString(path, environment: environment))
}
private func color(_ value: ConcordElement?, role: jint) -> ConcordColor? {
    guard let value else { return nil }
    switch role { case 1: return value.resolvedForegroundColor; case 2: return value.resolvedBackgroundColor; case 3: return value.resolvedFrameColor; case 4: return value.resolvedTextColor; default: return nil }
}
private func explicitColor(_ value: ConcordElement?, role: jint) -> ConcordColor? {
    guard let value else { return nil }
    switch role { case 1: return value.foregroundColor; case 2: return value.backgroundColor; case 3: return value.frameColor; case 4: return value.textColor; default: return nil }
}
private func colorString(_ color: ConcordColor?) -> String {
    guard let color else { return "" }
    switch color { case .semantic(let semantic): return "semantic:\(semantic.rawValue)"; case .rgba(let r, let g, let b, let a): return "rgba:\(r),\(g),\(b),\(a)" }
}

@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_start")
public func concordAndroidStart(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject) {
    let platform = ConcordAndroidPlatform()
    let application = HelloConcordUIApplication(platform: platform)
    androidPlatform = platform
    androidApplication = application
    application.startApplication()
}

@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_completeStandardAppStart")
public func concordAndroidCompleteStandardAppStart(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject) {
    androidApplication?.completeStandardAppStart()
}

@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_elementType")
public func concordAndroidElementType(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint {
    guard let value = element(path, environment: environment) else { return 0 }
    if value is ConcordLabel { return 1 }; if value is ConcordButton { return 2 }; if value is ConcordVStack { return 3 }; if value is ConcordHStack { return 4 }
    if value is ConcordSpacer { return 5 }; if value is ConcordDivider { return 6 }; if value is ConcordBoolElement { return 7 }; if value is ConcordTextElement { return 8 }
    if value is ConcordIntElement { return 9 }; if value is ConcordFloatElement { return 10 }; if value is ConcordDateElement { return 11 }; if value is ConcordTimeElement { return 12 }
    if value is ConcordDateTimeElement { return 13 }; if value is ConcordImageElement { return 14 }; if value is ConcordProgressElement { return 15 }; if value is any ConcordSelectionPresenting { return 16 }
    if value is ConcordLine { return 17 }; if value is ConcordExpander { return 18 }; if value is ConcordABStack { return 19 }; if value is ConcordWorkStack { return 20 }; if value is ConcordRasterElement { return 21 }; if value is ConcordTitleActionElement { return 22 }; if value is ConcordActionGroupButton { return 23 }; return 0
}

@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_elementText") public func concordAndroidElementText(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring {
    let value: String
    if let label = element(path, environment: environment) as? ConcordLabel { value = label.label.map { "\($0): \(label.text)" } ?? label.text }
    else if let button = element(path, environment: environment) as? ConcordButton { value = button.title }
    else { value = "" }
    return javaString(value, environment: environment)
}
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_buttonFlavor") public func concordAndroidButtonFlavor(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint {
    guard let flavor = (element(path, environment: environment) as? ConcordButton)?.flavor else { return 0 }
    switch flavor { case .text: return 1; case .roundedRectangle: return 2; case .icon: return 3; case .textIcon: return 4 }
}
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_buttonRole") public func concordAndroidButtonRole(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint {
    guard let role = (element(path, environment: environment) as? ConcordButton)?.role else { return 0 }
    switch role { case .normal: return 1; case .defaultAction: return 2; case .cancel: return 3; case .destructive: return 4 }
}
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_buttonIcon") public func concordAndroidButtonIcon(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring {
    javaString((element(path, environment: environment) as? ConcordButton)?.icon?.rawValue ?? "", environment: environment)
}

@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_titleActionFlavor")
public func concordAndroidTitleActionFlavor(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint {
    guard let flavor = (element(path, environment: environment) as? ConcordTitleActionElement)?.flavor else { return 0 }
    switch flavor { case .vlist: return 1; case .stack: return 2; case .popup: return 3 }
}
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_titleActionLabel")
public func concordAndroidTitleActionLabel(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring {
    javaString((element(path, environment: environment) as? ConcordTitleActionElement)?.label ?? "", environment: environment)
}
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_titleActionImageKind")
public func concordAndroidTitleActionImageKind(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint {
    guard let image = (element(path, environment: environment) as? ConcordTitleActionElement)?.image else { return 0 }
    switch image { case .asset: return 1; case .icon: return 2 }
}
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_titleActionImageName")
public func concordAndroidTitleActionImageName(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring {
    guard let image = (element(path, environment: environment) as? ConcordTitleActionElement)?.image else {
        return javaString("", environment: environment)
    }
    switch image {
    case .asset(let name): return javaString(name, environment: environment)
    case .icon(let icon): return javaString(icon.rawValue, environment: environment)
    }
}
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_titleActionCount")
public func concordAndroidTitleActionCount(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint {
    jint((element(path, environment: environment) as? ConcordTitleActionElement)?.actionCount ?? 0)
}
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_titleActionTitle")
public func concordAndroidTitleActionTitle(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint) -> jstring {
    javaString((element(path, environment: environment) as? ConcordTitleActionElement)?.actionTitle(at: Int(index)) ?? "", environment: environment)
}
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_activateTitleAction")
public func concordAndroidActivateTitleAction(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint) {
    (element(path, environment: environment) as? ConcordTitleActionElement)?.activateAction(at: Int(index))
}

@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_actionGroupTitle")
public func concordAndroidActionGroupTitle(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring {
    let title = (element(path, environment: environment) as? ConcordActionGroupButton)?
        .resolvedTitle() ?? ""
    return javaString(title, environment: environment)
}
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_actionGroupImageKind")
public func concordAndroidActionGroupImageKind(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint {
    guard let image = (element(path, environment: environment) as? ConcordActionGroupButton)?.image else { return 0 }
    switch image { case .asset: return 1; case .icon: return 2 }
}
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_actionGroupImageName")
public func concordAndroidActionGroupImageName(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring {
    guard let image = (element(path, environment: environment) as? ConcordActionGroupButton)?.image else {
        return javaString("", environment: environment)
    }
    switch image {
    case .asset(let name): return javaString(name, environment: environment)
    case .icon(let icon): return javaString(icon.rawValue, environment: environment)
    }
}

@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_actionGroupCount")
public func concordAndroidActionGroupCount(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint {
    jint((element(path, environment: environment) as? ConcordActionGroupButton)?
        .resolvedActionGroup()?.actions.count ?? 0)
}
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_actionGroupItemTitle")
public func concordAndroidActionGroupItemTitle(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint) -> jstring {
    guard let actions = (element(path, environment: environment) as? ConcordActionGroupButton)?
        .resolvedActionGroup()?.actions,
        actions.indices.contains(Int(index)) else {
        return javaString("", environment: environment)
    }
    return javaString(actions[Int(index)].title, environment: environment)
}
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_activateActionGroupItem")
public func concordAndroidActivateActionGroupItem(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint) {
    guard let actions = (element(path, environment: environment) as? ConcordActionGroupButton)?
        .resolvedActionGroup()?.actions,
        actions.indices.contains(Int(index)) else { return }
    actions[Int(index)].invoke()
}

@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_childCount") public func concordAndroidChildCount(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { jint((element(path, environment: environment) as? ConcordContainer)?.elements.count ?? 0) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_containerEdge") public func concordAndroidContainerEdge(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { (element(path, environment: environment) as? ConcordContainer)?.edge ?? 0 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_containerSpacing") public func concordAndroidContainerSpacing(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { (element(path, environment: environment) as? ConcordContainer)?.spacing ?? ConcordContainer.defaultSpacing }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_workBottomHeight") public func concordAndroidWorkBottomHeight(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { (element(path, environment: environment) as? ConcordWorkStack)?.bottomHeight ?? ConcordWorkStack.defaultBottomHeight }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_justification") public func concordAndroidJustification(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { guard let value = element(path, environment: environment)?.horizontalJustification else { return 0 }; switch value { case .left: return 1; case .center: return 2; case .right: return 3 } }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_isVisible") public func concordAndroidIsVisible(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { element(path, environment: environment)?.isVisible == true ? 1 : 0 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_isEnabled") public func concordAndroidIsEnabled(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { element(path, environment: environment)?.isEnabled == true ? 1 : 0 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_isReadOnly") public func concordAndroidIsReadOnly(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { element(path, environment: environment)?.isReadOnly == true ? 1 : 0 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_isRequired") public func concordAndroidIsRequired(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { element(path, environment: environment)?.isRequired == true ? 1 : 0 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_validationState") public func concordAndroidValidationState(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { guard let value = element(path, environment: environment) as? any ConcordValidatable else { return 0 }; switch value.validationState { case .unvalidated: return 0; case .valid: return 1; case .invalid: return 2 } }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_requiredIndicator") public func concordAndroidRequiredIndicator(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { guard let value = element(path, environment: environment) else { return 0 }; switch value.requiredIndicator { case .none: return 0; case .redAsterisk: return 1; case .requiredText: return 2 } }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_invalidIndicator") public func concordAndroidInvalidIndicator(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { guard let value = element(path, environment: environment) else { return 0 }; switch value.invalidIndicator { case .none: return 0; case .errorText: return 1; case .redBorder: return 2; case .redBorderAndErrorText: return 3 } }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_helpText") public func concordAndroidHelpText(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString(element(path, environment: environment)?.helpText ?? "", environment: environment) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_errorText") public func concordAndroidErrorText(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString(element(path, environment: environment)?.errorText ?? "", environment: environment) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_isBold") public func concordAndroidIsBold(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { ((element(path, environment: environment) as? ConcordLabel)?.textStyle?.isBold == true || (element(path, environment: environment) as? ConcordExpander)?.labelIsBold == true) ? 1 : 0 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_isItalic") public func concordAndroidIsItalic(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { (element(path, environment: environment) as? ConcordLabel)?.textStyle?.isItalic == true ? 1 : 0 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_isUnderlined") public func concordAndroidIsUnderlined(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { (element(path, environment: environment) as? ConcordLabel)?.textStyle?.isUnderlined == true ? 1 : 0 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_fontKind") public func concordAndroidFontKind(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { guard let value = element(path, environment: environment) else { return 0 }; switch value.resolvedFont { case .system: return 1; case .monospaced: return 2 } }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_fontSize") public func concordAndroidFontSize(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { element(path, environment: environment)?.resolvedFontSize ?? 17 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_colorValue") public func concordAndroidColorValue(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, role: jint) -> jstring { javaString(colorString(color(element(path, environment: environment), role: role)), environment: environment) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_explicitColorValue") public func concordAndroidExplicitColorValue(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, role: jint) -> jstring { javaString(colorString(explicitColor(element(path, environment: environment), role: role)), environment: environment) }

private func sizeCode(_ rule: ConcordSizeRule?) -> jint { guard let rule else { return 0 }; switch rule { case .content: return 1; case .fixed: return 2; case .fill: return 3 } }
private func fixedSize(_ rule: ConcordSizeRule?) -> Double { if case .fixed(let value) = rule { return value }; return 0 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_widthRule") public func concordAndroidWidthRule(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { sizeCode(element(path, environment: environment)?.structure?.width) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_heightRule") public func concordAndroidHeightRule(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { sizeCode(element(path, environment: environment)?.structure?.height) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_fixedWidth") public func concordAndroidFixedWidth(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { fixedSize(element(path, environment: environment)?.structure?.width) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_fixedHeight") public func concordAndroidFixedHeight(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { fixedSize(element(path, environment: environment)?.structure?.height) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_boxWidth") public func concordAndroidBoxWidth(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { element(path, environment: environment)?.boxStyle?.width ?? 0 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_boxRadius") public func concordAndroidBoxRadius(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { element(path, environment: environment)?.boxStyle?.cornerRadius ?? 0 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_boxPadding") public func concordAndroidBoxPadding(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { element(path, environment: environment)?.boxStyle?.padding ?? 0 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_accessibilityText") public func concordAndroidAccessibilityText(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString(element(path, environment: environment)?.accessibilityText ?? "", environment: environment) }

@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_boolFlavor") public func concordAndroidBoolFlavor(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { guard let value = (element(path, environment: environment) as? ConcordBoolElement)?.flavor else { return 0 }; switch value { case .toggle: return 1; case .checkbox: return 2; case .radio: return 3 } }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_boolControlSide") public func concordAndroidBoolControlSide(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { guard let value = element(path, environment: environment) as? ConcordBoolElement, let onRight = value.isControlOnRight else { return 0 }; return onRight ? 2 : 1 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_boolState") public func concordAndroidBoolState(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { guard let value = (element(path, environment: environment) as? ConcordBoolElement)?.value else { return -1 }; return value ? 1 : 0 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_boolLabel") public func concordAndroidBoolLabel(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString((element(path, environment: environment) as? ConcordBoolElement)?.label ?? "", environment: environment) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_boolTrueName") public func concordAndroidBoolTrueName(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString((element(path, environment: environment) as? ConcordBoolElement)?.trueName ?? "True", environment: environment) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_boolFalseName") public func concordAndroidBoolFalseName(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString((element(path, environment: environment) as? ConcordBoolElement)?.falseName ?? "False", environment: environment) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_setBool") public func concordAndroidSetBool(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, value: jboolean) { (element(path, environment: environment) as? ConcordBoolElement)?.userChangedValue(to: value != 0) }

@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_textFlavor") public func concordAndroidTextFlavor(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { guard let value = (element(path, environment: environment) as? ConcordTextElement)?.flavor else { return 0 }; switch value { case .normal: return 1; case .password: return 2 } }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_textLabel") public func concordAndroidTextLabel(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString((element(path, environment: environment) as? ConcordTextElement)?.label ?? "", environment: environment) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_textPlaceholder") public func concordAndroidTextPlaceholder(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString((element(path, environment: environment) as? ConcordTextElement)?.placeholder ?? "", environment: environment) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_textValue") public func concordAndroidTextValue(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString((element(path, environment: environment) as? ConcordTextElement)?.value ?? "", environment: environment) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_setText") public func concordAndroidSetText(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, value: jstring) { (element(path, environment: environment) as? ConcordTextElement)?.userChangedValue(to: swiftString(value, environment: environment)) }

private func numericFlavorCode(_ value: ConcordNumericFlavor?) -> jint { guard let value else { return 0 }; switch value { case .input: return 1; case .stepper: return 2; case .slider: return 3; case .combo: return 4 } }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_intFlavor") public func concordAndroidIntFlavor(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { numericFlavorCode((element(path, environment: environment) as? ConcordIntElement)?.flavor) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_intLabel") public func concordAndroidIntLabel(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString((element(path, environment: environment) as? ConcordIntElement)?.label ?? "", environment: environment) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_intPlaceholder") public func concordAndroidIntPlaceholder(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString((element(path, environment: environment) as? ConcordIntElement)?.placeholder ?? "", environment: environment) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_intHasValue") public func concordAndroidIntHasValue(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { (element(path, environment: environment) as? ConcordIntElement)?.value == nil ? 0 : 1 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_intValue") public func concordAndroidIntValue(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jlong { jlong((element(path, environment: environment) as? ConcordIntElement)?.value ?? 0) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_intHasRange") public func concordAndroidIntHasRange(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { (element(path, environment: environment) as? ConcordIntElement)?.range == nil ? 0 : 1 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_intRangeLower") public func concordAndroidIntRangeLower(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jlong { jlong((element(path, environment: environment) as? ConcordIntElement)?.effectiveRange.lowerBound ?? 0) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_intRangeUpper") public func concordAndroidIntRangeUpper(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jlong { jlong((element(path, environment: environment) as? ConcordIntElement)?.effectiveRange.upperBound ?? 100) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_intStep") public func concordAndroidIntStep(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jlong { jlong((element(path, environment: environment) as? ConcordIntElement)?.step ?? 1) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_setInt") public func concordAndroidSetInt(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, value: jlong) { (element(path, environment: environment) as? ConcordIntElement)?.userChangedValue(to: ConcordInt(value)) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_clearInt") public func concordAndroidClearInt(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) { (element(path, environment: environment) as? ConcordIntElement)?.userChangedValue(to: nil) }

@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_floatFlavor") public func concordAndroidFloatFlavor(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { numericFlavorCode((element(path, environment: environment) as? ConcordFloatElement)?.flavor) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_floatLabel") public func concordAndroidFloatLabel(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString((element(path, environment: environment) as? ConcordFloatElement)?.label ?? "", environment: environment) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_floatPlaceholder") public func concordAndroidFloatPlaceholder(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString((element(path, environment: environment) as? ConcordFloatElement)?.placeholder ?? "", environment: environment) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_floatHasValue") public func concordAndroidFloatHasValue(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { (element(path, environment: environment) as? ConcordFloatElement)?.value == nil ? 0 : 1 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_floatValue") public func concordAndroidFloatValue(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { (element(path, environment: environment) as? ConcordFloatElement)?.value ?? 0 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_floatHasRange") public func concordAndroidFloatHasRange(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { (element(path, environment: environment) as? ConcordFloatElement)?.range == nil ? 0 : 1 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_floatRangeLower") public func concordAndroidFloatRangeLower(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { (element(path, environment: environment) as? ConcordFloatElement)?.effectiveRange.lowerBound ?? 0 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_floatRangeUpper") public func concordAndroidFloatRangeUpper(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { (element(path, environment: environment) as? ConcordFloatElement)?.effectiveRange.upperBound ?? 100 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_floatStep") public func concordAndroidFloatStep(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { (element(path, environment: environment) as? ConcordFloatElement)?.step ?? 1 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_setFloat") public func concordAndroidSetFloat(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, value: jdouble) { (element(path, environment: environment) as? ConcordFloatElement)?.userChangedValue(to: ConcordFloat(value)) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_clearFloat") public func concordAndroidClearFloat(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) { (element(path, environment: environment) as? ConcordFloatElement)?.userChangedValue(to: nil) }

private func dateElement(_ value: ConcordElement?) -> (flavor: jint, label: String, value: Date?, minimum: Date?, maximum: Date?)? {
    if let e = value as? ConcordDateElement { return (e.flavor == .components ? 2 : 1, e.label, e.value, e.minimumDate, e.maximumDate) }
    if let e = value as? ConcordTimeElement { return (e.flavor == .components ? 2 : 1, e.label, e.value, e.minimumDate, e.maximumDate) }
    if let e = value as? ConcordDateTimeElement { return (e.flavor == .components ? 2 : 1, e.label, e.value, e.minimumDate, e.maximumDate) }
    return nil
}
private func setDateElement(_ value: ConcordElement?, date: Date?) { if let e = value as? ConcordDateElement { e.userChangedValue(to: date) } else if let e = value as? ConcordTimeElement { e.userChangedValue(to: date) } else if let e = value as? ConcordDateTimeElement { e.userChangedValue(to: date) } }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_dateFlavor") public func concordAndroidDateFlavor(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { dateElement(element(path, environment: environment))?.flavor ?? 0 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_dateLabel") public func concordAndroidDateLabel(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString(dateElement(element(path, environment: environment))?.label ?? "", environment: environment) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_dateHasValue") public func concordAndroidDateHasValue(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { dateElement(element(path, environment: environment))?.value == nil ? 0 : 1 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_dateValue") public func concordAndroidDateValue(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { dateElement(element(path, environment: environment))?.value?.timeIntervalSince1970 ?? 0 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_dateMinimum") public func concordAndroidDateMinimum(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { dateElement(element(path, environment: environment))?.minimum?.timeIntervalSince1970 ?? Double.nan }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_dateMaximum") public func concordAndroidDateMaximum(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { dateElement(element(path, environment: environment))?.maximum?.timeIntervalSince1970 ?? Double.nan }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_setDateValue") public func concordAndroidSetDateValue(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, value: jdouble) { setDateElement(element(path, environment: environment), date: Date(timeIntervalSince1970: value)) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_clearDateValue") public func concordAndroidClearDateValue(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) { setDateElement(element(path, environment: environment), date: nil) }

@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_imageKind") public func concordAndroidImageKind(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { guard let image = element(path, environment: environment) as? ConcordImageElement else { return 0 }; switch image.source { case .asset: return 1; case .icon: return 2 } }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_imageName") public func concordAndroidImageName(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { guard let image = element(path, environment: environment) as? ConcordImageElement else { return javaString("", environment: environment) }; let name: String; switch image.source { case .asset(let value): name = value; case .icon(let icon): name = icon.rawValue }; return javaString(name, environment: environment) }
private func rasterElement(_ value: ConcordElement?) -> ConcordRasterElement? { value as? ConcordRasterElement }
private func rasterCommands(_ value: ConcordElement?, _ width: jdouble, _ height: jdouble) -> [ConcordRasterImageCommand] {
    guard let raster = rasterElement(value), width > 0, height > 0 else { return [] }
    return raster.imageCommands(in: ConcordSize(width: width, height: height))
}
private func rasterCommand(_ value: ConcordElement?, _ index: jint, _ width: jdouble, _ height: jdouble) -> ConcordRasterImageCommand? {
    let commands = rasterCommands(value, width, height)
    guard index >= 0, Int(index) < commands.count else { return nil }
    return commands[Int(index)]
}
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_rasterWidth") public func concordAndroidRasterWidth(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { rasterElement(element(path, environment: environment))?.coordinateSize.width ?? 1 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_rasterHeight") public func concordAndroidRasterHeight(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { rasterElement(element(path, environment: environment))?.coordinateSize.height ?? 1 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_rasterImageCount") public func concordAndroidRasterImageCount(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, width: jdouble, height: jdouble) -> jint { jint(rasterCommands(element(path, environment: environment), width, height).count) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_rasterImageKind") public func concordAndroidRasterImageKind(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint, width: jdouble, height: jdouble) -> jint { guard let command = rasterCommand(element(path, environment: environment), index, width, height) else { return 0 }; switch command.imageData { case .asset: return 1; case .icon: return 2 } }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_rasterImageName") public func concordAndroidRasterImageName(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint, width: jdouble, height: jdouble) -> jstring { guard let command = rasterCommand(element(path, environment: environment), index, width, height) else { return javaString("", environment: environment) }; let name: String; switch command.imageData { case .asset(let value): name = value; case .icon(let icon): name = icon.rawValue }; return javaString(name, environment: environment) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_rasterImageX") public func concordAndroidRasterImageX(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint, width: jdouble, height: jdouble) -> jdouble { rasterCommand(element(path, environment: environment), index, width, height)?.rect.origin.x ?? 0 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_rasterImageY") public func concordAndroidRasterImageY(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint, width: jdouble, height: jdouble) -> jdouble { rasterCommand(element(path, environment: environment), index, width, height)?.rect.origin.y ?? 0 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_rasterImageWidth") public func concordAndroidRasterImageWidth(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint, width: jdouble, height: jdouble) -> jdouble { rasterCommand(element(path, environment: environment), index, width, height)?.rect.size.width ?? 0 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_rasterImageHeight") public func concordAndroidRasterImageHeight(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint, width: jdouble, height: jdouble) -> jdouble { rasterCommand(element(path, environment: environment), index, width, height)?.rect.size.height ?? 0 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_rasterImageZOrder") public func concordAndroidRasterImageZOrder(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint, width: jdouble, height: jdouble) -> jint { jint(rasterCommand(element(path, environment: environment), index, width, height)?.zOrder ?? 0) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_rasterImageContentMode") public func concordAndroidRasterImageContentMode(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint, width: jdouble, height: jdouble) -> jint { guard let mode = rasterCommand(element(path, environment: environment), index, width, height)?.contentMode else { return 1 }; switch mode { case .fit: return 1; case .fill: return 2; case .stretch: return 3; case .original: return 4 } }

@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_progressFlavor") public func concordAndroidProgressFlavor(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { guard let progress = element(path, environment: environment) as? ConcordProgressElement else { return 0 }; return progress.flavor == .spinner ? 2 : 1 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_progressLabel") public func concordAndroidProgressLabel(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString((element(path, environment: environment) as? ConcordProgressElement)?.label ?? "", environment: environment) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_progressValue") public func concordAndroidProgressValue(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { (element(path, environment: environment) as? ConcordProgressElement)?.value ?? 0 }

private func selectionElement(_ value: ConcordElement?) -> (any ConcordSelectionPresenting)? { value as? any ConcordSelectionPresenting }
private func selectionFlavorCode(_ flavor: ConcordSelectionFlavor) -> jint { switch flavor { case .popup: return 1; case .spinner: return 2; case .radio: return 3; case .segmented: return 4; case .list: return 5 } }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_selectionFlavor") public func concordAndroidSelectionFlavor(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { guard let selection = selectionElement(element(path, environment: environment)) else { return 0 }; return selectionFlavorCode(selection.flavor) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_selectionLabel") public func concordAndroidSelectionLabel(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString(selectionElement(element(path, environment: environment))?.label ?? "", environment: environment) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_selectionCount") public func concordAndroidSelectionCount(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { jint(selectionElement(element(path, environment: environment))?.itemCount ?? 0) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_selectionIndex") public func concordAndroidSelectionIndex(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { jint(selectionElement(element(path, environment: environment))?.selectedIndex ?? -1) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_selectionItemText") public func concordAndroidSelectionItemText(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint) -> jstring { guard let selection = selectionElement(element(path, environment: environment)) else { return javaString("", environment: environment) }; return javaString(selection.displayText(at: Int(index)), environment: environment) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_setSelectionIndex") public func concordAndroidSetSelectionIndex(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint) { selectionElement(element(path, environment: environment))?.userSelected(index: Int(index)) }

@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_expanderFlavor") public func concordAndroidExpanderFlavor(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { guard let expander = element(path, environment: environment) as? ConcordExpander else { return 0 }; return expander.flavor == .checkbox ? 2 : 1 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_expanderLabel") public func concordAndroidExpanderLabel(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString((element(path, environment: environment) as? ConcordExpander)?.label ?? "", environment: environment) }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_expanderExpanded") public func concordAndroidExpanderExpanded(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { (element(path, environment: environment) as? ConcordExpander)?.isExpanded == true ? 1 : 0 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_expanderOnRight") public func concordAndroidExpanderOnRight(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { (element(path, environment: environment) as? ConcordExpander)?.onRight == true ? 1 : 0 }
@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_toggleExpander") public func concordAndroidToggleExpander(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) { (element(path, environment: environment) as? ConcordExpander)?.toggleExpanded() }

@_cdecl("Java_com_zodiacinnovations_helloconcordui_ConcordNative_activate") public func concordAndroidActivate(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) { (element(path, environment: environment) as? ConcordButton)?.activate() }