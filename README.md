# ⚡ FarmCharge

A native **iOS SwiftUI** prototype for discovering, booking, and paying for EV & agricultural-drone charging stations across rural Thailand. Designed for farmers and users outside major cities, with a clean, modern UI in Thai (primary) and English (secondary).

> 🌾 Built from a [Claude Design](https://claude.ai/design) handoff bundle — a multi-screen iOS prototype covering the full charging flow from station discovery to payment.

---

## ✨ Features

- 🗺️ **Map-first discovery** — Stylized map view with solar-powered station pins, availability indicators, and real-time filter chips (All / EV car / Drone)
- 🔍 **Search** — Quick suggestions and nearby station results
- 📍 **Station detail** — Stats (distance, ETA, kW), connector availability (CCS2, Type 2, Drone Pad), reviews, and address
- 🗓️ **Booking** — Select vehicle/drone, connector, time slot, and charging duration
- 💳 **Payments** — Multiple methods (PromptPay QR, TrueMoney Wallet, Rabbit LINE Pay, SCB EASY, credit/debit card)
- 🔋 **Active charging** — Animated ring progress with live kW/kWh/time and running cost
- 👤 **Profile & trip history** — Vehicles, payment methods, savings indicator, and past sessions
- 🇹🇭 **Thai-first UI** — Localized copy for Thai agricultural users

---

## 🖼️ Screenshots

> _Coming soon_ — screenshots of the following screens will be added here:

| Onboarding | Map | Station Detail |
|------------|-----|----------------|
| _placeholder_ | _placeholder_ | _placeholder_ |

| Booking | Payment | Active Charging |
|---------|---------|-----------------|
| _placeholder_ | _placeholder_ | _placeholder_ |

| Profile | Trip History | Search |
|---------|--------------|--------|
| _placeholder_ | _placeholder_ | _placeholder_ |

---

## 🛠️ Tech Stack

- **Language**: Swift 5
- **UI Framework**: SwiftUI
- **Platform**: iOS 26.4+
- **Architecture**: `ObservableObject` router + view-local `@State`
- **No third-party dependencies** — pure SwiftUI + Combine

---

## 📋 Requirements

- **macOS** 14 or later
- **Xcode** 26 or later (project uses `objectVersion = 77` and the iOS 26.4 SDK)
- **iOS** 26.4+ deployment target (Simulator or device)
- **Apple Developer account** for running on a physical device

---

## 🚀 Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/sirawitchpoon/FarmCharge.git
   cd FarmCharge
   ```

2. **Open in Xcode**

   ```bash
   open FarmCharge.xcodeproj
   ```

3. **Select a simulator** (iPhone 17 Pro / iPhone Air / iPhone 17e recommended) and press **⌘R** to build and run.

   Alternatively, build from the command line:

   ```bash
   xcodebuild \
     -project FarmCharge.xcodeproj \
     -scheme FarmCharge \
     -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
     build
   ```

---

## 📂 Project Structure

```
FarmCharge/
├── FarmCharge.xcodeproj/          # Xcode project
└── FarmCharge/                    # App sources (auto-synced file group)
    ├── FarmChargeApp.swift        # @main — SwiftUI App entry
    ├── ContentView.swift          # Root screen router
    │
    ├── Theme.swift                # Color palette, fonts, baht formatter
    ├── Station.swift              # Station + Connector data models
    ├── SharedViews.swift          # Router, Card, Pill, StationCard, etc.
    │
    ├── OnboardingView.swift       # 3-slide intro flow
    ├── MapView.swift              # Home: map + pins + bottom sheet
    ├── StationDetailView.swift    # Station info, connectors, reviews
    ├── BookingView.swift          # Vehicle, connector, time slot, duration
    ├── PaymentView.swift          # PromptPay / wallets / cards + success
    ├── ActiveChargingView.swift   # Live session ring + stats
    ├── ProfileView.swift          # Profile, trip history, search
    │
    └── Assets.xcassets/           # App icon, accent color
```

### 🎨 Design System (`Theme.swift`)

The palette is a warm rural/agricultural tone:

| Token        | Hex       | Usage                              |
|--------------|-----------|------------------------------------|
| `forest`     | `#0F3D2E` | Primary brand, buttons             |
| `lime`       | `#4ADE80` | Accent on dark surfaces            |
| `sun`        | `#FACC15` | Solar indicator, price badges      |
| `paper`      | `#FAF7EE` | App background                     |
| `ink`        | `#0A1F17` | Primary text                       |

Display headings use the **Instrument Serif** fallback; body copy uses the iOS system font (which covers Thai automatically).

### 🔀 Navigation

A lightweight `Router: ObservableObject` (in `SharedViews.swift`) drives the active screen via an `AppScreen` enum. `ContentView` switches on `router.screen` and injects the router down the tree as an `@EnvironmentObject`.

---

## 📄 License

This project is released under the **MIT License**. See `LICENSE` for details.

```
MIT License

Copyright (c) 2026 Sirawitch Butryojantho

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
```
