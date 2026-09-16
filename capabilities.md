# Capabilities Configuration

## Analysis
Based on operation guide analysis (keywords: 拍摄/拍照/相机, 相册/照片, 订阅/购买/会员, Siri/快捷指令, 锁屏 Widget, 云端渲染/BYO API, 本地存储 SwiftData):

| Detected Need | Capability |
|---------------|------------|
| Capture rooms / import sketches | Camera + Photo Library usage descriptions |
| Cloud render + BYO API (fal.ai/Replicate/DeepSeek) | Outgoing network (no config needed — allowed by default) |
| 4-tier paywall (Free/Pro/Studio/lifetime) | In-App Purchase (StoreKit 2) |
| "Hey Siri, Sketcho my sketch" | App Intents (AppShortcutsProvider — no entitlement required) |
| Lock-screen widget | WidgetKit extension target |
| Projects/history | SwiftData (no capability) |
| On-device AI prompt generation | Foundation Models framework (iOS 26+, runtime availability check — no entitlement) |

## Auto-Configured Capabilities
| Capability | Status | Method |
|------------|--------|--------|
| Bundle ID corrected to `com.zzoutuo.Sketcho` | ✅ Configured | pbxproj edit (was `com.zzoutuo.Sketcho.Sketcho`) |
| Deployment target iOS 17.0 (main app) | ✅ Verified | pbxproj (test targets 26.4) |
| Camera usage description | ✅ Configured | INFOPLIST_KEY_NSCameraUsageDescription |
| Photo Library usage description | ✅ Configured | INFOPLIST_KEY_NSPhotoLibraryUsageDescription |
| Siri usage description | ✅ Configured | INFOPLIST_KEY_NSSiriUsageDescription |
| App Icon (1024, dark/tinted) | ✅ Configured | Asset Catalog AppIcon.appiconset |
| Development Team / auto signing | ✅ Present | DEVELOPMENT_TEAM = JP4TN5PTS3, CODE_SIGN_STYLE = Automatic |
| In-App Purchase | ✅ Ready | StoreKit 2 requires no explicit entitlement; products configured in App Store Connect (manual step at submission time) |
| App Intents (Siri phrase) | ✅ Ready | AppShortcutsProvider in code — no entitlement needed |

## Manual Configuration Required
| Capability | Status | Steps |
|------------|--------|-------|
| Lock-screen Widget (WidgetKit extension) | ⏳ Optional | App is fully functional without it. To add: Xcode → File → New → Target → Widget Extension (name: SketchoWidget, embed in app). The render-last-project App Intent already exists and is reusable by any future widget. |
| IAP products in App Store Connect | ⏳ Submission time | Create subscription group + products per price.md (Pro $12.99/mo, $79.99/yr, $149 lifetime; Studio $29.99/mo, $199/yr) when submitting. StoreKit 2 code reads products dynamically. |

## No Configuration Needed
- Outgoing network (cloud render / BYO API) — default allowed
- Push Notifications — not in guide
- iCloud — not in guide (SwiftData local only)
- Location, HealthKit, Apple Watch — not in guide

## Verification
- Build succeeded after configuration: (see PHASE 4/6 build results)
- All entitlements correct: ✅ (none required; graceful degradation everywhere)
