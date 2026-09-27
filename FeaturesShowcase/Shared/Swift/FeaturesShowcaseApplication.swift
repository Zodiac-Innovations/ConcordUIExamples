//
//  FeaturesShowcaseApplication.swift
//  FeaturesShowcase
//

import ConcordUI

nonisolated public final class FeaturesShowcaseApplication: ConcordApplication {

    public override func startApplication() {

        mainVenue
            .size(640, 480)
            .minSize(640, 480)
            .maxSize(640, 480)

        // Welcome Feature
        
        useStandardWelcomeFeature(
            images: [
                .asset("welcome-getstarted"),
                .asset("welcome-whatsnew"),
                .asset("welcome-about")
            ],
            subHeader: "Native Swift interfaces for Apple and Android."
        )
        
        // Get Started Feature
        
        useStandardGetStartedFeature(
            summaries: [
                ConcordSummaryData(
                    image: .icon(.settings),
                    title: "Standard Features",
                    description: "Reusable native presentations for common application experiences."
                ),
                ConcordSummaryData(
                    image: .icon(.app),
                    title: "Cross-Platform",
                    description: "One shared Swift definition rendered for Apple and Android."
                ),
                ConcordSummaryData(
                    image: .icon(.information),
                    title: "Native Presentation",
                    description: "Platform-appropriate windows, menus, controls, and mobile navigation."
                )
            ],
            centerAccess: ConcordAccessData(
                title: "Complete Feature List",
                link: "https://concordui.org/features.html"
            ),
            accessList: [
                ConcordAccessData(title: "ConcordUI.Org", link: "https://concordui.org")
            ]
        )
        
        // What's New Feature
        
        useStandardWhatsNewFeature(
            summaries: [
                ConcordSummaryData(
                    image: .icon(.add),
                    title: "Reusable Feature Configuration",
                    description: "Standard application features now share one configuration and display path."
                ),
                ConcordSummaryData(
                    image: .icon(.information),
                    title: "Standard About",
                    description: "Applications can present a native, cross-platform About experience."
                ),
                ConcordSummaryData(
                    image: .icon(.settings),
                    title: "Get Started",
                    description: "Summary-driven onboarding is available from application UI and native menus."
                )
            ],
            centerAccess: ConcordAccessData(
                title: "Complete Feature List",
                link: "https://concordui.org/features.html"
            ),
            accessList: [
                ConcordAccessData(title: "ConcordUI.Org", link: "https://concordui.org")
            ]
        )

        // About Feature
        
        useStandardAboutFeature(
            urlAcknowledgements: "https://concordui.org/acknowledgement.html",
            urlLicenseAgreement: "https://concordui.org/license.html"
        )
        
        // Setting Features

        settingsFeature = ConcordFeatureConfig(
            presentation: { [weak self] in
                ConcordPresentation {
                    ConcordVStack([
                        ConcordText(ConcordString.settings)
                            .bold()
                            .fontSize(28)
                            .centerJustified(),
                        ConcordDivider(),
                        ConcordSpacer(),
                        ConcordHStack([
                            self?.concordAllSpecialButton(flavor: .stack)
                                ?? ConcordBlankElement()
                        ])
                        .centerJustified(),
                        ConcordText(
                            "Reset Start makes the next launch behave like the application's first launch. Reset Version makes the next launch behave like the first launch of the current version. Restart the app after pressing either button to see the effect."
                        )
                        .centerJustified(),
                        ConcordSpacer()
                    ])
                    .fillSize()
                }
            },
            preferredWindowSize: (width: 480, height: 320),
            dismissAble: true
        )
        
        addSettingAccess(
            ConcordAccessData(
                title: "ConcordUI.Org",
                link: "https://concordui.org"
            )
        )


        // FAQ Feature

        useStandardFAQFeature(
            text: """
            {
              "sections": [
                {
                  "title": "Getting Started",
                  "questions": [
                    {
                      "question": "How do I use the standard features?",
                      "answer": "Choose a feature from the application interface or the Help menu.",
                      "access": [
                        {
                          "title": "Complete Feature List",
                          "link": "https://concordui.org/features.html"
                        }
                      ]
                    },
                    {
                      "question": "Where can I open a feature?",
                      "answer": "Use its button on the home presentation or choose it from the Help menu."
                    }
                  ]
                },
                {
                  "title": "Cross-Platform",
                  "questions": [
                    {
                      "question": "Does the same FAQ work on Apple and Android?",
                      "answer": "Yes. ConcordUI renders the shared FAQ data using each platform's native interface."
                    },
                    {
                      "question": "Can a question link to more information?",
                      "answer": "Yes. Add one or more access entries containing a URL or bundled file.",
                      "access": [
                        {
                          "title": "ConcordUI Website",
                          "link": "https://concordui.org"
                        }
                      ]
                    }
                  ]
                }
              ]
            }
            """
        )

        // Help Feature

        helpFeature = ConcordFeatureConfig(
            presentation: {
                ConcordPresentation {
                    ConcordVStack([
                        ConcordText(
                            "Features Showcase demonstrates ConcordUI's reusable, native application features on Apple and Android platforms."
                        ),

                        ConcordText("About")
                            .bold()
                            .fontSize(20),
                        ConcordText(
                            "Displays the application icon, name, version, copyright, acknowledgements, and license information using a standard platform-appropriate presentation."
                        ),

                        ConcordText("Welcome")
                            .bold()
                            .fontSize(20),
                        ConcordText(
                            "Introduces the application with a title, optional subheader, and overlapping preview images. On first launch it can continue directly to Get Started."
                        ),

                        ConcordText("Get Started")
                            .bold()
                            .fontSize(20),
                        ConcordText(
                            "Presents a concise introduction to the application's major capabilities, with summary icons and optional links to additional information."
                        ),

                        ConcordText("What's New")
                            .bold()
                            .fontSize(20),
                        ConcordText(
                            "Highlights changes in a newly installed application version and is shown automatically the first time that version is launched."
                        ),

                        ConcordText("FAQ")
                            .bold()
                            .fontSize(20),
                        ConcordText(
                            "Organizes questions into sections. Each question expands to reveal its answer and any related links or embedded documents."
                        ),

                        ConcordText("Help")
                            .bold()
                            .fontSize(20),
                        ConcordText(
                            "Provides application guidance in a presentation supplied by the developer. Additional help links and actions can also appear in the Help menu."
                        ),

                        ConcordText("Settings")
                            .bold()
                            .fontSize(20),
                        ConcordText(
                            "Provides a managed location for application preferences. Its presentation can be supplied by the developer, with related settings links and actions available alongside it."
                        )
                    ])
                    .fillSize()
                    .boxed(width: 1, cornerRadius: 4, padding: 10)
                }
            },
            preferredWindowSize: (width: 480, height: 320),
            dismissAble: true
        )

        // Additional Help actions
        
        addHelpAccess(
            ConcordAccessData(
                title: "Apple Support",
                link: "https://support.apple.com"
            )
        )
        addHelpAccess(
            ConcordAccessData(
                title: "Google Play Support",
                link: "https://support.google.com/googleplay"
            )
        )

        
        // Custom action Feature
        
        createActionGroup(
            tag: "showcase-links",
            title: ConcordString.links
        )
        
        createActionGroupItem(
            groupTag: "showcase-links",
            action: ConcordTitleAction("Apple") { [weak self] in
                guard let self else { return }
                ConcordAccessData(
                    title: "Apple",
                    link: "https://apple.com"
                ).openAccess(using: self)
            }
        )
        createActionGroupItem(
            groupTag: "showcase-links",
            action: ConcordTitleAction("Google Play") { [weak self] in
                guard let self else { return }
                ConcordAccessData(
                    title: "Google Play",
                    link: "https://google.com/googleplay"
                ).openAccess(using: self)
            }
        )
        
        // Special Feature

        createSpecialItem(
            action: ConcordTitleAction("Reset Start") { [weak self] in
                self?.resetFirstTimeLaunch()
            }
        )

        createSpecialItem(
            action: ConcordTitleAction("Reset Version") { [weak self] in
                self?.resetFirstTimeNewVersion()
            }
        )

        // Main Home Page
        
        registerHome { _ in
            ConcordPresentation {
                ConcordVStack([
                    ConcordText("Hello FeaturesShowcase")
                        .centerJustified(),
                    ConcordDivider(),
                    self.concordAboutFeatureButton(),
                    self.concordWelcomeFeatureButton(),
                    self.concordGetStartedFeatureButton(),
                    self.concordWhatsNewFeatureButton(),
                    self.concordFAQFeatureButton(),
                    self.concordHelpFeatureButton(),
                    self.concordSettingsFeatureButton(),
                    ConcordDivider(),
                    ConcordHStack([
                        self.concordAboutFeatureButton(flavor: .icon),
                        self.concordWelcomeFeatureButton(flavor: .icon),
                        self.concordGetStartedFeatureButton(flavor: .icon),
                        self.concordWhatsNewFeatureButton(flavor: .icon),
                        self.concordFAQFeatureButton(flavor: .icon),
                        self.concordHelpFeatureButton(flavor: .icon),
                        self.concordSettingsFeatureButton(flavor: .icon),
                    ]),
                    ConcordDivider(),
                    self.concordAllHelpButton(),
                    self.concordAllSettingButton(),
                    ConcordActionGroupButton(tag: "showcase-links"),
                ])
                .fillSize()
            }
        }

        // Start app
        
        standardAppStart()
    }
}
