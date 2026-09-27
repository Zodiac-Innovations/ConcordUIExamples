# ConcordUI Sample Guide

**Status:** Living component guide  
**Project:** ConcordUI  
**Area:** Samples

## Purpose

This is the authoritative component guide for the ConcordUI `Samples` area. It documents the purpose, organization, conventions, and expectations for all Sample applications and their subdirectories. Sample-specific details belong as sections in this guide rather than as additional guide documents scattered through individual Sample folders, unless a compelling technical reason requires otherwise.

ConcordUI Sample Apps demonstrate useful applications built with ConcordUI. They are intended to teach developers how the framework is used in realistic application code and to provide understandable examples of complete or focused application patterns. Samples are different from Showcases: a Sample demonstrates an application or application pattern, while a Showcase deliberately demonstrates and verifies framework capabilities.

## Documentation Rule

This file is the single component guide for the `Samples` hierarchy. Individual Sample directories such as `HelloWorld` should normally contain source and platform-support files, not separate documentation guides. Documentation for an individual Sample should be maintained as a section of this guide so that humans and AI development assistants have one authoritative place to understand the entire Samples area.

## HelloWorld

`HelloWorld` is the canonical minimal ConcordUI Sample and smoke test. It should remain intentionally small and use the current public ConcordUI API rather than internal implementation details. Its shared application code should demonstrate the minimum structure needed for a ConcordUI application, and the Sample should remain runnable on both Apple and Android. Because HelloWorld is a smoke test as well as a teaching example, unnecessary framework features should not be added merely to make the Sample more elaborate.

## Adding Samples

New Samples should demonstrate useful applications or focused application patterns rather than duplicate the role of the Showcase applications. A proposed Sample should have a clear learning or validation purpose and should use portable shared Swift application code wherever ConcordUI intends that code to be portable. When a Sample requires platform host code, that host code should remain thin and should not move ordinary application behavior out of shared ConcordUI code.
