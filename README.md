# AAPS Garmin Combined Widget

A combined Garmin Connect IQ widget that merges three separate AAPS control widgets and a glucose monitoring display into a single app.

## Credits

**All credit goes to [swissalpine](https://github.com/swissalpine)**, who created the original AAPS Garmin widgets and the Garmin plugin for AAPS. This combined widget is built entirely on top of his work:

- [AAPS-Garmin-BolusWidget](https://github.com/swissalpine/AAPS-Garmin-BolusWidget)
- [AAPS-Garmin-CarbsWidget](https://github.com/swissalpine/AAPS-Garmin-CarbsWidget)
- [AAPS-Garmin-TempTargetWidget](https://github.com/swissalpine/AAPS-Garmin-TempTargetWidget)

## Features

- **Bolus** — Administer insulin boluses to AAPS (preset values or custom with ±0.1 U increments)
- **Carbs** — Enter carbohydrates to AAPS (preset values or custom with ±1 g increments)
- **TempTarget** — Set temporary targets in AAPS in mmol/l (preset values or custom with ±0.1 mmol/l and ±5 min increments)

## How it works

1. Open the widget — glucose data is displayed immediately
2. Press SELECT to open the action menu (Bolus / Carbs / TempTarget)
3. Choose a preset value or select "Custom value..." to dial in your own
4. Review the confirmation screen (glucose data visible at the top)
5. Press SELECT to send to AAPS

## Configuration

Edit `source/settings.mc` to configure the endpoint URLs:

```
var bolusUrl = "http://127.0.0.1:28891/bolus";
var carbsUrl = "http://127.0.0.1:28891/carbs";
var tempTargetUrl = "http://127.0.0.1:28891/temptarget";
```

Glucose data is fetched from `http://127.0.0.1:28891/get` (the standard AAPS Garmin plugin endpoint).

## Prerequisites

The necessary adjustments in AAPS are currently not available in either the dev or master versions. They are only available in the modified AAPS version by swissalpine.
At your own risk, you must copy the Garmin plugin folders and paste them into your own version:

Version 3.3.2:
- https://github.com/swissalpine/AndroidAPS/tree/sport-changes-3.3.2.0/plugins/sync/src/main/kotlin/app/aaps/plugins/sync/garmin
- https://github.com/swissalpine/AndroidAPS/tree/sport-changes-3.3.2.0/plugins/sync/src/androidTest/kotlin/app/aaps/plugins/sync/garmin

Version 3.3.3:
- https://github.com/swissalpine/AndroidAPS/tree/3.3.3-mod-alpha/plugins/sync/src/test/kotlin/app/aaps/plugins/sync/garmin
- https://github.com/swissalpine/AndroidAPS/tree/3.3.3-mod-alpha/plugins/sync/src/androidTest/kotlin/app/aaps/plugins/sync/garmin

## Building

Build with Visual Studio Code and the Monkey C extension. Install on the watch via sideloading.

## Disclaimer

**This software is provided as-is. Just because it works for one person does not guarantee it will work for you. Use at your own risk. If in doubt, don't use it.**
