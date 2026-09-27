import Android
import ConcordUI
import Foundation

nonisolated(unsafe) private var concordAndroidPlatformJNIEnvironment: UnsafeMutablePointer<JNIEnv?>?

@_cdecl("Java_com_zodiacinnovations_elementshowcase_ConcordNative_setPlatformEnvironment")
public func concordAndroidSetPlatformEnvironment(
    environment: UnsafeMutablePointer<JNIEnv?>,
    receiver: jobject
) {
    concordAndroidPlatformJNIEnvironment = environment
}

extension ConcordAndroidPlatform {
    private func platformInformation(_ method: String) -> String? {
        callPlatformString(
            className: "com/zodiacinnovations/elementshowcase/ConcordPlatformInformation",
            method: method,
            strings: []
        )
    }

    var appName: String { platformInformation("appName") ?? "Application" }
    var appIdentifier: String { platformInformation("appIdentifier") ?? "" }
    var appCopyright: String? { platformInformation("appCopyright") }
    var appVersion: String { platformInformation("appVersion") ?? "0.0" }
    var appBuild: String { platformInformation("appBuild") ?? "0" }
    var platformName: String { platformInformation("platformName") ?? "Android" }
    var platformVersion: String { platformInformation("platformVersion") ?? "Unknown" }
    var platformAPILevel: Int? { platformInformation("platformAPILevel").flatMap(Int.init) }
    var deviceModel: String { platformInformation("deviceModel") ?? "Unknown" }
    var deviceManufacturer: String { platformInformation("deviceManufacturer") ?? "Unknown" }
    var localeIdentifier: String { platformInformation("localeIdentifier") ?? "Unknown" }
    var languageCode: String { platformInformation("languageCode") ?? "Unknown" }
    var timeZoneIdentifier: String { platformInformation("timeZoneIdentifier") ?? "Unknown" }
    var appearanceMode: String { platformInformation("appearanceMode") ?? "Unknown" }
    var deviceClass: String { platformInformation("deviceClass") ?? "Unknown" }
    var platformType: ConcordPlatformType {
        ConcordPlatformType(rawValue: platformInformation("platformType") ?? "") ?? .unknown
    }
    var deviceType: ConcordDeviceType {
        ConcordDeviceType(rawValue: platformInformation("deviceType") ?? "") ?? .unknown
    }
    var orientation: ConcordOrientation {
        ConcordOrientation(rawValue: platformInformation("orientation") ?? "") ?? .none
    }

    @discardableResult
    func setSecureData(_ data: Data, forKey key: String) -> Bool {
        callPlatformBoolean(
            className: "com/zodiacinnovations/elementshowcase/ConcordSecureStorage",
            method: "set",
            strings: [key, data.base64EncodedString()]
        )
    }

    func secureData(forKey key: String) -> Data? {
        guard let encoded = callPlatformString(
            className: "com/zodiacinnovations/elementshowcase/ConcordSecureStorage",
            method: "get",
            strings: [key]
        ), !encoded.isEmpty else { return nil }
        return Data(base64Encoded: encoded)
    }

    @discardableResult
    func removeSecureValue(forKey key: String) -> Bool {
        callPlatformBoolean(
            className: "com/zodiacinnovations/elementshowcase/ConcordSecureStorage",
            method: "remove",
            strings: [key]
        )
    }

    func resourceExists(name: String, type: ConcordResourceType) -> Bool {
        callPlatformBoolean(
            className: "com/zodiacinnovations/elementshowcase/ConcordResourceManager",
            method: "exists",
            strings: [name, resourceTypeIdentifier(type)]
        )
    }

    func resourceRetrieve(name: String, type: ConcordResourceType) -> Data? {
        guard let encoded = callPlatformString(
            className: "com/zodiacinnovations/elementshowcase/ConcordResourceManager",
            method: "retrieve",
            strings: [name, resourceTypeIdentifier(type)]
        ), !encoded.isEmpty else { return nil }
        return Data(base64Encoded: encoded)
    }

    @discardableResult
    func resourceOpen(name: String, type: ConcordResourceType) -> Bool {
        callPlatformBoolean(
            className: "com/zodiacinnovations/elementshowcase/ConcordResourceManager",
            method: "open",
            strings: [name, resourceTypeIdentifier(type)]
        )
    }

    private func resourceTypeIdentifier(_ type: ConcordResourceType) -> String {
        switch type {
        case .text: return "text"
        case .pdf: return "pdf"
        case .image: return "image"
        case .custom(let value): return "custom:\(value)"
        }
    }

    func canLaunchURL(_ url: URL) -> Bool {
        callActionBoolean(method: "canLaunch", strings: [url.absoluteString])
    }

    @discardableResult
    func launchURL(_ url: URL) -> Bool {
        callActionBoolean(method: "launch", strings: [url.absoluteString])
    }

    var canComposeEmail: Bool {
        callActionBoolean(method: "canLaunch", strings: ["mailto:concordui@example.com"])
    }

    @discardableResult
    func composeEmail(to: [String], subject: String?, body: String?) -> Bool {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = to.joined(separator: ",")
        var items: [URLQueryItem] = []
        if let subject, !subject.isEmpty { items.append(URLQueryItem(name: "subject", value: subject)) }
        if let body, !body.isEmpty { items.append(URLQueryItem(name: "body", value: body)) }
        components.queryItems = items.isEmpty ? nil : items
        guard let value = components.string else { return false }
        return callActionBoolean(method: "launch", strings: [value])
    }

    var canComposeMessage: Bool {
        callActionBoolean(method: "canLaunch", strings: ["sms:5555555555"])
    }

    @discardableResult
    func composeMessage(to: [String], body: String?) -> Bool {
        var components = URLComponents()
        components.scheme = "sms"
        components.path = to.joined(separator: ",")
        if let body, !body.isEmpty {
            components.queryItems = [URLQueryItem(name: "body", value: body)]
        }
        guard let value = components.string else { return false }
        return callActionBoolean(method: "launch", strings: [value])
    }

    var canDialPhone: Bool {
        callActionBoolean(method: "canLaunch", strings: ["tel:5555555555"])
    }

    @discardableResult
    func dialPhone(_ number: String) -> Bool {
        let normalized = number.filter { $0.isNumber || $0 == "+" || $0 == "*" || $0 == "#" }
        guard !normalized.isEmpty else { return false }
        return callActionBoolean(method: "launch", strings: ["tel:\(normalized)"])
    }

    var canOpenMap: Bool {
        callActionBoolean(method: "canLaunch", strings: ["geo:0,0?q=ConcordUI"])
    }

    @discardableResult
    func openMap(latitude: Double, longitude: Double, label: String?) -> Bool {
        let coordinate = "\(latitude),\(longitude)"
        let query = label?.isEmpty == false ? "\(coordinate)(\(label!))" : coordinate
        return callActionBoolean(method: "launch", strings: ["geo:\(coordinate)?q=\(encoded(query))"])
    }

    @discardableResult
    func openMap(address: String) -> Bool {
        callActionBoolean(method: "launch", strings: ["geo:0,0?q=\(encoded(address))"])
    }

    @discardableResult
    func searchMap(_ query: String) -> Bool {
        callActionBoolean(method: "launch", strings: ["geo:0,0?q=\(encoded(query))"])
    }

    var canOpenDirections: Bool {
        callActionBoolean(method: "canLaunch", strings: ["google.navigation:q=0,0"])
    }

    @discardableResult
    func openDirections(toLatitude latitude: Double, longitude: Double, label: String?) -> Bool {
        callActionBoolean(method: "launch", strings: ["google.navigation:q=\(latitude),\(longitude)"])
    }

    @discardableResult
    func openDirections(toAddress address: String) -> Bool {
        callActionBoolean(method: "launch", strings: ["google.navigation:q=\(encoded(address))"])
    }

    var canOpenApplicationSettings: Bool {
        callActionBoolean(method: "canOpenSettings", strings: [])
    }

    @discardableResult
    func openApplicationSettings() -> Bool {
        callActionBoolean(method: "openSettings", strings: [])
    }

    private func encoded(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
    }

    private func callActionBoolean(method: String, strings: [String]) -> Bool {
        callPlatformBoolean(
            className: "com/zodiacinnovations/elementshowcase/ConcordPlatformActions",
            method: method,
            strings: strings
        )
    }

    private func callPlatformBoolean(className: String, method: String, strings: [String]) -> Bool {
        guard let environment = concordAndroidPlatformJNIEnvironment,
              let functions = environment.pointee?.pointee else { return false }
        let clazz = className.withCString { functions.FindClass(environment, $0) }
        guard let clazz else { return false }
        defer { functions.DeleteLocalRef(environment, clazz) }

        let signature = "(" + String(repeating: "Ljava/lang/String;", count: strings.count) + ")Z"
        let methodID = method.withCString { methodName in
            signature.withCString { methodSignature in
                functions.GetStaticMethodID(environment, clazz, methodName, methodSignature)
            }
        }
        guard let methodID else { return false }

        let localStrings: [jstring] = strings.map { value in
            value.withCString { functions.NewStringUTF(environment, $0)! }
        }
        defer { for value in localStrings { functions.DeleteLocalRef(environment, value) } }
        var arguments = localStrings.map { value -> jvalue in
            var argument = jvalue(); argument.l = value; return argument
        }
        let result: jboolean = arguments.withUnsafeMutableBufferPointer { buffer in
            functions.CallStaticBooleanMethodA(environment, clazz, methodID, buffer.baseAddress)
        }
        return result != 0
    }

    private func callPlatformString(className: String, method: String, strings: [String]) -> String? {
        guard let environment = concordAndroidPlatformJNIEnvironment,
              let functions = environment.pointee?.pointee else { return nil }
        let clazz = className.withCString { functions.FindClass(environment, $0) }
        guard let clazz else { return nil }
        defer { functions.DeleteLocalRef(environment, clazz) }

        let signature = "(" + String(repeating: "Ljava/lang/String;", count: strings.count) + ")Ljava/lang/String;"
        let methodID = method.withCString { methodName in
            signature.withCString { methodSignature in
                functions.GetStaticMethodID(environment, clazz, methodName, methodSignature)
            }
        }
        guard let methodID else { return nil }

        let localStrings: [jstring] = strings.map { value in
            value.withCString { functions.NewStringUTF(environment, $0)! }
        }
        defer { for value in localStrings { functions.DeleteLocalRef(environment, value) } }
        var arguments = localStrings.map { value -> jvalue in
            var argument = jvalue(); argument.l = value; return argument
        }
        guard let object = arguments.withUnsafeMutableBufferPointer({ buffer in
            functions.CallStaticObjectMethodA(environment, clazz, methodID, buffer.baseAddress)
        }) else { return nil }
        defer { functions.DeleteLocalRef(environment, object) }

        let value = unsafeBitCast(object, to: jstring.self)
        guard let chars = functions.GetStringUTFChars(environment, value, nil) else { return nil }
        defer { functions.ReleaseStringUTFChars(environment, value, chars) }
        return String(cString: chars)
    }
}

extension ConcordAndroidPlatform: ConcordPlatformFileSupport {
    var canRetrieveResources: Bool { true }
    var canOpenResources: Bool { true }
    var canShareResources: Bool {
        callPlatformBoolean(
            className: "com/zodiacinnovations/elementshowcase/ConcordResourceManager",
            method: "canShare",
            strings: []
        )
    }

    @discardableResult
    func resourceShare(name: String, type: ConcordResourceType) -> Bool {
        callPlatformBoolean(
            className: "com/zodiacinnovations/elementshowcase/ConcordResourceManager",
            method: "share",
            strings: [name, resourceTypeIdentifier(type)]
        )
    }

    @discardableResult
    func shareTextContent(_ text: String) -> Bool {
        callPlatformBoolean(
            className: "com/zodiacinnovations/elementshowcase/ConcordResourceManager",
            method: "shareText",
            strings: [text]
        )
    }

    @discardableResult
    func shareDataContent(_ data: Data, filename: String, mimeType: String) -> Bool {
        callPlatformBoolean(
            className: "com/zodiacinnovations/elementshowcase/ConcordResourceManager",
            method: "shareData",
            strings: [data.base64EncodedString(), filename, mimeType]
        )
    }
}

extension ConcordAndroidPlatform: ConcordPlatformPrintSupport {
    var canPrintTextContent: Bool {
        callPlatformBoolean(
            className: "com/zodiacinnovations/elementshowcase/ConcordPrintManager",
            method: "canPrint",
            strings: []
        )
    }

    var canPrintImageContent: Bool { canPrintTextContent }

    @discardableResult
    func printTextContent(_ text: String, font: ConcordFont) -> Bool {
        let fontName: String
        switch font {
        case .system: fontName = "system"
        case .monospaced: fontName = "monospaced"
        }
        return callPlatformBoolean(
            className: "com/zodiacinnovations/elementshowcase/ConcordPrintManager",
            method: "printText",
            strings: [text, fontName]
        )
    }

    @discardableResult
    func printImageContent(_ image: ConcordBitmapImage, size: Bool) -> Bool {
        callPlatformBoolean(
            className: "com/zodiacinnovations/elementshowcase/ConcordPrintManager",
            method: "printImage",
            strings: [image.data.base64EncodedString(), size ? "true" : "false"]
        )
    }
}

nonisolated(unsafe) private var concordAndroidSoundCompletion: ConcordPlaybackCompletion?
nonisolated(unsafe) private var concordAndroidSpeechCompletion: ConcordPlaybackCompletion?

@_cdecl("Java_com_zodiacinnovations_elementshowcase_ConcordAudioNative_audioDidFinish")
public func concordAndroidAudioDidFinish(
    environment: UnsafeMutablePointer<JNIEnv?>,
    receiver: jobject,
    kindValue: jstring,
    resultValue: jstring
) {
    guard let functions = environment.pointee?.pointee else { return }

    func swiftString(_ value: jstring) -> String? {
        guard let chars = functions.GetStringUTFChars(environment, value, nil) else { return nil }
        defer { functions.ReleaseStringUTFChars(environment, value, chars) }
        return String(cString: chars)
    }

    guard let kind = swiftString(kindValue), let resultName = swiftString(resultValue) else { return }
    let result: ConcordPlaybackResult
    switch resultName {
    case "finished": result = .finished
    case "cancelled": result = .cancelled
    default: result = .failed
    }

    let completion: ConcordPlaybackCompletion?
    if kind == "sound" {
        completion = concordAndroidSoundCompletion
        concordAndroidSoundCompletion = nil
    } else {
        completion = concordAndroidSpeechCompletion
        concordAndroidSpeechCompletion = nil
    }
    completion?(result)
}

extension ConcordAndroidPlatform: ConcordPlatformAudioSupport {
    var canPlaySoundContent: Bool {
        callPlatformBoolean(
            className: "com/zodiacinnovations/elementshowcase/ConcordAudioManager",
            method: "canPlaySound",
            strings: []
        )
    }

    var canSpeakTextContent: Bool {
        callPlatformBoolean(
            className: "com/zodiacinnovations/elementshowcase/ConcordAudioManager",
            method: "canSpeakText",
            strings: []
        )
    }

    @discardableResult
    func playSoundContent(
        _ data: Data,
        fileExtension: String,
        speed: ConcordFloat,
        completion: @escaping ConcordPlaybackCompletion
    ) -> Bool {
        cancelSoundContent()
        concordAndroidSoundCompletion = completion
        let started = callPlatformBoolean(
            className: "com/zodiacinnovations/elementshowcase/ConcordAudioManager",
            method: "playSound",
            strings: [data.base64EncodedString(), fileExtension, String(speed)]
        )
        if !started {
            concordAndroidSoundCompletion = nil
            completion(.failed)
        }
        return started
    }

    func cancelSoundContent() {
        _ = callPlatformBoolean(
            className: "com/zodiacinnovations/elementshowcase/ConcordAudioManager",
            method: "cancelSound",
            strings: []
        )
    }

    @discardableResult
    func speakTextContent(
        _ text: String,
        speed: ConcordFloat,
        completion: @escaping ConcordPlaybackCompletion
    ) -> Bool {
        cancelSpeechContent()
        concordAndroidSpeechCompletion = completion
        let started = callPlatformBoolean(
            className: "com/zodiacinnovations/elementshowcase/ConcordAudioManager",
            method: "speakText",
            strings: [text, String(speed)]
        )
        if !started {
            concordAndroidSpeechCompletion = nil
            completion(.failed)
        }
        return started
    }

    func cancelSpeechContent() {
        _ = callPlatformBoolean(
            className: "com/zodiacinnovations/elementshowcase/ConcordAudioManager",
            method: "cancelSpeech",
            strings: []
        )
    }
}

nonisolated(unsafe) private var concordAndroidBannerJNIEnvironment: UnsafeMutablePointer<JNIEnv?>?
nonisolated(unsafe) private var concordAndroidBannerCompletion: ConcordBannerCompletion?

@_cdecl("Java_com_zodiacinnovations_elementshowcase_ConcordNative_setBannerEnvironment")
public func concordAndroidSetBannerEnvironment(
    environment: UnsafeMutablePointer<JNIEnv?>,
    receiver: jobject
) {
    concordAndroidBannerJNIEnvironment = environment
}

@_cdecl("Java_com_zodiacinnovations_elementshowcase_ConcordNative_bannerDidDismiss")
public func concordAndroidBannerDidDismiss(
    environment: UnsafeMutablePointer<JNIEnv?>,
    receiver: jobject
) {
    let completion = concordAndroidBannerCompletion
    concordAndroidBannerCompletion = nil
    completion?()
}

extension ConcordAndroidPlatform: ConcordPlatformBannerSupport {
    var canDisplayBanner: Bool {
        callBannerBoolean(method: "canDisplayBanner", strings: [])
    }

    @discardableResult
    func banner(_ text: String, completion: @escaping ConcordBannerCompletion) -> Bool {
        let previous = concordAndroidBannerCompletion
        concordAndroidBannerCompletion = nil
        previous?()

        concordAndroidBannerCompletion = completion
        let started = callBannerBoolean(method: "banner", strings: [text])
        if !started { concordAndroidBannerCompletion = nil }
        return started
    }

    private func callBannerBoolean(method: String, strings: [String]) -> Bool {
        guard let environment = concordAndroidBannerJNIEnvironment,
              let functions = environment.pointee?.pointee else { return false }
        let className = "com/zodiacinnovations/elementshowcase/ConcordBannerManager"
        let clazz = className.withCString { functions.FindClass(environment, $0) }
        guard let clazz else { return false }
        defer { functions.DeleteLocalRef(environment, clazz) }

        let signature = "(" + String(repeating: "Ljava/lang/String;", count: strings.count) + ")Z"
        let methodID = method.withCString { methodName in
            signature.withCString { methodSignature in
                functions.GetStaticMethodID(environment, clazz, methodName, methodSignature)
            }
        }
        guard let methodID else { return false }

        let localStrings: [jstring] = strings.map { value in
            value.withCString { functions.NewStringUTF(environment, $0)! }
        }
        defer { for value in localStrings { functions.DeleteLocalRef(environment, value) } }
        var arguments = localStrings.map { value -> jvalue in
            var argument = jvalue(); argument.l = value; return argument
        }
        let result: jboolean = arguments.withUnsafeMutableBufferPointer { buffer in
            functions.CallStaticBooleanMethodA(environment, clazz, methodID, buffer.baseAddress)
        }
        return result != 0
    }
}