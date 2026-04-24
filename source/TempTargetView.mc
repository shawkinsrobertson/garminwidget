using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Communications as Comm;
using Toybox.Lang;

// =========================================================
// UNIT CONFIGURATION
// Set USE_MMOL to 1 for mmol/l, 0 for mg/dl
// =========================================================

#define USE_MMOL 0  // Change to 1 for mmol, 0 for mg/dl

#if USE_MMOL
  const TT_UNIT_LABEL  = " mmol/l";
  const TT_FIELD_LABEL = "Target (mmol/l)";
  const TT_FORMAT      = "%.1f";
  const TT_ROUND       = 10.0;
  const TT_DEFAULT     = 5.5;
  const TT_MIN         = 2.0;
  const TT_MAX         = 15.0;
  const TT_STEP        = 0.1;
  const TT_P1          = 4.4;
  const TT_P2          = 6.7;
  const TT_P3          = 7.8;
  const TT_P4          = 8.9;
#else
  const TT_UNIT_LABEL  = " mg/dl";
  const TT_FIELD_LABEL = "Target (mg/dl)";
  const TT_FORMAT      = "%.0f";
  const TT_ROUND       = 1.0;
  const TT_DEFAULT     = 100.0;
  const TT_MIN         = 36.0;
  const TT_MAX         = 270.0;
  const TT_STEP        = 1.0;
  const TT_P1          = 80.0;
  const TT_P2          = 120.0;
  const TT_P3          = 140.0;
  const TT_P4          = 160.0;
#endif


var ttDuration = 0;
var ttTarget = 0;
var ttError = null;
var ttAbfrage = 1; // 1: start, 2: selected, 3: waiting, 4: finished
var ttReason = "Activity";
var ttCircle = Gfx.COLOR_BLACK;
var ttErrorCircle = false;

// Custom picker temp values
var ttCustomTarget = TT_DEFAULT;
var ttCustomDuration = 60; // minutes
var ttCustomField = 0;     // 0 = editing target, 1 = editing duration
var ttOpenCustom = false;

class TempTargetBehaviorDelegate extends Ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
        ttCircle = Gfx.COLOR_BLACK;
        ttAbfrage = 1;
        ttDuration = 0;
        ttTarget = 0;
        ttError = null;
        ttReason = "Activity";
        ttErrorCircle = false;
        ttOpenCustom = false;
    }

    function onKey(keyEvent) {
        if( keyEvent.getKey() == 4 ) {
            if( ttAbfrage == 1 ) {
                showTTMenu();
            } else if( ttAbfrage == 2 ) {
                sendTempTarget();
                ttError = "Contacting\nAAPS...";
            } else if ( ttAbfrage == 3 ) {
                ttError = "Waiting for\nAAPS...";
            } else {
                ttError = "Click SELECT to start!";
                ttAbfrage = 1;
                ttTarget = 0;
                ttDuration = 0;
                ttCircle = Gfx.COLOR_BLACK;
            }
            Ui.requestUpdate();
            return true;
        }
        return false;
    }

    function onHold(touchEvent) {
        if( ttAbfrage == 1 ) {
            showTTMenu();
        } else if( ttAbfrage == 2 ) {
            sendTempTarget();
            ttError = "Contacting\nAAPS...";
        } else if ( ttAbfrage == 3 ) {
            ttError = "Waiting for\nAAPS...";
        } else {
            ttError = "Click SELECT to start!";
            ttAbfrage = 1;
            ttTarget = 0;
            ttDuration = 0;
            ttCircle = Gfx.COLOR_BLACK;
        }
        Ui.requestUpdate();
        return true;
    }

    function showTTMenu() {
        ttAbfrage = 2;
        var menu = new Ui.Menu();
        menu.setTitle("Choose TT");
        menu.addItem("Custom value...", :custom);
        menu.addItem("Cancel TT", :a);
        // Pre-selected values — labels derived from TT_P1–TT_P4 and TT_FORMAT (set by USE_MMOL above)
        menu.addItem(TT_P1.format(TT_FORMAT) + " @ 60m", :b);
        menu.addItem(TT_P1.format(TT_FORMAT) + " @ 120m", :c);
        menu.addItem(TT_P1.format(TT_FORMAT) + " @ 180m", :d);
        menu.addItem(TT_P2.format(TT_FORMAT) + " @ 60m", :e);
        menu.addItem(TT_P2.format(TT_FORMAT) + " @ 120m", :f);
        menu.addItem(TT_P2.format(TT_FORMAT) + " @ 180m", :g);
        menu.addItem(TT_P3.format(TT_FORMAT) + " @ 60m", :h);
        menu.addItem(TT_P3.format(TT_FORMAT) + " @ 120m", :i);
        menu.addItem(TT_P3.format(TT_FORMAT) + " @ 180m", :j);
        menu.addItem(TT_P3.format(TT_FORMAT) + " @ 240m", :k);
        menu.addItem(TT_P4.format(TT_FORMAT) + " @ 60m", :l);
        menu.addItem(TT_P4.format(TT_FORMAT) + " @ 120m", :m);
        menu.addItem(TT_P4.format(TT_FORMAT) + " @ 180m", :n);
        menu.addItem(TT_P4.format(TT_FORMAT) + " @ 240m", :o);
        WatchUi.pushView(menu, new TTMenuInputDelegate(), WatchUi.SLIDE_IMMEDIATE);
     }

    function sendTempTarget() {
        ttCircle = Gfx.COLOR_WHITE;
        var targetValue = null;
        if( ttTarget != null ) {
            targetValue = ttTarget.format("%.1f").toFloat();
        }
        Comm.makeWebRequest(tempTargetUrl,{"duration" => ttDuration, "target" => targetValue},{ :method => Comm.HTTP_REQUEST_METHOD_POST, :headers => { "Content-Type" => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON }, :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON}, method(:onTTResponse));
        ttAbfrage = 3;
        return true;
     }

     function onTTResponse( responseCode as Lang.Number, data as Lang.Dictionary or Lang.String or Null ) as Void {
        if( responseCode == 200 ) {
            Sys.println(data);
            ttError = "Submitted to\n AAPS";
            ttCircle = Gfx.COLOR_GREEN;
        } else {
            ttError = "Error: " + responseCode.toString();
            ttCircle = Gfx.COLOR_RED;
            ttErrorCircle = true;
        }
        ttAbfrage = 4;
        Ui.requestUpdate();
     }

}

class TTMenuInputDelegate extends Ui.MenuInputDelegate {

    function initialize() {
       MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        if (item == :custom) {
            ttCustomTarget = TT_DEFAULT;
            ttCustomDuration = 60;
            ttCustomField = 0;
            ttOpenCustom = true;
            return;
        }
        ttCircle = Gfx.COLOR_YELLOW;
        if (item == :a) {
            ttTarget = null; ttDuration = 0; ttReason = null;
        } else if (item == :b) {
            ttTarget = TT_P1; ttDuration = 60; ttReason = "Eating Soon";
        } else if (item == :c) {
            ttTarget = TT_P1; ttDuration = 120; ttReason = "Eating Soon";
        } else if (item == :d) {
            ttTarget = TT_P1; ttDuration = 180; ttReason = "Eating Soon";
        } else if (item == :e) {
            ttTarget = TT_P2; ttDuration = 60; ttReason = "Activity";
        } else if (item == :f) {
            ttTarget = TT_P2; ttDuration = 120; ttReason = "Activity";
        } else if (item == :g) {
            ttTarget = TT_P2; ttDuration = 180; ttReason = "Activity";
        } else if (item == :h) {
            ttTarget = TT_P3; ttDuration = 60; ttReason = "Activity";
        } else if (item == :i) {
            ttTarget = TT_P3; ttDuration = 120; ttReason = "Activity";
        } else if (item == :j) {
            ttTarget = TT_P3; ttDuration = 180; ttReason = "Activity";
        } else if (item == :k) {
            ttTarget = TT_P3; ttDuration = 240; ttReason = "Activity";
        } else if (item == :l) {
            ttTarget = TT_P4; ttDuration = 60; ttReason = "Activity";
        } else if (item == :m) {
            ttTarget = TT_P4; ttDuration = 120; ttReason = "Activity";
        } else if (item == :n) {
            ttTarget = TT_P4; ttDuration = 180; ttReason = "Activity";
        } else if (item == :o) {
            ttTarget = TT_P4; ttDuration = 240; ttReason = "Activity";
        }
    }
}

// -----------------------------------------------------------
// Two-field custom picker
// Field 0: target value   (UP = +TT_STEP, DOWN = -TT_STEP)
// Field 1: duration in min (UP = +5, DOWN = -5)
// SELECT on field 0 -> moves to field 1
// SELECT on field 1 -> confirms
// BACK on field 1 -> goes back to field 0
// -----------------------------------------------------------
class TTCustomPickerView extends Ui.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc) as Void {
    }

    function onUpdate(dc) as Void {
        var cx = dc.getWidth() * 0.5;
        var cy = dc.getHeight() * 0.5;

        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();

        // UP hint
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 65, Gfx.FONT_MEDIUM, "+", Gfx.TEXT_JUSTIFY_CENTER);

        if( ttCustomField == 0 ) {
            // Editing target
            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.drawText(cx, cy - 85, Gfx.FONT_XTINY, TT_FIELD_LABEL, Gfx.TEXT_JUSTIFY_CENTER);

            // Target value - highlighted
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(cx, cy - 15, Gfx.FONT_NUMBER_HOT, ttCustomTarget.format(TT_FORMAT), Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);

            // Duration value - dimmed
            dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.drawText(cx, cy + 38, Gfx.FONT_SMALL, ttCustomDuration.toString() + " min", Gfx.TEXT_JUSTIFY_CENTER);

            // Instruction
            dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
            dc.drawText(cx, cy + 70, Gfx.FONT_XTINY, "SELECT > set duration", Gfx.TEXT_JUSTIFY_CENTER);
        } else {
            // Editing duration
            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.drawText(cx, cy - 85, Gfx.FONT_XTINY, "Duration (min)", Gfx.TEXT_JUSTIFY_CENTER);

            // Target value - dimmed
            dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.drawText(cx, cy - 30, Gfx.FONT_SMALL, ttCustomTarget.format(TT_FORMAT) + TT_UNIT_LABEL, Gfx.TEXT_JUSTIFY_CENTER);

            // Duration value - highlighted
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(cx, cy + 15, Gfx.FONT_NUMBER_HOT, ttCustomDuration.toString(), Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);

            // Instruction
            dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
            dc.drawText(cx, cy + 70, Gfx.FONT_XTINY, "SELECT > confirm", Gfx.TEXT_JUSTIFY_CENTER);
        }

        // DOWN hint
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 50, Gfx.FONT_MEDIUM, "-", Gfx.TEXT_JUSTIFY_CENTER);
    }

}

class TTCustomPickerDelegate extends Ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // top-right = UP = increment
    function onPreviousPage() {
        if( ttCustomField == 0 ) {
            ttCustomTarget = ttCustomTarget + TT_STEP;
            ttCustomTarget = ((ttCustomTarget * TT_ROUND + 0.5).toNumber()).toFloat() / TT_ROUND;
            if( ttCustomTarget > TT_MAX ) { ttCustomTarget = TT_MAX; }
        } else {
            ttCustomDuration = ttCustomDuration + 5;
            if( ttCustomDuration > 480 ) { ttCustomDuration = 480; }
        }
        Ui.requestUpdate();
        return true;
    }

    // bottom-right = DOWN = decrement
    function onNextPage() {
        if( ttCustomField == 0 ) {
            ttCustomTarget = ttCustomTarget - TT_STEP;
            ttCustomTarget = ((ttCustomTarget * TT_ROUND + 0.5).toNumber()).toFloat() / TT_ROUND;
            if( ttCustomTarget < TT_MIN ) { ttCustomTarget = TT_MIN; }
        } else {
            ttCustomDuration = ttCustomDuration - 5;
            if( ttCustomDuration < 5 ) { ttCustomDuration = 5; }
        }
        Ui.requestUpdate();
        return true;
    }

    // middle = SELECT
    function onSelect() {
        if( ttCustomField == 0 ) {
            // Move to duration field
            ttCustomField = 1;
            Ui.requestUpdate();
        } else {
            // Confirm both values
            ttTarget = ttCustomTarget;
            ttDuration = ttCustomDuration;
            ttReason = "Activity";
            ttCircle = Gfx.COLOR_YELLOW;
            ttAbfrage = 2;
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        }
        return true;
    }

    function onKey(keyEvent) {
        var key = keyEvent.getKey();
        if( key == 4 ) {
            return onSelect();
        } else if( key == 13 ) {
            return onPreviousPage();
        } else if( key == 8 ) {
            return onNextPage();
        }
        return false;
    }

    // BACK on field 1 goes back to field 0
    function onBack() {
        if( ttCustomField == 1 ) {
            ttCustomField = 0;
            Ui.requestUpdate();
            return true;
        }
        return false;
    }
}

class TempTargetView extends Ui.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    function onShow() as Void {
        if( ttOpenCustom == true ) {
            ttOpenCustom = false;
            WatchUi.pushView(new TTCustomPickerView(), new TTCustomPickerDelegate(), WatchUi.SLIDE_LEFT);
        }
    }

    function onUpdate(dc) as Void {
        View.onUpdate(dc);

        var addPadding = dc.getWidth() >= 360 ? 15 : 0;
        // Circle
        dc.setColor(ttCircle, ttCircle);
        dc.fillCircle(dc.getWidth() * 0.5, dc.getHeight() * 0.5, dc.getHeight() * 0.5);
        if (ttErrorCircle == false ) {
            dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        } else {
            dc.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_BLACK);
            ttErrorCircle = false;
        }
        dc.fillCircle(dc.getWidth() * 0.5, dc.getHeight() * 0.5, dc.getHeight() * 0.5 - 5);

        // Title
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(
                dc.getWidth() * 0.5,
                dc.getHeight() * 0.5 + 10 - dc.getFontHeight(Gfx.FONT_MEDIUM) * 0.5 - 40 - 3 - dc.getFontHeight(Gfx.FONT_LARGE) - 3 - addPadding,
                Gfx.FONT_MEDIUM,
                "TempTarget",
                Gfx.TEXT_JUSTIFY_CENTER
        );
        // Icon
        dc.drawBitmap(
            dc.getWidth() * 0.5 - 20,
            dc.getHeight() * 0.5 + 10 - dc.getFontHeight(Gfx.FONT_MEDIUM) * 0.5 - 40 - 3 - addPadding,
            Ui.loadResource(Rez.Drawables.TempTargetIcon)
        );
        // Value
        var text;
        if( ttTarget == null ) {
            text = "Cancel TT";
        } else {
            text = ttTarget.format(TT_FORMAT) + TT_UNIT_LABEL;
            text += "\n@ " + ttDuration.toString() + " min";
        }
        var fontSize1 = Gfx.FONT_SMALL;
        dc.drawText(
                dc.getWidth() * 0.5,
                dc.getHeight() * 0.5 + 10,
                fontSize1,
                text,
                Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
        );
        // Instruction
        var fontSize2 = Gfx.FONT_TINY;
        var anweisung = ( ttTarget == 0 ) ? "Click SELECT to start!" : "Push it to\nAAPS?";
        if (ttError != null ) {
            anweisung = ttError;
            ttError = null;
        }
        dc.drawText(
                dc.getWidth() * 0.5,
                dc.getHeight() * 0.5 + 10 + dc.getFontHeight(Gfx.FONT_MEDIUM) * 0.5 + 15,
                fontSize2,
                anweisung,
                Gfx.TEXT_JUSTIFY_CENTER
        );

    }

    function onHide() as Void {
    }

}
