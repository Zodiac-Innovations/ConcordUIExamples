# ConcordUI Showcase Guide

**Status:** Living component guide  
**Project:** ConcordUI  
**Area:** Showcases

## Purpose

This is the authoritative component guide for the ConcordUI `Showcases` area. It documents the purpose, organization, conventions, and expectations for all Showcase applications and their subdirectories. Details about Element Showcase, Presentation Showcase, and future Showcases belong as sections in this one guide rather than in separate guide files within each Showcase directory, unless a compelling technical reason requires otherwise.

ConcordUI Showcase Apps deliberately demonstrate and verify framework capabilities. They are development and integration tools as well as examples: when a visual or behavioral framework feature is completed, the appropriate Showcase should make that capability observable and testable. Showcases differ from Sample Apps, which demonstrate useful applications built with ConcordUI rather than systematically exposing framework capabilities.

## Documentation Rule

This file is the single component guide for the `Showcases` hierarchy. `ElementShowcase`, `PresentationShowcase`, and their `Shared`, `Apple`, and `Android` subdirectories should normally not contain their own documentation guides. Humans and AI development assistants working anywhere in the Showcase hierarchy should be able to consult this one document for authoritative Showcase-wide guidance.

## Element Showcase

Element Showcase is the canonical demonstration and integration check for ConcordUI elements and element-level capabilities. It should expose supported elements and relevant modifiers, bindings, actions, validation behavior, layout behavior, and other element features in a form that can be exercised on the supported primary platforms. It is not intended to look like a finished commercial application; its purpose is systematic framework demonstration and verification.

## Presentation Showcase

Presentation Showcase is the canonical demonstration area for `ConcordPresentation`, `ConcordSection`, ownership, lifecycle, navigation/display behavior, data injection, Home Presentation, child Presentations, and other Presentation/Section architecture. It should exercise these concepts using the same portable public API that application developers use and should remain available on both Apple and Android as those capabilities evolve.

## Vector Showcase

Vector Showcase is the planned focused demonstration and parity check for the Core vector protocol, `ConcordVectorElement`, logical coordinate behavior, and Apple/Android native vector rendering. Shared Swift should define the demonstrated drawings, while the platform hosts and renderers remain thin. macOS validation should accompany the Apple and Android checks.

## Markup Showcase

Markup Showcase is the planned focused demonstration and parity check for `ConcordMarkupProtocol`, `ConcordMarkupClosure`, typed style sheets, `ConcordMarkupElement`, accessibility semantics, and Apple/Android native Markup rendering. Shared Swift should define the semantic content and styles. The initial Showcase should cover headings, paragraphs, inline emphasis, links, lists, images, quotations, code/preformatted content, horizontal rules, named styles, and developer-special-data behavior, with Apple, Android, and macOS validation.

Markup Showcase belongs to the Core release path. Optional concrete recording, custom DSL, PDF, and external document-format packages may add demonstrations later but must not block the initial Showcase.

## Platform Structure

Showcases should keep portable application behavior in their shared Swift area and use thin platform-specific hosts for Apple and Android. Platform host code exists to connect the shared ConcordUI application to the native backend; it should not become a second implementation of application behavior that belongs in shared Swift.

## Feature Completion

The project-wide feature completion rule is **Core → Apple → Android → Showcase → CI**. When Showcase coverage is relevant to a feature, the appropriate Showcase must demonstrate or verify the completed behavior before that feature is considered complete. A feature is not complete merely because it works in Core or on one platform.
