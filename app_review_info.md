# App Review Information

## Demo Instructions for Apple Review

Sketcho works immediately after download with no account, no sign-in, and no API key:

1. Launch the app. The home screen shows the daily free quota: 3 free HD renders/day + unlimited free on-device previews (first 72 hours: all Pro features unlocked, no watermark).
2. Tap the large camera button to shoot a room (or tap "Photo Library" / "Try a Sample" on the simulator).
3. Pick a style (Modern / Scandinavian / Industrial / Japandi / Farmhouse / Mid-century), optionally drag the Lock Mode slider, then tap "Preview".
4. A before/after comparison slider appears with the result. Tap into the result for: Export (4K PNG / comparison image / Concept Sketch PDF), Tap to Edit, Style Quad, and chat-style iteration.
5. Projects tab stores every render with a version timeline; roll back to any version.

### Optional API Keys (Cloud HD + Furniture ID)
HD cloud rendering and furniture identification use a "Bring Your Own API Key" model:
1. Settings → "Advanced: Configure Custom API"
2. Enter a fal.ai API key for HD cloud rendering, and/or a DeepSeek API key for furniture identification (Shop the Look)
3. Keys are stored in the device Keychain only

Without keys, the app remains fully functional: rendering falls back to the on-device engine and is clearly labeled "Preview quality (enhanced)". There are no dead-end buttons.

### Subscription Testing
Product IDs (subscription group "Sketcho Pro"):
- `com.zzoutuo.Sketcho.pro.monthly` — $12.99/month
- `com.zzoutuo.Sketcho.pro.yearly` — $79.99/year
- `com.zzoutuo.Sketcho.pro.lifetime` — $149.00 one-time, non-consumable
- `com.zzoutuo.Sketcho.studio.monthly` — $29.99/month
- `com.zzoutuo.Sketcho.studio.yearly` — $199.00/year

Free tier: 3 HD cloud renders/day, unlimited on-device previews, project folders, basic export. 72-hour full-feature trial from first launch (in-app, does not auto-convert).

### Required Links (In-App)
- Privacy Policy: https://asunnyboy861.github.io/Sketcho/privacy.html
- Terms of Use: https://asunnyboy861.github.io/Sketcho/terms.html
- Support Page: https://asunnyboy861.github.io/Sketcho/support.html

Accessible from Settings → Legal, and directly inside the Paywall below the purchase options.

## Review Notes

### AI Rendering (BYO Key Model)
- Rendering works out-of-the-box via the built-in on-device engine — no configuration needed to test
- HD cloud rendering optionally uses the user's own fal.ai API key; furniture identification optionally uses the user's own DeepSeek API key
- The app does NOT sell API keys or AI usage; no AI provider is promoted in the UI
- API keys are stored in the device Keychain only
- Generated-image reporting/compliance: user uploads and outputs remain on-device unless the user opts into cloud rendering; images are never used for model training

### Subscriptions
- All four price points are visible on one paywall screen before purchase
- Auto-renewal disclosure and "cancel anytime in Settings" text are on the paywall
- Privacy Policy and Terms of Use links are functional and located below the purchase options
- Restore Purchases is available on both the paywall and Settings

### China App Store Compliance
This app does NOT include ChatGPT functionality or reference ChatGPT/OpenAI in any user-facing UI or metadata. Rendering uses a built-in on-device engine plus a generic "Bring Your Own API Key" model where users configure their own provider endpoints. No specific AI provider is promoted or bundled.
