# FocusMe

## Discipline — install on your iPhone (2 minutes)

The **Discipline** web app lives in [`docs/`](docs/) and is published automatically to GitHub Pages:

**https://maxxthebest7-sys.github.io/FocusMe/**

Scan to open it on your phone:

![QR code for the Discipline app](https://api.qrserver.com/v1/create-qr-code/?size=180x180&margin=8&data=https%3A%2F%2Fmaxxthebest7-sys.github.io%2FFocusMe%2F)

1. Open the link in **Safari** on your iPhone (iOS 16.4 or newer).
2. Tap **Share** (the square with an arrow) → **Add to Home Screen** → **Add**.
3. Open **Discipline** from your Home Screen and tap **Turn on reminders** → **Allow**.

That's it. No App Store, no developer account, no 7-day expiry. The app itself walks you through these steps the first time it opens, and tells you when an update is ready.

**Publishing / updating:** every push that touches `docs/` runs the *Deploy Discipline PWA* workflow, which generates the icons and deploys to Pages. The first time, open the repo's **Settings → Pages** and set **Source** to **GitHub Actions** if the workflow didn't already enable it. When you change `docs/`, bump `VERSION` in `docs/sw.js` and `APP_VERSION` in `docs/index.html` so installed copies offer the update.

---

**FocusMe** is a Swift-based reminder app using SwiftUI for UI, Combine for reactive state management, and Core Data for local persistence. It follows Clean Architecture to support modular, testable, and scalable code.

## Features
- Create, view, and manage reminders
- Calendar integration for browsing reminders by date
- Modular Clean Architecture (Use Cases + Repositories)
- SwiftUI-based user interface
- Reactive state management with Combine

## Tech Stack
- Swift 5
- SwiftUI
- Combine
- CoreData
- UserNotifications

## Getting Started
1. Clone the repository:
   ```bash
   git clone https://github.com/PortoCode/FocusMe.git
   cd FocusMe
   ```
2. Open the project in Xcode (>= 14.0)
3. Run on iOS Simulator or device
