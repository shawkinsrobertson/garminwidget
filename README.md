# AAPS Garmin Combined Widget

This is a combined Garmin Connect IQ widget that merges the three separate AAPS widgets into a single app:

- **Bolus** — Administer boluses to AAPS
- **Carbs** — Enter carbohydrates to AAPS
- **TempTarget** — Set temporary targets in AAPS

## How it works

1. Open the widget on your Garmin watch
2. Press SELECT to open the main menu
3. Choose your action: **Bolus**, **Carbs**, or **TempTarget**
4. Select your desired value from the sub-menu
5. Confirm by pressing SELECT to send to AAPS

## Configuration

Edit `source/settings.mc` to configure the URLs for each endpoint:

```
var bolusUrl = "http://127.0.0.1:28891/bolus";
var carbsUrl = "http://127.0.0.1:28891/carbs";
var tempTargetUrl = "http://127.0.0.1:28891/temptarget";
```

## Prerequisites

The necessary adjustments in AAPS are currently not available in either the dev or master versions. They are only available in the modified AAPS version.
At your own risk, you must copy the Garmin plugin folders and paste them into your own version:

Version 3.3.2:
- https://github.com/swissalpine/AndroidAPS/tree/sport-changes-3.3.2.0/plugins/sync/src/main/kotlin/app/aaps/plugins/sync/garmin
- https://github.com/swissalpine/AndroidAPS/tree/sport-changes-3.3.2.0/plugins/sync/src/androidTest/kotlin/app/aaps/plugins/sync/garmin

Version 3.3.3:
- https://github.com/swissalpine/AndroidAPS/tree/3.3.3-mod-alpha/plugins/sync/src/test/kotlin/app/aaps/plugins/sync/garmin
- https://github.com/swissalpine/AndroidAPS/tree/3.3.3-mod-alpha/plugins/sync/src/androidTest/kotlin/app/aaps/plugins/sync/garmin

## Building

Build with Visual Studio Code and the Monkey C extension. Install on the watch via sideloading.

**Once again: Just because it works for me, I cannot guarantee that it will work for you. If in doubt, it's better to leave this!**
