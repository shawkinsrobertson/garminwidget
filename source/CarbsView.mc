using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Communications as Comm;
using Toybox.Lang;

var carbsValue = 0;
var carbsError = null;
var carbsAbfrage = 1; // 1: start, 2: selected, 3: waiting, 4: finished
var carbsCircle = Gfx.COLOR_BLACK;
var carbsErrorCircle = false;
var carbsCustom = 0;
var carbsOpenCustom = false;

class CarbsBehaviorDelegate extends Ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
        carbsCircle = Gfx.COLOR_BLACK;
        carbsAbfrage = 1;
        carbsValue = 0;
        carbsError = null;
        carbsErrorCircle = false;
        carbsOpenCustom = false;
    }

    function onKey(keyEvent) {
        if( keyEvent.getKey() == 4 ) {
            if( carbsAbfrage == 1 ) {
                showCarbsMenu();
            } else if( carbsAbfrage == 2 ) {
                sendCarbs();
                carbsError = "Contacting\nAAPS...";
            } else if ( carbsAbfrage == 3 ) {
                carbsError = "Waiting for\nAAPS...";
            } else {
                carbsError = "Click SELECT to start!";
                carbsAbfrage = 1;
                carbsValue = 0;
                carbsCircle = Gfx.COLOR_BLACK;
            }
            Ui.requestUpdate();
            return true;
        }
        return false;
    }

    function onHold(touchEvent) {
        if( carbsAbfrage == 1 ) {
            showCarbsMenu();
        } else if( carbsAbfrage == 2 ) {
            sendCarbs();
            carbsError = "Contacting\nAAPS...";
        } else if ( carbsAbfrage == 3 ) {
            carbsError = "Waiting for\nAAPS...";
        } else {
            carbsError = "Click SELECT to start!";
            carbsAbfrage = 1;
            carbsValue = 0;
            carbsCircle = Gfx.COLOR_BLACK;
        }
        Ui.requestUpdate();
        return true;
    }

    function showCarbsMenu() {
        carbsAbfrage = 2;
        var menu = new Ui.Menu();
        menu.setTitle("Choose Carbs");
        menu.addItem("Custom value...", :custom);
        menu.addItem("5 g", :a);
        menu.addItem("10 g", :b);
        menu.addItem("15 g", :c);
        menu.addItem("20 g", :d);
        menu.addItem("25 g", :e);
        menu.addItem("30 g", :f);
        menu.addItem("40 g", :g);
        menu.addItem("50 g", :h);
        menu.addItem("60 g", :i);
        menu.addItem("70 g", :j);
        menu.addItem("80 g", :k);
        WatchUi.pushView(menu, new CarbsMenuInputDelegate(), WatchUi.SLIDE_IMMEDIATE);
     }

    function sendCarbs() {
        carbsCircle = Gfx.COLOR_WHITE;
        Comm.makeWebRequest( carbsUrl, { "eventType" => "Snack Bolus", "carbs" => carbsValue, "enteredBy" => "Garmin Widget" }, { :method => Comm.HTTP_REQUEST_METHOD_POST, :headers => { "Content-Type" => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON }, :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON}, method(:onCarbsResponse) );
        carbsAbfrage = 3;
        return true;
     }

     function onCarbsResponse( responseCode as Lang.Number, data as Lang.Dictionary or Lang.String or Null ) as Void {
        if( responseCode == 200 ) {
            Sys.println(data);
            carbsError = "added to\nAAPS";
            carbsCircle = Gfx.COLOR_GREEN;
        } else {
            carbsError = "Error: " + responseCode.toString();
            carbsCircle = Gfx.COLOR_RED;
            carbsErrorCircle = true;
        }
        carbsAbfrage = 4;
        Ui.requestUpdate();
     }

}

class CarbsMenuInputDelegate extends Ui.MenuInputDelegate {

    function initialize() {
       MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        if (item == :custom) {
            carbsCustom = 0;
            carbsOpenCustom = true;
            return;
        }
        carbsCircle = Gfx.COLOR_YELLOW;
        if (item == :a) {
            carbsValue = 5;
        } else if (item == :b) {
            carbsValue = 10;
        } else if (item == :c) {
            carbsValue = 15;
        } else if (item == :d) {
            carbsValue = 20;
        } else if (item == :e) {
            carbsValue = 25;
        } else if (item == :f) {
            carbsValue = 30;
        } else if (item == :g) {
            carbsValue = 40;
        } else if (item == :h) {
            carbsValue = 50;
        } else if (item == :i) {
            carbsValue = 60;
        } else if (item == :j) {
            carbsValue = 70;
        } else if (item == :k) {
            carbsValue = 80;
        }
    }
}

// -----------------------------------------------------------
// Custom picker: UP (top-right) = +1, DOWN (bottom-right) = -1, SELECT = confirm
// -----------------------------------------------------------
class CarbsCustomPickerView extends Ui.View {

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

        // Title
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 70, Gfx.FONT_SMALL, "Set Carbs (g)", Gfx.TEXT_JUSTIFY_CENTER);

        // UP hint
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 45, Gfx.FONT_MEDIUM, "+", Gfx.TEXT_JUSTIFY_CENTER);

        // Value
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(cx, cy, Gfx.FONT_NUMBER_HOT, carbsCustom.toString(), Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);

        // DOWN hint
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 40, Gfx.FONT_MEDIUM, "-", Gfx.TEXT_JUSTIFY_CENTER);

        // Instruction
        dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 70, Gfx.FONT_XTINY, "SELECT to confirm", Gfx.TEXT_JUSTIFY_CENTER);
    }

}

class CarbsCustomPickerDelegate extends Ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // top-right = UP = increment
    function onPreviousPage() {
        carbsCustom = carbsCustom + 1;
        if( carbsCustom > 200 ) { carbsCustom = 200; }
        Ui.requestUpdate();
        return true;
    }

    // bottom-right = DOWN = decrement
    function onNextPage() {
        carbsCustom = carbsCustom - 1;
        if( carbsCustom < 0 ) { carbsCustom = 0; }
        Ui.requestUpdate();
        return true;
    }

    function onSelect() {
        carbsValue = carbsCustom;
        carbsCircle = Gfx.COLOR_YELLOW;
        carbsAbfrage = 2;
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
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
}


class CarbsView extends Ui.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    function onShow() as Void {
        if( carbsOpenCustom == true ) {
            carbsOpenCustom = false;
            WatchUi.pushView(new CarbsCustomPickerView(), new CarbsCustomPickerDelegate(), WatchUi.SLIDE_LEFT);
        }
    }

    function onUpdate(dc) as Void {
        View.onUpdate(dc);

        var addPadding = dc.getWidth() >= 360 ? 10 : 0;
        // Circle
        dc.setColor(carbsCircle, carbsCircle);
        dc.fillCircle(dc.getWidth() * 0.5, dc.getHeight() * 0.5, dc.getHeight() * 0.5);
        if (carbsErrorCircle == false ) {
            dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        } else {
            dc.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_BLACK);
            carbsErrorCircle = false;
        }
        dc.fillCircle(dc.getWidth() * 0.5, dc.getHeight() * 0.5, dc.getHeight() * 0.5 - 5);

        // Title
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(
                dc.getWidth() * 0.5,
                dc.getHeight() * 0.5 + 10 - dc.getFontHeight(Gfx.FONT_LARGE) * 0.5 - 40 - 5 - dc.getFontHeight(Gfx.FONT_LARGE) - 5 - addPadding,
                Gfx.FONT_LARGE,
                "Carbs",
                Gfx.TEXT_JUSTIFY_CENTER
        );
        // Icon
        dc.drawBitmap(
            dc.getWidth() * 0.5 - 15,
            dc.getHeight() * 0.5 + 10 - dc.getFontHeight(Gfx.FONT_LARGE) * 0.5 - 40 - 5 - addPadding,
            Ui.loadResource(Rez.Drawables.CarbsIcon)
        );
        // Value
        dc.drawText(
                dc.getWidth() * 0.5,
                dc.getHeight() * 0.5 + 10 + 5,
                Gfx.FONT_LARGE,
                carbsValue.toString() + " g",
                Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
        );
        // Instruction
        var fontSize = Gfx.FONT_TINY;
        var anweisung = (carbsValue == 0) ? "Click SELECT to start!" : "Push it to\nAAPS?";
        if (carbsError != null ) {
            anweisung = carbsError;
            carbsError = null;
        }
        dc.drawText(
                dc.getWidth() * 0.5,
                dc.getHeight() * 0.5 + 10 + dc.getFontHeight(Gfx.FONT_LARGE) * 0.5 + 10,
                fontSize,
                anweisung,
                Gfx.TEXT_JUSTIFY_CENTER
        );

    }

    function onHide() as Void {
    }

}
