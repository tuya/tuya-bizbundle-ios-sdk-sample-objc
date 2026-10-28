# AIRecom Demo replacement images

The page has two cards: business settings and images with **Save configuration**, and `pid`/`content`/`send` with **Open page**. Each button sits at the bottom of its own card. The configuration page lets you select each example image independently. Selected images are loaded from `Images.xcassets/AIRecomDemo` and assigned to the corresponding public `ThingAIRecomBizConfig` UIImage property. Clearing a selection leaves that property nil. The demo restores saved configuration after initializing the BizBundle service at app launch. Editing settings or selecting images only changes the page draft. Tap **Save configuration** below the image section to persist and apply the settings for newly opened conversations and device panels. The separate **Open page** button uses the current `pid`, `content`, and `send` parameters without saving pending configuration changes. Entry parameters are remembered independently and do not apply business configuration. Existing views are not refreshed automatically. Each field uses two lines: title and **?** help above, then the key on the left and the current value, image selection or switch on the right. Help appears as a toast instead of a section footer.

| Public property | Asset name | @3x pixels |
| --- | --- | --- |
| logo | demo_airecom_logo | 108 × 108 |
| chat_title_logo_light | demo_airecom_chat_title_logo_light | 285 × 60 |
| chat_title_logo_dark | demo_airecom_chat_title_logo_dark | 285 × 60 |
| plus_badge_light | demo_airecom_plus_badge_light | 150 × 78 |
| plus_badge_dark | demo_airecom_plus_badge_dark | 150 × 78 |
| plus_star_badge | demo_airecom_plus_star_badge | 234 × 105 |

All images are transparent PNGs, generated with the built-in image_gen tool, then exported to the recommended @3x resource dimensions. They are demo artwork, independent of the BizBundle default assets.

## Generation prompts

Common constraints: Use case logo-brand. Generate one transparent PNG resource for AIRecom iOS demo. Genuine transparent background outside artwork. No checkerboard, mockup, labels, size annotations, watermark, or surrounding decoration. Keep legible at small UI size.

- Assistant logo: Minimal crisp friendly four-point sparkle nested in a soft rounded speech bubble, smooth violet-to-teal color accents, bold silhouette, readable at 36pt. Centered square composition, no text, no backdrop, no drop shadow outside icon. Requested 108x108 pixels, image fills 90% of the square.
- Light title: Exact text “AIRecom” in bold, friendly modern black rounded sans-serif, one tiny simple four-point sparkle on the left, same black color. Flat monochrome black, no gradients. Very wide horizontal composition, aspect ratio 285:60. Fill width and height with modest 4% margins.
- Dark title (edit using the light title as reference): Change only the artwork color to pure solid white. Keep exactly the text AIRecom, layout, typography, sparkle, geometry, and transparent backdrop. Clean vector-like filled letters with smooth edges, solid opaque white interiors. No distress, texture, grain, holes, flecks, shadows, outlines, or extra objects. Wide 285:60 aspect ratio, centered wordmark filling almost all canvas, for a 95x20pt iOS navigation bar.
- Light subscription badge: Exact text “Plus” in bold white rounded sans-serif, inside a deep violet pill with subtle teal accent. Crisp clean flat iOS graphic, premium AI assistant style. Horizontal composition, aspect ratio 150:78. Pill fills almost full canvas with 5% transparent margins.
- Dark subscription badge: Exact text “Plus” in bold deep violet rounded sans-serif, inside a luminous pale lavender pill with subtle mint accent. Crisp clean flat iOS graphic, premium AI assistant style. Horizontal composition, aspect ratio 150:78. Pill fills almost full canvas with 5% transparent margins.
- Settings membership badge: One four-point violet-to-teal gradient sparkle followed by exact text “Plus” in bold deep violet rounded sans-serif, on a pale lavender rounded capsule. Crisp clean iOS graphic, premium AI assistant style. Horizontal aspect ratio 234:105. Capsule fills canvas with 5% transparent margins.
