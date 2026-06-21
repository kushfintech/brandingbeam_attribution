# brandingbeam_attribution

BrandingBeam deep linking & attribution SDK for Flutter (Android + iOS).

- **Deferred deep linking** — resolve the link a user clicked *before* installing.
  - **Android**: deterministic via the Google Play **Install Referrer**.
  - **iOS**: probabilistic match (scored server-side) — the SDK polls briefly while it resolves.
- **Conversion tracking** — `trackLead` (signup) and `trackSale` (purchase + revenue), stitched to
  the originating click → campaign.
- Authenticated with a **publishable key** (`pk_...`) — safe to ship in your app binary.

## Install

From git:

```yaml
dependencies:
  brandingbeam_attribution:
    git:
      url: https://github.com/kushfintech/brandingbeam_attribution.git
      ref: v0.0.1   # or main
```

### Android
The Play Install Referrer dependency is bundled. No extra setup. For App Links, declare your
`assetlinks.json` (served by the BrandingBeam link domain) and an intent filter for your domain.

### iOS
Enable **Associated Domains** and add `applinks:your-link-domain` so Universal Links open the app.

## Usage

```dart
import 'package:brandingbeam_attribution/brandingbeam_attribution.dart';

final sdk = BrandingbeamAttribution();

void main() {
  sdk.init(
    publishableKey: 'pk_live_xxxxxxxx',     // from the BrandingBeam dashboard → SDK & Settings
    baseUrl: 'https://api.yourdomain.com',  // your BrandingBeam backend
  );
  runApp(const MyApp());
}

// On first open (and when launched from a deep link):
final result = await sdk.trackOpen(); // optionally pass the opened deepLink
if (result.deepLink != null) {
  router.go(result.deepLink!);          // route the user to the right screen
  // result.data holds any custom key-values configured on the link
}

// Later, when the user signs up / purchases:
await sdk.trackLead(customerExternalId: user.id, customerEmail: user.email);
await sdk.trackSale(customerExternalId: user.id, amount: 1999, currency: 'USD'); // cents
```

`trackOpen` persists the resolved `clickId`; `trackLead`/`trackSale` automatically reference it so
revenue rolls up to the originating link and campaign.

## API

| Method | Description |
| --- | --- |
| `init({publishableKey, baseUrl})` | Configure the SDK. Call once at startup. |
| `trackOpen({deepLink})` → `AttributionResult` | Resolve deferred/direct deep link + attribution. |
| `trackLead({customerExternalId, customerName?, customerEmail?, eventName?})` | Record a signup. |
| `trackSale({customerExternalId, amount, currency, eventName?, invoiceId?})` | Record a purchase. |

`AttributionResult`: `installId`, `status` (`matched`/`pending`), `matchType`
(`deterministic`/`probabilistic`/`none`), `clickId`, `deepLink`, `campaign`, `data`.
