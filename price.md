# Pricing Configuration

## Monetization Model: Subscription (IAP) + Lifetime Buyout

Freemium with auto-renewable subscriptions (Pro, Studio) plus one-time lifetime buyout. Honest free tier with 3 HD cloud renders/day and unlimited on-device previews. Pricing is shown transparently on the first screen and paywall; one-tap cancel disclosure included. BYO API key is available to any paid tier for unlimited cloud renders.

## Subscription Group
- **Group Name**: Sketcho Pro
- **Reference Name**: Sketcho Pro
- **Products in group**: Pro Monthly, Pro Annual, Studio Monthly, Studio Annual (auto-renewable only)

## Subscription Tiers (Auto-Renewable)

### 1. Pro Monthly
- **Reference Name**: Sketcho Pro Monthly
- **Product ID**: `com.zzoutuo.Sketcho.pro.monthly`
- **Type**: Auto-renewable subscription
- **Price**: $12.99 USD per month
- **Display Name**: `Sketcho Pro Monthly` (19 chars, ≤35 ✅)
- **Description**: `4K export, Tap-to-Edit, Style Quad, full Lock Mode` (51 chars, ≤55 ✅)
- **Localization**: English (US)
- **Subscription Group**: Sketcho Pro
- **Restore Purchases**: ✅ Required

### 2. Pro Annual
- **Reference Name**: Sketcho Pro Annual
- **Product ID**: `com.zzoutuo.Sketcho.pro.yearly`
- **Type**: Auto-renewable subscription
- **Price**: $79.99 USD per year (49% savings vs monthly)
- **Display Name**: `Sketcho Pro Annual` (18 chars, ≤35 ✅)
- **Description**: `All Pro features, billed yearly. Save 49%.` (42 chars, ≤55 ✅)
- **Localization**: English (US)
- **Subscription Group**: Sketcho Pro (same group as monthly)
- **Restore Purchases**: ✅ Required

### 3. Studio Monthly
- **Reference Name**: Sketcho Studio Monthly
- **Product ID**: `com.zzoutuo.Sketcho.studio.monthly`
- **Type**: Auto-renewable subscription
- **Price**: $29.99 USD per month
- **Display Name**: `Sketcho Studio Monthly` (22 chars, ≤35 ✅)
- **Description**: `Pro features plus batch 16 and client demo mode` (47 chars, ≤55 ✅)
- **Localization**: English (US)
- **Subscription Group**: Sketcho Pro
- **Restore Purchases**: ✅ Required

### 4. Studio Annual
- **Reference Name**: Sketcho Studio Annual
- **Product ID**: `com.zzoutuo.Sketcho.studio.yearly`
- **Type**: Auto-renewable subscription
- **Price**: $199.00 USD per year (45% savings vs monthly)
- **Display Name**: `Sketcho Studio Annual` (21 chars, ≤35 ✅)
- **Description**: `All Studio features, billed yearly. Save 45%.` (45 chars, ≤55 ✅)
- **Localization**: English (US)
- **Subscription Group**: Sketcho Pro (same group)
- **Restore Purchases**: ✅ Required

## One-Time Purchases (Non-Consumable)

### 1. Pro Lifetime
- **Reference Name**: Sketcho Pro Lifetime
- **Product ID**: `com.zzoutuo.Sketcho.pro.lifetime`
- **Type**: Non-consumable (one-time purchase, permanently unlocked)
- **Price**: $149.00 USD (one-time)
- **Display Name**: `Sketcho Pro Lifetime` (20 chars, ≤35 ✅)
- **Description**: `All Pro features forever. BYO key unlimited renders.` (52 chars, ≤55 ✅)
- **Localization**: English (US)
- **Restore Purchases**: ✅ Required
- **Note**: No ongoing platform cost for on-device and BYO key rendering.
- **⚠️ DIFFERENTIATION NOTE**: Lifetime includes ALL Pro features plus unlimited BYO-key cloud renders, but does NOT include platform-hosted cloud render quota (daily free quota and user BYO keys apply) and does NOT include Studio batch/demo features. Choose it to pay once instead of recurring billing.

## Free Tier (Default)

- **Price**: Free
- **Features**:
  - 3 HD cloud renders per day (quota shown on home screen)
  - Unlimited on-device quick previews (works offline)
  - Project folders with version timeline
  - Basic export (light "Concept Sketch" badge)
  - 72-hour full-feature no-watermark experience from first launch
- **Conversion hooks**:
  - 3 free HD renders every day — forever, no credit packs
  - Unlimited quick previews, even offline
  - First 72 hours: every Pro feature unlocked, no watermark
  - Cancel anytime in Settings — one tap

## Pro Features Unlocked (All Paid Tiers)

Cross-referenced with capabilities.md — all features confirmed implementable in code.

| Feature | Free | Pro (Subscriptions + Lifetime) | Studio |
|---------|:----:|:------------------------------:|:------:|
| On-device quick previews | ✅ Unlimited | ✅ Unlimited | ✅ Unlimited |
| HD cloud renders | 3/day | ✅ Fair-use unlimited + BYO key unlimited | ✅ Fair-use unlimited + BYO key unlimited |
| 4K export, no watermark | ❌ (72h trial only) | ✅ | ✅ |
| Tap-to-Edit (masked inpainting) | ❌ (72h trial only) | ✅ | ✅ |
| Style Quad (2x2 grid) | ❌ (72h trial only) | ✅ | ✅ |
| Lock Mode full strength + fidelity badge | ❌ (72h trial only) | ✅ | ✅ |
| Commercial license + Concept Sketch PDF | ❌ | ✅ | ✅ |
| Unlimited project folders | ✅ Basic | ✅ | ✅ |
| BYO API key (fal.ai/Replicate/DeepSeek) | ✅ Configurable | ✅ Unlimited renders | ✅ Unlimited renders |
| Batch 16 styles | ❌ | ❌ | ✅ |
| Priority queue | ❌ | ❌ | ✅ |
| Client demo mode (read-only link/PDF) | ❌ | ❌ | ✅ |
| White-label export | ❌ | ❌ | ✅ |

## Free Trial
- **Duration**: None as a StoreKit free trial. In-app 72-hour full-feature experience (no watermark) from first launch; free tier with daily quotas continues afterward. Subscriptions do not auto-convert from the trial.

## BYO Key Model: Premium Features Unlock

### Free Tier (with own API key)
- Cloud rendering via user's own fal.ai/Replicate/DeepSeek key: ✅ Unlimited
- On-device previews: ✅ Unlimited
- Basic export and projects: ✅

### Premium Subscription Unlocks
- 4K no-watermark export, Tap-to-Edit, Style Quad, full Lock Mode, commercial license
- Studio: batch 16, priority queue, client demo mode, white-label export

### Subscription Value Proposition
"Unlock Premium Features" — NOT "Unlimited AI Generations". AI/cloud rendering is ALWAYS unlimited for users with their own API key. Paywall leads with app features, not AI usage.

## Policy Pages Required
- Support Page: ✅ (must include subscription management + cancellation instructions)
- Privacy Policy: ✅
- Terms of Use (EULA): ✅ (REQUIRED — subscription apps must have Terms)
- **Total policy pages**: 3

## Apple IAP Compliance Checklist
- [x] Auto-renewal terms will be included in Terms of Use
- [x] Cancellation instructions will be included in Support Page
- [x] Pricing clearly stated in PaywallView (all four price points + cancel disclosure)
- [x] 72h in-app trial terms disclosed (not a StoreKit auto-converting trial)
- [x] Restore purchases functionality implemented (StoreKit 2 `Transaction.currentEntitlements`)
- [x] No external payment links (Guideline 3.1.1)
- [x] No price references to outside-App-Store options
- [x] All IAP descriptions ≤ 55 characters
- [x] All IAP display names ≤ 35 characters
- [x] IAP type purity: non-consumable Lifetime separated from auto-renewable tiers
- [x] BYO Key model: subscription gated only by features, never AI generation counting (`freeGenerationsUsed` / `maxFreeGenerations` forbidden dead code)
