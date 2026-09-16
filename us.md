# Sketcho - iOS Development Guide

> Translated and structured from: TR-20260915-速渲Sketcho-操作指南.MD (2026-09-15)

## Executive Summary

**Sketcho** is a native iOS AI rendering app that turns sketches and room photos into photorealistic renders. It targets two markets with one app:

- **B2B core** (architects, interior designers, real-estate agents): geometry locking, material placement, batch style boards, high-res export → "professionally trustworthy" reputation supporting the Studio subscription.
- **C-end periphery** (homeowners, renters, home enthusiasts): photo room → conversational restyle → real shoppable furniture list → volume and viral spread (before/after is natural TikTok format).

**Winning formula**: iOS native (no competitor has it) + Apple free AI (cost-structure advantage) + Geometry Lock (professional trust) + Tap-to-Edit (most requested) + Transparent pricing (blue ocean of an unfair-review market).

**Benchmark competitor**: Visualizee.ai — ~$10,000/month AI architecture rendering web tool (verified via Starter Story 2026-09-02 interview). Target: MVP in 6 weeks, $10K MRR by month 3.

**Key differentiators (competitor weaknesses → our features)**:
1. Visualizee has NO iOS app (74% of US architects use iPhone) → we are native-first.
2. Competitors use complex/expensive credit systems → we use transparent daily-free quotas.
3. "Everything after the image" is an industry-wide gap → we ship Tap-to-Edit, Shop the Look, export compliance.

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| Visualizee.ai | Mature web platform, batch 16, 32MP | No iOS app; credit system complex ($35/mo = 240 renders); commercial license paid-only | Native iOS; honest free tier (3 HD/day); $149 lifetime option |
| RoomGPT | Open-source origin (MIT), simple UX | "Furniture is completely fictional... you can not buy any of it"; pricing behind login wall; flat textures | Shop the Look with real products; no login wall; Lock Mode |
| Interior AI | Established brand | "Results can be generic"; "absurd details (odd furniture placement, distorted lighting)" | ControlNet edge+depth dual conditioning; fidelity badge |
| ReRoom AI | Has iOS app | "Precision issues with furniture dimensions"; only 5 free credits; multi-room fails | Unlimited on-device previews; project folders with version timeline |
| Remodel AI | Cross-platform | Fake free (3 free tries then wall) | Honest free layer written on first screen |
| MeltFlex | Shoppable furniture + floorplan-to-3D ($9/mo) | No professional rendering controls | Pro-level lock controls + shopping in free tier |
| Lumion/V-Ray/Enscape | Professional quality | $575-995/yr + GPU hardware + weeks of learning | Zero-parameter single lock slider; $12.99/mo |

## ⚠️ Feature Inventory (MANDATORY — Every Feature Must Be Listed)

### Primary Features

| # | Feature | User Operation Flow | Data Input | Processing | Data Output | Persistence | Acceptance Criteria |
|---|---------|--------------------|------------|------------|-------------|-------------|---------------------|
| 1 | Capture / Import | 1. Home shows one big 📸 button → 2. Tap to shoot room OR pick from photo library OR import sketch line-art | Camera photo / library image / sketch image | Image normalization, downscale to working resolution | Working image in render session | SwiftData: original image asset | Photo/sketch appears in editor within 2s |
| 2 | Style selection | 1. Bottom style capsule rail horizontally scrolls → 2. Tap style → 0.5s highlight | Style tap (modern/scandinavian/industrial/japandi/farmhouse/midcentury) | Style template lookup + prompt fragment injection | Selected style chip highlighted | In-session state | Style chip visually selected; affects next render |
| 3 | AI Router (3-tier) | Automatic; no user action | RenderIntent (user input + vision facts) | Tier resolution: BYO key > free cloud quota > on-device SD > cloud fallback; structured prompt generation | RenderPlan (channel + structured prompt) | None (ephemeral) | Correct channel chosen per entitlements; all calls exit through single router |
| 4 | On-device preview render | 1. Tap "Render – Preview" → 2. 3-8s wait with progress | Working image + structured prompt | CoreML SDXL-Turbo 4-step sampling (cpuAndGPU), optional canny condition | Preview image labeled "Preview quality" | SwiftData: render version | Preview image appears ≤10s on 8GB+ device; free, unlimited, works offline |
| 5 | Cloud HD render | 1. Tap "Render – HD" → 2. 15s wait | Image + edge map + depth map + prompt + lock weight | POST fal.ai Flux.2 ControlNet-union (canny+depth), 28 steps | HD image (up to 4K after upscaling) | SwiftData: render version | HD image ≤30s; timeout auto-degrades to on-device preview labeled "Preview quality" |
| 6 | Lock Mode (geometry fidelity) | 1. Toggle Lock Mode ON → 2. Drag lock-strength slider 0-100% | Slider value | Vision framework: contour/edge extraction + depth estimation; dual condition maps injected into render | Fidelity badge (SF Mono) shown on result | Slider persisted per project | Rendered geometry matches input layout at ≥80% lock; badge reflects strength |
| 7 | Before/After comparison | 1. Result reveals → 2. Drag slider left/right | Drag gesture | Composite two images with moving divider | Interactive comparison view; auto-saved to project | SwiftData: both versions | Comparison available immediately after render; works in result view |
| 8 | Tap-to-Edit | 1. Finger circle a region → 2. Type instruction ("make sofa black leather") → 3. Confirm | Stroke points + text instruction | Instance mask segmentation → masked inpainting with edge/depth conditions ("edit only masked area; keep everything else identical") | Edited image; untouched pixels identical | SwiftData: new version node | Only masked region changes; rest pixel-identical; new version in timeline |
| 9 | Style Quad (one image → 4 styles) | 1. Tap Style Quad → 2. 2x2 grid generates (~60s) → 3. Tap a cell to adopt or export comparison long-image | Current image + 4 style selections | 4 parallel structured renders | 2x2 grid + exportable long comparison image | SwiftData: quad record | 4 distinct renders in one shot; one-tap export of comparison sheet |
| 10 | Shop the Look | 1. Open a render → 2. Tap Shop the Look → 3. Product cards list | Render image | Vision/AI furniture identification → matched real purchasable items (affiliate links) | Furniture cards (name, style, price, link) | None (live query) | Real product links open in Safari; works in free tier |
| 11 | Projects & version timeline | 1. Projects tab → 2. Open project → 3. Browse version tree, rollback | Project selection | SwiftData fetch; version tree navigation | Project list, version timeline, restore | SwiftData: Project/RenderVersion entities | Any prior version restorable; recent projects on home rail |
| 12 | Export suite | 1. Result view → Export → 2. Choose 4K PNG / style comparison long image / Concept Sketch PDF | Export choice + optional "Concept Sketch" badge checkbox | Image upscale to 4K (Real-ESRGAN-class), PDF composer with fidelity statement + commercial license page | Files to share sheet | Files app on save | 4K PNG export; PDF contains geometry-fidelity declaration + license; badge optional |
| 13 | Paywall (StoreKit 2, 4 tiers) | 1. Pro tab or upgrade prompt → 2. See all 4 prices on one screen + one-tap cancel note → 3. Purchase | Plan selection | StoreKit 2 Product.purchase; entitlement refresh | Entitlements (quota, features) | StoreKit 2 + UserDefaults mirror | Free: 3 HD/day + unlimited previews. Pro $12.99/mo, $79.99/yr, $149 lifetime. Studio $29.99/mo, $199/yr. All prices visible pre-purchase |
| 14 | BYO API key | 1. Settings → Advanced → paste fal.ai/Replicate/DeepSeek key | API key string | Keychain storage; router prefers BYO channel (unlimited, zero platform cut) | Unlimited cloud renders via user key | Keychain | Key persisted in Keychain only; BYO renders unlimited; compliance: no free-generation counting |
| 15 | Honest free tier | Automatic; quota shown on first screen | N/A | Daily cloud counter (3/day), 72h full-feature no-watermark trial from first launch | Quota label "3 free HD renders today + unlimited quick previews" | UserDefaults: daily date + count; first-launch timestamp | Counter resets daily; trial expiry honored; no registration wall ever |
| 16 | Conversational iteration | 1. Open project chat → 2. Type "walnut floor, dusk light" → 3. New version in ~30s | Text instruction + current version | Prompt merge → router → render → new version node | Chat-style history with version thumbnails | SwiftData: messages + versions | Instruction produces new version linked in timeline; rollback supported |
| 17 | Widget / Siri shortcut | 1. Lock-screen widget "Render last room" → 2. Or "Hey Siri, Sketcho my sketch" | App Intent trigger | Load last project → start render | App opens to in-progress render | App Intents registration | Widget and Siri phrase both launch render of last project |
| 18 | Transparent onboarding | First launch: single question "What are we rendering today?" + big capture button + recent projects rail + free-quota text | None | Static layout | Home screen | None | No onboarding questionnaire; price/quota visible on first screen; first image requires zero account |

### Sub-Features & Detail Interactions

| # | Parent Feature | Sub-Feature | Detail Description | Interaction Pattern |
|---|---------------|-------------|-------------------|--------------------|
| 6.1 | Lock Mode | Lock-strength slider | 0-100% maps to ControlNet canny weight; depth weight = max(0.4, lock-0.2) | Continuous slider drag |
| 6.2 | Lock Mode | Fidelity badge | "Geometry fidelity" badge in SF Mono showing effective lock % | Passive display on result |
| 3.1 | AI Router | Structured prompt schema | @Generable: positive (40-80 words), negative, style enum, lockStrength 0-1 | Automatic |
| 3.2 | AI Router | Prompt template versioning | Every prompt template carries version number for regression testing | Automatic |
| 3.3 | AI Router | Timeout degradation | Cloud >30s → auto-fallback to on-device preview explicitly labeled "Preview quality" | Automatic + user notice |
| 3.4 | AI Router | Cost transparency | Before each cloud render, local estimate shown: "Uses 1 free HD render today" | Inline label on render button |
| 4.1 | On-device render | Model on-demand download | SDXL-Turbo CoreML ~900MB downloaded on first use with progress page explaining purpose | One-tap download w/ progress |
| 5.1 | Cloud render | Dual conditioning | canny + depth images sent as data URIs; lock≥0.8 in lock mode | Automatic |
| 8.1 | Tap-to-Edit | Mask preview | Highlighted mask region shown before confirm | Visual overlay |
| 9.1 | Style Quad | Swappable styles | 2x2 styles replaceable (modern/scandinavian/industrial/japandi default) | Tap cell style chip |
| 10.1 | Shop the Look | Share card | Render + shoppable list composed into shareable card | Share sheet |
| 11.1 | Projects | Project folders | Organize renders into named projects | List + create/rename |
| 12.1 | Export | Concept Sketch badge | Optional "Concept Sketch" corner badge + compliance PDF | Checkbox in export sheet |
| 13.1 | Paywall | One-tap cancel disclosure | "Cancel anytime in Settings" text on paywall | Static text |
| 15.1 | Free tier | 72h trial | Full features no watermark for 72h from first launch | Automatic |
| 18.1 | Home | Recent projects rail | Horizontal scroll of recent projects under capture button | Horizontal scroll |

### Cross-Feature Dependencies

| Dependency | Source Feature | Target Feature | Data Passed | Trigger Condition |
|------------|---------------|----------------|-------------|-------------------|
| Capture → Render | #1 Capture | #4/#5 Render | Working image + vision condition maps | Image loaded |
| Style → Router | #2 Style | #3 Router | Style fragment into structured prompt | Style selected |
| Router → Renderers | #3 Router | #4/#5 Render | RenderPlan (channel + prompt) | Render requested |
| Render → Compare | #4/#5 Render | #7 Compare | Before + after images | Render completes |
| Render → Projects | #4/#5 Render | #11 Projects | Version node | Render completes |
| Render → TapToEdit | #5 Render | #8 TapToEdit | Base image | User taps edit |
| Render → StyleQuad | #5 Render | #9 StyleQuad | Base image + conditions | User taps quad |
| Render → ShopLook | #5 Render | #10 ShopLook | Final image | User taps shop |
| Render → Export | #4/#5 Render | #12 Export | Final image + metadata | User taps export |
| Paywall → Router | #13 Paywall | #3 Router | Entitlements (quota/BYO) | Entitlement change |
| BYO key → Router | #14 BYO | #3 Router | Key presence flag | Key saved |
| Chat → Render | #16 Chat | #3 Router | Instruction + current version | Message sent |
| App Intents → Projects | #17 Widget/Siri | #11 Projects | Last project ID | Intent invoked |

**VERIFICATION CHECK**: Guide sections 五/六 describe 18 primary capabilities — all 18 listed above. ✅

## ⚠️ App Store Compliance — AI Features

### Apple Intelligence (Default Free AI Backend)
This app uses Apple Intelligence (on-device Foundation Models + Private Cloud Compute) as the default AI backend. On supported devices (iPhone 15 Pro+, iOS 26+), AI features work immediately after download with zero configuration.

- **iOS 26+**: Apple Intelligence default. AI prompt generation works out-of-the-box.
- **iOS < 26**: Apple Intelligence unavailable → template-based prompt engine fallback (per guide risk item 6). UI may offer BYO key.
- **Simulator**: Apple Intelligence unavailable → use BYO key or template fallback for testing.

### BYO API Key (Optional)
Settings → Advanced: custom API key (fal.ai / Replicate / DeepSeek). Stored in Keychain ONLY. BYO renders are unlimited, zero platform cut.

### Guideline 2.1(a) — App Completeness
1. Create `app_review_info.md` with demo key instructions for reviewers on older devices.
2. NEVER show AI buttons that dead-end without a backend — template fallback always renders.
3. `canGenerate` logic: `isPremium || hasAPIKey || appleIntelligenceAvailable` — **no free generation counting**.

### Dead Code Prevention
- ❌ NEVER add: `freeGenerationsUsed`, `maxFreeGenerations`, `canGenerateFree`, `incrementGenerationCount()`
- Note: the *daily HD cloud quota (3/day)* is a rendering-quota concept distinct from AI text generation — implement as cloud render quota, not AI availability gate.

## ⚠️ App Store Compliance — Subscriptions

### Guideline 3.1.2(c) — Subscription Information
Paywall MUST include: functional Privacy Policy link, functional Terms of Use (EULA) link, subscription title/length/price for all tiers, auto-renewal disclosure text.

### BYO Key + Subscription Model
- Subscription value: "Unlock Premium Features" — NOT "Unlimited AI Generations"
- Paywall leads with app features (4K export, Tap-to-Edit, Style Quad, commercial license)
- AI generation is ALWAYS unlimited for users with their own key
- Lifetime ($149) includes BYO unlimited + on-device; platform cloud renders NOT included (API cost red line) — disclose on paywall

## Apple Design Guidelines Compliance

- **iOS 26 Liquid Glass** native feel + Large Title navigation; no cross-platform Material look
- **Dark-first** color scheme (architects/designers favor dark workflows); single accent Warm Amber #FF9F0A ("warm light of rendering"), neutral grays elsewhere
- **One-handed priority**: all core actions in bottom 1/3; 64pt circular floating capture button; no hamburger menu; 3 tabs: Create (home) / Projects / Pro
- **Home screen**: only "What are we rendering today?" + big capture button + recent projects rail; NO onboarding questionnaire
- **Reveal animation**: result unveiled with 1.2s blur→sharp "developing" animation (photo-developing ritual)
- **Typography**: SF Pro; SF Mono for fidelity badge/professional data
- **Accessibility**: full Dynamic Type; VoiceOver dual-axis description for comparison slider
- **Localization**: English-only at launch; string tables structured for V2 ES/FR

## Technical Architecture

- **Language**: Swift 5.9+
- **UI**: SwiftUI (iOS 26 SDK, minimum deployment iOS 17 with graceful feature degradation)
- **On-device AI understanding**: Foundation Models framework (AFM, free, offline) with template fallback
- **On-device generation**: Core ML + apple/ml-stable-diffusion (SDXL-Turbo quantized, 4-step)
- **Cloud generation**: fal.ai / Replicate (Flux.2 + ControlNet union: canny + depth)
- **BYO vision/reasoning**: DeepSeek API (furniture ID, prompt refinement)
- **Vision preprocessing**: Vision framework — contour/edge maps, depth estimation, instance masks
- **Payments**: StoreKit 2 native (no RevenueCat)
- **Local data**: SwiftData (projects, render versions, chat messages)
- **Networking**: URLSession async/await

### Three Data-Flow Reliability Iron Rules
1. **Condition maps first**: every render carries edge+depth (Lock Mode) or at least one (Inspire Mode) — geometry hallucination is eliminated by design.
2. **Degrade, never dead-end**: cloud timeout 30s → auto-fallback to on-device preview labeled "Preview quality". Never a black screen or infinite spinner.
3. **Auditable cost**: before every cloud render show local estimate ("Uses 1 free HD render today") — anti-credit-blackbox by design.

### Coding Rules (from guide §7.1)
1. ALL AI calls exit through AIRouter — feature pages never call APIs directly.
2. Every cloud call must have an on-device degradation path.
3. User images stay local by default; one-time upload consent dialog before first cloud render.
4. API keys stored ONLY in Keychain.
5. Every prompt template is version-numbered (regression testing on model upgrades).

## Module Structure

```
Sketcho/
├── App/SketchoApp.swift              # Entry + routing
├── Core/
│   ├── Router/AIRouter.swift         # 3-tier AI router (single exit point)
│   ├── PromptEngine/                 # AFM prompt gen + template fallback + material dictionary (200+ architecture terms)
│   ├── VisionKit/                    # Edge/depth/segmentation preprocessing
│   └── Render/
│       ├── OnDeviceRenderer.swift    # CoreML SD pipeline
│       └── CloudRenderer.swift       # fal.ai/Replicate + BYO
├── Features/
│   ├── Capture/                      # Shoot/import
│   ├── Chat/                         # Conversational iteration
│   ├── TapToEdit/                    # Masked inpainting editor
│   ├── StyleQuad/                    # 2x2 style grid
│   ├── ShopTheLook/                  # Furniture → product cards
│   ├── Compare/                      # Before/after slider
│   ├── Export/                       # 4K PNG / long image / PDF
│   └── Projects/                     # Project folders + version timeline
├── Pay/StoreService.swift            # StoreKit 2 four tiers
├── Data/SwiftDataStore.swift         # Persistence
└── Resources/StylePacks/             # Style JSON packs
```

## ⚠️ Data Flow Diagram (MANDATORY — Core Feature Lifecycles)

```
Feature: Render (core loop)
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── capture/import image + style tap + render tap        │
│       │                                                   │
│  Preprocessing (Core/VisionKit)                           │
│  └── edge map (contours) + depth map + dominant colors    │
│       │                                                   │
│  ViewModel (RenderViewModel)                              │
│  └── build RenderIntent → AIRouter.resolve()              │
│       ├── AFM/template → StructuredPrompt (@Generable)    │
│       └── channel: BYO > free-quota cloud > on-device     │
│       │                                                   │
│  Execution (Core/Render)                                  │
│  └── OnDeviceRenderer (CoreML SD 4-step)                  │
│       OR CloudRenderer (fal.ai Flux+ControlNet, 30s cap)  │
│       OR BYO CloudRenderer (user key, unlimited)          │
│       │  timeout → degrade to on-device + label           │
│       │                                                   │
│  Post-process                                             │
│  └── upscale → result image + fidelity badge              │
│       │                                                   │
│  Persistence (SwiftData)                                  │
│  └── RenderVersion node in Project (original + conditions │
│      + prompt + channel + timestamp)                      │
│       │                                                   │
│  Display Output                                           │
│  └── 1.2s reveal animation → Before/After slider          │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── enables TapToEdit / StyleQuad / ShopLook / Export    │
└───────────────────────────────────────────────────────────┘

Feature: TapToEdit
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── finger stroke points + text instruction              │
│       │                                                   │
│  ViewModel (TapToEditViewModel)                           │
│  └── instance mask from strokes → preview overlay         │
│       │                                                   │
│  Processing                                               │
│  └── CloudRenderer.inpaint(image, mask, "edit only masked │
│      area: <instruction>; keep everything else identical",│
│      edge, depth)  ← dual conditions lock other pixels    │
│       │                                                   │
│  Persistence + Display                                    │
│  └── new RenderVersion → timeline → compare slider        │
└───────────────────────────────────────────────────────────┘

Feature: Paywall → Entitlements
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── plan tap → StoreKit 2 purchase                       │
│       │                                                   │
│  ViewModel (PaywallViewModel → StoreService)              │
│  └── Product.purchase() → entitlement refresh → mirror to │
│      UserDefaults (quota date/count, trial timestamp)     │
│       │                                                   │
│  Consumers                                                │
│  └── AIRouter (channel decision), ExportView (watermark/  │
│      4K), TapToEdit/StyleQuad (feature gates)             │
└───────────────────────────────────────────────────────────┘
```

**VERIFICATION CHECK**: All 18 features trace input→processing→persistence→display. ✅

## Implementation Flow

1. Project skeleton: tabs (Create/Projects/Pro), SwiftData models (Project, RenderVersion, ChatMessage), design tokens (dark + #FF9F0A)
2. Capture/import + Vision preprocessing (edge, depth, dominant color, room-type rough classification)
3. PromptEngine: AFM structured generation + versioned template fallback + material dictionary
4. AIRouter: tier resolution + quota accounting + cost display + degradation path
5. OnDeviceRenderer: CoreML SD integration + on-demand model download (~900MB, progress page)
6. CloudRenderer: fal.ai Flux.2 ControlNet-union (canny+depth, lock weights), 30s timeout, BYO variant
7. Before/After compare view + 1.2s reveal animation
8. TapToEdit: instance mask → inpainting
9. StyleQuad: 4-way parallel render + comparison long-image export
10. ShopTheLook: furniture recognition → product cards + share card
11. Chat iteration + version timeline + rollback
12. Export suite: 4K PNG, comparison sheet, Concept Sketch PDF (badge + fidelity statement + license)
13. StoreService: 4 tiers, quota logic, 72h trial, entitlements
14. Widget + Siri App Intent (render last project)
15. Onboarding transparency pass: first-screen quota text, no walls, price sheet complete
16. Accessibility + localization strings + App Review info

## Pricing (summary — details in price.md)

| Tier | Price | Contents |
|------|-------|----------|
| Free | $0 | 3 HD cloud renders/day + unlimited on-device previews + project folders + basic export (light badge) |
| Pro | $12.99/mo · $79.99/yr · $149 lifetime | No-watermark 4K, Tap-to-Edit, Style Quad, full Lock Mode, commercial license, unlimited projects, BYO key unlimited |
| Studio | $29.99/mo · $199/yr | Pro + batch 16, priority queue, team folders, client demo mode, white-label export |

## Build & Deployment Checklist

1. Naming pre-check: App Store Connect search "Sketcho"; USPTO Class 9/42
2. Apple AI free-tier verification (PCC quota, iOS 26+)
3. AI content compliance: report-entry for generated content; privacy label "image processing on device"; watermark/badge policy in terms
4. Copyright terms: user owns uploads and outputs; no training on user data (in EULA — trust selling point)
5. On-device model ~900MB on-demand download (app stays under 200MB cellular limit)
6. Degradation matrix: <8GB RAM devices → no on-device render (free cloud quota unchanged); no Apple Intelligence → template prompt engine
7. First review: reserve 1 week; subscription price table screenshot ready
8. Simulator cleanup after testing: `bash /Users/macmini4/.trae-cn/skills/ios-app-developer/scripts/cleanup_simulators.sh after_test <UDID>`

## Open-Source References (from guide)

| Project | Reuse | License |
|---------|-------|---------|
| Nutlope/roomGPT | Upload→style→generate interaction skeleton | MIT |
| apple/ml-stable-diffusion | CoreML conversion tools + Swift inference | Apple license (use SDXL-Turbo commercial weights) |
| lllyasviel/ControlNet | canny/depth/lineart weights | Apache-2.0 |
| facebookresearch/segment-anything | Segmentation (or Vision instance masks on-device) | Apache-2.0 |
| Real-ESRGAN | On-device 2K→4K upscale | BSD-3 |
| bankaino/comfyui-sketch-to-interior-render | ComfyUI workflow node order → app pipeline | Check repo |
