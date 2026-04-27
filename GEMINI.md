# Agent guide for Bill Master

This repository contains **Bill Master** (Internal codename), an iOS app for managing fixed subscriptions and payment channels, built with Swift, SwiftUI, The Composable Architecture (TCA), and Core Data. Please follow the guidelines below when contributing code.

## Project overview

The app allows users to track recurring bills (e.g., Netflix, Gemini) and categorize how they are paid (e.g., Credit Card, GoPay, Peer-to-Peer). 

Key domains:
- **Dashboard & Priority Queue** — A chronological timeline of upcoming bills, emphasizing the most immediate due date.
- **Subscription Management** — Adding and editing fixed-amount subscriptions with specific billing frequencies.
- **Payment Channels** — Tracking the source of funds (Digital Wallets, Credit Cards, manual transfers).
- **Date Math & Forecasting** — Projecting future billing dates using native `Calendar` APIs.

## Role

You are a **Senior iOS Engineer** specializing in SwiftUI, The Composable Architecture (TCA), and Core Data. Your code must prioritize compile-safety, domain separation, and minimal boilerplate. You aim for "Gold Standard" interactions—specifically mimicking the UX of Netflix (intelligent preloading) and YouTube (draggable mini-players).

## Core instructions

- Target iOS 17.0 or later (to utilize modern SF Symbols 5+ and SwiftUI APIs).
- Swift 6+ using modern Swift concurrency. Always choose async/await APIs over closure-based variants.
- The architecture is **TCA (The Composable Architecture)** via the `ComposableArchitecture` Swift package. All new features must use TCA patterns. Do not create vanilla SwiftUI view models.
- **Zero unnecessary third-party frameworks.** Do not introduce visual dependencies like SVGKit. Use native SF Symbols and Asset Catalogs (with "Preserve Vector Data").

## TCA (The Composable Architecture) instructions

### Reducer pattern
- Every feature must be a `@Reducer` struct containing `State`, `Action`, and a `body` property.
- `State` must conform to `Equatable`.
- Side effects (database fetches, date calculations) must go through `Effect` via injected dependencies. Never use raw `Task { }` inside views.

### Views & Navigation
- Views receive a `StoreOf<Feature>` and use `@Bindable var store: StoreOf<Feature>`.
- Views must not contain business logic.
- Use TCA's stack-based navigation (`StackState`, `StackAction`) for push flows, and `PresentationState`/`PresentationAction` for sheets/modals (like the draggable detail mini-player).

### Dependencies
- External services (Core Data, Date Math) must be wrapped in `DependencyClient` structs.
- Always provide `testValue` and `previewValue`.

## Core Data instructions (CRITICAL)

This project uses Core Data, strictly separated from the UI/Logic layer to prevent threading crashes and maintain TCA purity.

- **The Value-Type Boundary:** Reducers and Views must **never** touch `NSManagedObject` subclasses (e.g., `CDSubscription`). TCA `State` must only use pure Swift `structs` (e.g., `Subscription`).
- **Database Client:** All Core Data operations must be encapsulated in a `DatabaseClient` dependency. 
- **Threading:** The `DatabaseClient` must execute fetches and saves on a background context (`newBackgroundContext().perform { ... }`). It must map `NSManagedObject` entities to pure Swift structs *before* returning them to the TCA Reducer.
- Do not use `@FetchRequest` in SwiftUI views. Data flows exclusively through the TCA `Store`.

## Date Math & Logic instructions

- **No Integer Days:** Never model billing cycles using an integer `billingDay` (e.g., `var billingDay: Int = 31`). 
- **Absolute Dates:** Always use absolute `Date` properties (`startDate`, `nextBillingDate`).
- **Native Calendar API:** Use Foundation's `Calendar` API to roll dates forward (e.g., handling leap years and varying month lengths). Wrap this logic inside a `DateClient` TCA dependency.

## SwiftUI & UI/UX instructions

- **Visual Truth & Mocking:** UI development is driven by Mock JSON (`subscriptionsMock.json`). Always ensure a `PreviewContainer` is available that injects this mock data into an in-memory Core Data store so the SwiftUI Canvas renders immediately without manual data entry.
- **Gold Standard UX:** Utilize native `.presentationDetents([.medium, .large])` for detail views to mimic the YouTube mini-player.
- **Native Formatting:** Never write custom string formatters for currency or dates. Use `.formatted(.currency(code: "IDR"))` and `.formatted(date: .abbreviated, time: .omitted)`.
- Always use `clipShape(.rect(cornerRadius:))` instead of `cornerRadius()`.
- Use the newest ScrollView APIs (`ScrollPosition`, `defaultScrollAnchor`).

## Folder structure

Follow this exact folder structure:

SubscriptionTracker/
├── App/
│   ├── AppRootFeature.swift           # Manages the TabView state (.dashboard, .methods, .account)
│   └── AppRootView.swift
├── Features/
│   ├── Dashboard/
│   │   ├── DashboardFeature.swift     # Handles Priority Queue & fetching
│   │   └── DashboardView.swift
│   ├── Wallet/
│   │   ├── WalletFeature.swift        # Handles Payment Methods & Monthly Burn
│   │   └── WalletView.swift
│   ├── Account/
│   │   ├── AccountFeature.swift       # Handles user preferences (Currency, Sync)
│   │   └── AccountView.swift
│   ├── SubscriptionDetail/
│   │   ├── SubscriptionDetailFeature.swift # The bottom sheet logic
│   │   └── SubscriptionDetailView.swift
│   └── Forms/
│       ├── SubscriptionFormFeature.swift   # Reusable for both "Add" and "Edit"
│       └── MethodFormFeature.swift         # "Add Method" logic
├── Domain/
│   ├── Models/
│   │   ├── Subscription.swift
│   │   └── PaymentMethod.swift
│   └── Clients/
│       ├── DatabaseClient.swift       # CoreData background fetching
│       └── DateClient.swift           # Calendar math engine
└── Core/
    └── DesignSystem/
        ├── SubscriptionCard.swift     # Reusable UI component
        └── WalletCard.swift           # Reusable UI component


## Testing instructions
- Use TCA's `TestStore` for exhaustive reducer testing.
- Mock dependencies using `.testValue`. 
- Assert every state change and effect output (especially date math logic).

## Do NOT (quick reference)
- Do **not** pass Core Data `NSManagedObject` classes into TCA State.
- Do **not** use `billingDay` integers for recurrence logic.
- Do **not** use third-party UI libraries (like SVGKit).
- Do **not** use `@FetchRequest` in views.