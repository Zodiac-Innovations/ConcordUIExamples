//
//  PlatformShowcaseApplication.swift
//  ConcordUI Platform Showcase
//
//  Created by Steve Sheets on 8/20/26.
//
//  Shared application code for demonstrating ConcordUI Platform features.
//

import Foundation
import ConcordUI

private final class PlaybackStatusUI: @unchecked Sendable {
    let label: ConcordLabel
    let cancelButton: ConcordButton

    init(label: ConcordLabel, cancelButton: ConcordButton) {
        self.label = label
        self.cancelButton = cancelButton
    }

    func set(_ status: String, playing: Bool) {
        label.text = "Status: \(status)"
        cancelButton.isEnabled = playing
    }

    func set(_ result: ConcordPlaybackResult) {
        switch result {
        case .finished:
            set("Finished", playing: false)
        case .cancelled:
            set("Cancelled", playing: false)
        case .failed:
            set("Failed", playing: false)
        }
    }
}

nonisolated public final class PlatformShowcaseApplication: ConcordApplication {
    private var homePresentation: ConcordPresentation?
    private var informationPresentation: ConcordPresentation?
    private var functionPresentation: ConcordPresentation?
    private var audioSpeechPresentation: ConcordPresentation?
    private var storagePresentation: ConcordPresentation?
    private var embeddedDataPresentation: ConcordPresentation?
    private var elementsPresentation: ConcordPresentation?

    private var selectedDate: Date? = Date()
    private var persistentStorageResult = "No permanent-storage operation performed yet."
    private var secureStorageResult = "No encrypted-storage operation performed yet."
    private let persistentStorageDemoKey = "PlatformShowcase-PermanentStorage"
    private let secureStorageDemoKey = "PlatformShowcase-SecureStorage"

    public init(platform: any ConcordPlatform) {
        super.init(platform: platform, theme: ConcordTheme(frameColor: .secondary))
    }

    private func makeHome() -> ConcordButton {
        ConcordButton("Home") {
            guard let homePresentation = self.homePresentation else { return }
            self.displayMainPresentation(homePresentation)
        }
        .centerJustified()
    }

    private func platformButton(_ text: String, _ presentation: ConcordPresentation?) -> ConcordButton {
        ConcordButton(text) {
            guard let presentation else { return }
            self.displayMainPresentation(presentation)
        }
        .centerJustified()
    }

    private func refreshStorage() {
        guard let storagePresentation else { return }
        displayMainPresentation(storagePresentation)
    }

    public override func startApplication() {
        informationPresentation = ConcordPresentation {
            ConcordVStack([
                ConcordLabel("Platform Information").bold().centerJustified(),
                ConcordLabel("Information provided by the current platform and application environment.").italic(),
                ConcordDivider(),
                ConcordVStack([
                    ConcordLabel("Application: \(self.platform.appName)"),
                    ConcordLabel("Identifier: \(self.platform.appIdentifier)"),
                    ConcordLabel("Version: \(self.platform.appVersion)"),
                    ConcordLabel("Build: \(self.platform.appBuild)"),
                    ConcordLabel("Copyright: \(self.platform.appCopyright ?? "Not provided")")
                ]).boxed(),
                ConcordVStack([
                    ConcordLabel("First Launch: \(self.isFirstTimeLaunch)"),
                    ConcordLabel("First Launch of Version: \(self.isFirstTimeNewVersion)"),
                    ConcordLabel("Launch Count: \(self.numberLaunches)")
                ]).boxed(),
                ConcordVStack([
                    ConcordLabel("Platform: \(self.platform.platformName)"),
                    ConcordLabel("Platform Type: \(self.platform.platformType.rawValue)"),
                    ConcordLabel("Platform Version: \(self.platform.platformVersion)"),
                    ConcordLabel("API Level: \(self.platform.platformAPILevel.map(String.init) ?? "Not applicable")")
                ]).boxed(),
                ConcordVStack([
                    ConcordLabel("Device Model: \(self.platform.deviceModel)"),
                    ConcordLabel("Manufacturer: \(self.platform.deviceManufacturer)"),
                    ConcordLabel("Device Class: \(self.platform.deviceClass)"),
                    ConcordLabel("Device Type: \(self.platform.deviceType.rawValue)"),
                    ConcordLabel("Orientation: \(self.platform.orientation.rawValue)"),
                    ConcordLabel("Appearance: \(self.platform.appearanceMode)")
                ]).boxed(),
                ConcordVStack([
                    ConcordLabel("Locale: \(self.platform.localeIdentifier)"),
                    ConcordLabel("Language: \(self.platform.languageCode)"),
                    ConcordLabel("Time Zone: \(self.platform.timeZoneIdentifier)")
                ]).boxed(),
                ConcordSpacer(), self.makeHome()
            ])
        }

        var functionElements: [ConcordElement] = [
            ConcordLabel("Platform Functions").bold().centerJustified(),
            ConcordLabel("Functions performed by the native platform or ConcordUI application environment.").italic(),
            ConcordDivider()
        ]

        if let url = URL(string: "https://concordui.org"), platform.canLaunchURL(url) {
            functionElements.append(ConcordButton("Launch ConcordUI Website") {
                self.platform.launchURL(url)
            }.centerJustified())
        }
        if platform.canComposeEmail {
            functionElements.append(ConcordButton("Compose Email") {
                self.platform.composeEmail(to: ["test@example.com"], subject: "ConcordUI", body: "Sent from Platform Showcase")
            }.centerJustified())
        }
        if platform.canComposeMessage {
            functionElements.append(ConcordButton("Compose Message") {
                self.platform.composeMessage(to: ["8005550100"], body: "ConcordUI Platform Showcase")
            }.centerJustified())
        }
        if platform.canDialPhone {
            functionElements.append(ConcordButton("Dial Phone") {
                self.platform.dialPhone("8005550100")
            }.centerJustified())
        }
        if platform.canOpenMap {
            functionElements.append(ConcordButton("Open Map") {
                self.platform.openMap(latitude: 37.3349, longitude: -122.0090, label: "Apple Park")
            }.centerJustified())
            functionElements.append(ConcordButton("Search Map") {
                self.platform.searchMap("coffee")
            }.centerJustified())
        }
        if platform.canOpenDirections {
            functionElements.append(ConcordButton("Open Directions") {
                self.platform.openDirections(toAddress: "1 Apple Park Way, Cupertino, CA")
            }.centerJustified())
        }
        if platform.canOpenApplicationSettings {
            functionElements.append(ConcordButton("Open Application Settings") {
                self.platform.openApplicationSettings()
            }.centerJustified())
        }
        if platform.canPrintText {
            functionElements.append(ConcordButton("Print Text") {
                self.platform.printText("ConcordUI Platform Showcase\nNative text printing demonstration.")
            }.centerJustified())
            functionElements.append(ConcordButton("Print Text File") {
                self.platform.printFileText("PlatformResource.txt", font: .monospaced)
            }.centerJustified())
        }
        if platform.canPrintImage && platform.canRetrieveBitmap {
            functionElements.append(ConcordButton("Print Image") {
                guard let image = self.platform.retrieveBitmapFile("PlatformPrint.png") else { return }
                self.platform.printImage(image)
            }.centerJustified())
            functionElements.append(ConcordButton("Print Image File") {
                self.platform.printFileImage("PlatformPrint.png")
            }.centerJustified())
        }
        functionElements.append(ConcordSpacer())
        functionElements.append(makeHome())
        functionPresentation = ConcordPresentation { ConcordVStack(functionElements) }

        var audioSpeechElements: [ConcordElement] = [
            ConcordLabel("Audio and Speech").bold().centerJustified(),
            ConcordLabel("Native sound playback and text-to-speech services.").italic(),
            ConcordDivider()
        ]

        if platform.canPlaySound {
            let statusLabel = ConcordLabel("Status: Not Playing").italic().centerJustified()
            let cancelButton = ConcordButton("Cancel Sound") {
                self.platform.cancelSound()
            }.centerJustified()
            cancelButton.isEnabled = false
            let status = PlaybackStatusUI(label: statusLabel, cancelButton: cancelButton)

            let playFile = ConcordButton("Play scream.mp3") {
                status.set("Playing", playing: true)
                let started = self.platform.playSoundFile("scream.mp3") { result in
                    status.set(result)
                }
                if !started { status.set("Failed", playing: false) }
            }.centerJustified()

            let playFast = ConcordButton("Play scream.mp3 — 1.5x") {
                status.set("Playing", playing: true)
                let started = self.platform.playSoundFile("scream.mp3", speed: 1.5) { result in
                    status.set(result)
                }
                if !started { status.set("Failed", playing: false) }
            }.centerJustified()

            let playMemory = ConcordButton("Play scream.mp3 from Memory") {
                guard let data = self.platform.retrieveDataFile("scream.mp3") else {
                    status.set("Failed", playing: false)
                    return
                }
                status.set("Playing", playing: true)
                let started = self.platform.playSound(data, fileExtension: "mp3") { result in
                    status.set(result)
                }
                if !started { status.set("Failed", playing: false) }
            }.centerJustified()

            cancelButton.onAction(.buttonActivate) { _ in
                status.set("Cancelled", playing: false)
                self.platform.cancelSound()
            }

            audioSpeechElements.append(ConcordVStack([
                ConcordLabel("Sound Playback").bold().centerJustified(),
                statusLabel,
                playFile,
                playFast,
                playMemory,
                cancelButton
            ]).boxed())
        }

        if platform.canSpeakText {
            let statusLabel = ConcordLabel("Status: Not Playing").italic().centerJustified()
            let cancelButton = ConcordButton("Cancel Speech") {
                self.platform.cancelSpeech()
            }.centerJustified()
            cancelButton.isEnabled = false
            let status = PlaybackStatusUI(label: statusLabel, cancelButton: cancelButton)

            let speakNormal = ConcordButton("Speak Text") {
                status.set("Playing", playing: true)
                let started = self.platform.speakText("Concord U I can speak using the native platform voice.") { result in
                    status.set(result)
                }
                if !started { status.set("Failed", playing: false) }
            }.centerJustified()

            let speakSlow = ConcordButton("Speak Text — 0.75x") {
                status.set("Playing", playing: true)
                let started = self.platform.speakText("This sentence is spoken more slowly than normal.", speed: 0.75) { result in
                    status.set(result)
                }
                if !started { status.set("Failed", playing: false) }
            }.centerJustified()

            let speakFast = ConcordButton("Speak Text — 1.5x") {
                status.set("Playing", playing: true)
                let started = self.platform.speakText("This sentence is spoken at one point five times normal speed.", speed: 1.5) { result in
                    status.set(result)
                }
                if !started { status.set("Failed", playing: false) }
            }.centerJustified()

            cancelButton.onAction(.buttonActivate) { _ in
                status.set("Cancelled", playing: false)
                self.platform.cancelSpeech()
            }

            audioSpeechElements.append(ConcordVStack([
                ConcordLabel("Text to Voice").bold().centerJustified(),
                statusLabel,
                speakNormal,
                speakSlow,
                speakFast,
                cancelButton
            ]).boxed())
        }

        audioSpeechElements.append(ConcordSpacer())
        audioSpeechElements.append(makeHome())
        audioSpeechPresentation = ConcordPresentation { ConcordVStack(audioSpeechElements) }

        storagePresentation = ConcordPresentation {
            ConcordVStack([
                ConcordLabel("Platform Storage").bold().centerJustified(),
                ConcordLabel("Permanent and encrypted key/value storage provided through the ConcordUI platform abstraction.").italic(),
                ConcordDivider(),
                ConcordVStack([
                    ConcordLabel("Permanent Storage").bold().centerJustified(),
                    ConcordButton("Store String") {
                        let success = self.platform.setPersistentString("ConcordUI permanent storage test", forKey: self.persistentStorageDemoKey)
                        self.persistentStorageResult = success ? "Permanent value stored." : "Permanent value could not be stored."
                        self.refreshStorage()
                    }.centerJustified(),
                    ConcordButton("Read String") {
                        self.persistentStorageResult = self.platform.persistentString(forKey: self.persistentStorageDemoKey) ?? "No permanent value found."
                        self.refreshStorage()
                    }.centerJustified(),
                    ConcordButton("Remove String") {
                        let success = self.platform.removePersistentValue(forKey: self.persistentStorageDemoKey)
                        self.persistentStorageResult = success ? "Permanent value removed." : "Permanent value could not be removed."
                        self.refreshStorage()
                    }.centerJustified(),
                    ConcordLabel(self.persistentStorageResult).italic().centerJustified()
                ]).boxed(),
                ConcordVStack([
                    ConcordLabel("Encrypted Storage").bold().centerJustified(),
                    ConcordButton("Store Secure String") {
                        let success = self.platform.setSecureString("ConcordUI encrypted storage test", forKey: self.secureStorageDemoKey)
                        self.secureStorageResult = success ? "Encrypted value stored." : "Encrypted value could not be stored."
                        self.refreshStorage()
                    }.centerJustified(),
                    ConcordButton("Read Secure String") {
                        self.secureStorageResult = self.platform.secureString(forKey: self.secureStorageDemoKey) ?? "No encrypted value found."
                        self.refreshStorage()
                    }.centerJustified(),
                    ConcordButton("Remove Secure String") {
                        let success = self.platform.removeSecureValue(forKey: self.secureStorageDemoKey)
                        self.secureStorageResult = success ? "Encrypted value removed." : "Encrypted value could not be removed."
                        self.refreshStorage()
                    }.centerJustified(),
                    ConcordLabel(self.secureStorageResult).italic().centerJustified()
                ]).boxed(),
                ConcordVStack([
                    ConcordLabel("First-Time Launch Testing").bold().centerJustified(),
                    ConcordButton("Reset Start") {
                        _ = self.resetFirstTimeLaunch()
                    }.centerJustified(),
                    ConcordButton("Reset Version") {
                        _ = self.resetFirstTimeNewVersion()
                    }.centerJustified(),
                    ConcordLabel("Reset changes take effect the next time the application starts.").italic()
                ]).boxed(),
                ConcordSpacer(), self.makeHome()
            ])
        }

        embeddedDataPresentation = ConcordPresentation {
            ConcordVStack([
                ConcordLabel("Embedded Data").bold().centerJustified(),
                ConcordLabel("Open, retrieve, share, and print resources embedded with the application.").italic(),
                ConcordDivider(),

                ConcordButton("Open Text") {
                    _ = self.platform.textOpen(name: "lorem")
                }.centerJustified(),

                ConcordButton("Open Cat Image") {
                    _ = self.platform.imageOpen(name: "greycat")
                }.centerJustified(),

                ConcordButton("Open PDF") {
                    _ = self.platform.pdfOpen(name: "essay")
                }.centerJustified(),

                ConcordButton("Share Text File") {
                    guard let sharing = self.platform as? any ConcordPlatformFileSupport else { return }
                    _ = sharing.resourceShare(name: "lorem", type: .text)
                }.centerJustified(),

                ConcordButton("Share Image File") {
                    guard let sharing = self.platform as? any ConcordPlatformFileSupport else { return }
                    _ = sharing.resourceShare(name: "lenna", type: .image)
                }.centerJustified(),

                ConcordButton("Share PDF File") {
                    guard let sharing = self.platform as? any ConcordPlatformFileSupport else { return }
                    _ = sharing.resourceShare(name: "essay", type: .pdf)
                }.centerJustified(),

                ConcordButton("Retrieve and Share Text") {
                    guard
                        let sharing = self.platform as? any ConcordPlatformFileSupport,
                        let text = self.platform.textRetrieve(name: "lorem")
                    else { return }
                    _ = sharing.shareTextContent(text)
                }.centerJustified(),

                ConcordButton("Retrieve and Share Image") {
                    guard
                        let sharing = self.platform as? any ConcordPlatformFileSupport,
                        let data = self.platform.imageRetrieve(name: "lenna")
                    else { return }
                    _ = sharing.shareDataContent(
                        data,
                        filename: "lenna.png",
                        mimeType: "image/png"
                    )
                }.centerJustified(),

                ConcordButton("Retrieve and Share PDF") {
                    guard
                        let sharing = self.platform as? any ConcordPlatformFileSupport,
                        let data = self.platform.pdfRetrieve(name: "essay")
                    else { return }
                    _ = sharing.shareDataContent(
                        data,
                        filename: "essay.pdf",
                        mimeType: "application/pdf"
                    )
                }.centerJustified(),

                ConcordButton("Print Text") {
                    guard
                        let printing = self.platform as? any ConcordPlatformPrintSupport,
                        let text = self.platform.textRetrieve(name: "lorem")
                    else { return }
                    _ = printing.printTextContent(text, font: .system)
                }.centerJustified(),

                ConcordButton("Print Text Monospaced") {
                    guard
                        let printing = self.platform as? any ConcordPlatformPrintSupport,
                        let text = self.platform.textRetrieve(name: "lorem")
                    else { return }
                    _ = printing.printTextContent(text, font: .monospaced)
                }.centerJustified(),

                ConcordButton("Print Image — Fit") {
                    guard
                        let printing = self.platform as? any ConcordPlatformPrintSupport,
                        let data = self.platform.imageRetrieve(name: "lenna"),
                        let image = ConcordBitmapImage(data: data)
                    else { return }
                    _ = printing.printImageContent(image, size: true)
                }.centerJustified(),

                ConcordButton("Print Image — Natural Size") {
                    guard
                        let printing = self.platform as? any ConcordPlatformPrintSupport,
                        let data = self.platform.imageRetrieve(name: "lenna"),
                        let image = ConcordBitmapImage(data: data)
                    else { return }
                    _ = printing.printImageContent(image, size: false)
                }.centerJustified(),

                ConcordSpacer(), self.makeHome()
            ])
            .fillSize()
        }

        let dateBinding = ConcordBinding<Date?>(get: { self.selectedDate }, set: { self.selectedDate = $0 })
        elementsPresentation = ConcordPresentation {
            ConcordVStack([
                ConcordLabel("Platform Elements").bold().centerJustified(),
                ConcordLabel("Elements that rely on platform-specific resources or native controls.").italic(),
                ConcordDivider(),
                ConcordVStack([
                    ConcordImage(self.platform.appIcon).centerJustified(),
                    ConcordLabel("App Icon").centerJustified()
                ]).boxed(),
                ConcordVStack([
                    ConcordDateElement(.picker, label: "System Date Picker", value: dateBinding)
                ]).boxed(),
                ConcordVStack([
                    ConcordLabel("Button Styles").bold().centerJustified(),
                    ConcordButton("Text Button", flavor: .text) {}.centerJustified(),
                    ConcordButton("Rounded Rectangle", flavor: .roundedRectangle) {}.centerJustified(),
                    ConcordButton(icon: .home, accessibilityLabel: "Home") {}.centerJustified()
                ]).boxed(),
                ConcordSpacer(), self.makeHome()
            ])
        }

        homePresentation = ConcordPresentation {
            ConcordVStack([
                ConcordLabel("ConcordUI Platform Showcase").bold().centerJustified(),
                ConcordLabel("Explore the currently implemented ConcordUI platform capabilities.").italic().centerJustified(),
                ConcordDivider(),
                self.platformButton("Information", self.informationPresentation),
                self.platformButton("Function", self.functionPresentation),
                self.platformButton("Audio & Speech", self.audioSpeechPresentation),
                self.platformButton("Storage", self.storagePresentation),
                self.platformButton("Embedded Data", self.embeddedDataPresentation),
                self.platformButton("Elements", self.elementsPresentation),
                ConcordSpacer(),
                ConcordLabel(self.platform.appVersionBuild).italic().centerJustified()
            ])
        }

        if let homePresentation {
            displayMainPresentation(homePresentation)
        }
    }
}
