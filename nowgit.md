# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | Sketcho |
| **Git URL** | git@github.com:asunnyboy861/Sketcho.git |
| **Repo URL** | https://github.com/asunnyboy861/Sketcho |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ⏳ Pending (enabled in PHASE 7 from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/Sketcho/ | ⏳ Pending |
| Support | https://asunnyboy861.github.io/Sketcho/support.html | ⏳ Pending |
| Privacy Policy | https://asunnyboy861.github.io/Sketcho/privacy.html | ⏳ Pending |
| Terms of Use | https://asunnyboy861.github.io/Sketcho/terms.html | ⏳ Pending (subscription app) |

## Repository Structure

```
Sketcho/
├── Sketcho.xcodeproj/             # Xcode Project (bundle: com.zzoutuo.Sketcho, iOS 17+)
├── Sketcho/                       # Swift Source Files (synced root group)
│   ├── SketchoApp.swift           # Entry + SwiftData container
│   ├── ContentView.swift          # Root tabs: Create / Projects / Pro
│   ├── Core/                      # DesignSystem, Models, Support, PromptEngine,
│   │                              # VisionPreprocessor, AIRouter, OnDeviceRenderer,
│   │                              # CloudRenderer, DeepSeekService
│   ├── Features/                  # Home, Capture, Render, TapToEdit, StyleQuad,
│   │                              # ShopTheLook, Chat, Export, Projects
│   ├── Pay/                       # StoreService (StoreKit 2), PaywallView
│   ├── Settings/                  # SettingsView, ContactSupportView
│   └── Intents/                   # App Intents / Siri shortcuts
├── SketchoTests/                  # Unit tests target
├── SketchoUITests/                # UI tests target
├── docs/                          # Policy Pages (PHASE 7)
├── us.md                          # English development guide
├── capabilities.md                # Capabilities configuration
├── icon.md                        # App icon documentation
├── price.md                       # Pricing / IAP configuration
├── app_review_info.md             # Apple review instructions
├── nowgit.md                      # This file
├── keytext.md                     # ⚠️ EXCLUDED from repo (.gitignore — ASO strategy)
├── COMPETITOR_REPORT.md           # ⚠️ EXCLUDED from repo (.gitignore)
└── improvement_plan_1.md          # ⚠️ EXCLUDED from repo (.gitignore)
```

## Testing Summary

| Device | Result |
|--------|--------|
| iPhone 16 (iOS 26.4) | ✅ BUILD SUCCEEDED, app launched, home screen verified |
| iPad Pro 13-inch (M5) (iOS 26.4) | ✅ BUILD SUCCEEDED, app launched, tab layout adapted |
