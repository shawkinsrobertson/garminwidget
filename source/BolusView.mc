using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Communications as Comm;
using Toybox.Lang;

var bolusValue = 0.0;
var bolusError = null;
var bolusAbfrage = 1; // 1: start, 2: selected, 3: waiting, 4: finished
var bolusCircle = Gfx.COLOR_BLACK;
var bolusErrorCircle = false;
var bolusCustom = 0.0;
var bolusOpenCustom = false; // flag to open custom picker after menu pops

class BolusBehaviorDelegate extends Ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
        bolusCircle = Gfx.COLOR_BLACK;
        bolusAbfrage = 1;
        bolusValue = 0.0;
        bolusError = null;
        bolusErrorCircle = false;
        bolusOpenCustom = false;
    }

    function onKey(keyEvent) {
        if( keyEvent.getKey() == 4 ) {
            if( bolusAbfrage == 1 ) {
                showBolusMenu();
            } else if( bolusAbfrage == 2 ) {
                sendBolus();
                bolusError = "Contacting\nAAPS...";
            } else if ( bolusAbfrage == 3 ) {
                bolusError = "Waiting for\nAAPS...";
            } else {
                bolusError = "Click SELECT to start!";
                bolusAbfrage = 1;
                bolusValue = 0.0;
                bolusCircle = Gfx.COLOR_BLACK;
            }
            Ui.requestUpdate();
            return true;
        }
        return false;
    }

    function onHold(touchEvent) {
        if( bolusAbfrage == 1 ) {
            showBolusMenu();
        } else if( bolusAbfrage == 2 ) {
            sendBolus();
            bolusError = "Contacting\nAAPS...";
        } else if ( bolusAbfrage == 3 ) {
            bolusError = "Waiting for\nAAPS...";
        } else {
            bolusError = "Click SELECT to start!";
            bolusAbfrage = 1;
            bolusValue = 0.0;
            bolusCircle = Gfx.COLOR_BLACK;
        }
        Ui.requestUpdate();
        return true;
    }

    function showBolusMenu() {
        bolusAbfrage = 2;
        var menu = new Ui.Menu();
        menu.setTitle("Choose Bolus");
        menu.addItem("Custom value...", :custom);
        menu.addItem("0.2 U", :a);
        menu.addItem("0.5 U", :b);
        menu.addItem("1.0 U", :c);
        menu.addItem("1.5 U", :d);
        menu.addItem("2.0 U", :e);
        menu.addItem("2.5 U", :f);
        menu.addItem("3.0 U", :g);
        menu.addItem("3.5 U", :h);
        menu.addItem("4.0 U", :i);
        menu.addItem("4.5 U", :j);
        menu.addItem("5.0 U", :k);
        menu.addItem("6.0 U", :l);
        menu.addItem("7.0 U", :m);
        menu.addItem("8.0 U", :n);
        WatchUi.pushView(menu, new BolusMenuInputDelegate(), WatchUi.SLIDE_IMMEDIATE);
     }

    function sendBolus() {
        bolusCircle = Gfx.COLOR_WHITE;
        Comm.makeWebRequest( bolusUrl, { "bolus" => bolusValue, "enteredBy" => "Garmin Widget" }, { :method => Comm.HTTP_REQUEST_METHOD_POST, :headers => { "Content-Type" => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON }, :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON}, method(:onBolusResponse) );
        bolusAbfrage = 3;
        return true;
     }

     function onBolusResponse( responseCode as Lang.Number, data as Lang.Dictionary or Lang.String or Null ) as Void {
        if( responseCode == 200 ) {
            Sys.println(data);
            bolusError = "transmitted to\nAAPS";
            bolusCircle = Gfx.COLOR_GREEN;
        } else {
            bolusError = "Error: " + responseCode.toString();
            bolusCircle = Gfx.COLOR_RED;
            bolusErrorCircle = true;
        }
        bolusAbfrage = 4;
        Ui.requestUpdate();
     }

}

class BolusMenuInputDelegate extends Ui.MenuInputDelegate {

    function initialize() {
       MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        if (item == :custom) {
            // Set flag — the picker will be opened from BolusView.onShow
            // after the menu auto-pops back to BolusView
            bolusCustom = 0.0;
            bolusOpenCustom = true;
            return;
        }
        bolusCircle = Gfx.COLOR_YELLOW;
        if (item == :a) {
            bolusValue = 0.2;
        } else if (item == :b) {
            bolusValue = 0.5;
        } else if (item == :c) {
            bolusValue = 1.0;
        } else if (item == :d) {
            bolusValue = 1.5;
        } else if (item == :e) {
            bolusValue = 2.0;
        } else if (item == :f) {
            bolusValue = 2.5;
        } else if (item == :g) {
            bolusValue = 3.0;
        } else if (item == :h) {
            bolusValue = 3.5;
        } else if (item == :i) {
            bolusValue = 4.0;
        } else if (item == :j) {
            bolusValue = 4.5;
        } else if (item == :k) {
            bolusValue = 5.0;
        } else if (item == :l) {
            bolusValue = 6.0;
        } else if (item == :m) {
            bolusValue = 7.0;
        } else if (item == :n) {
            bolusValue = 8.0;
        }
    }
}

// -----------------------------------------------------------
// Custom picker view
// Fenix 7 Pro: top-right = UP = onPreviousPage, bottom-right = DOWN = onNextPage
// UP (+) = onPreviousPage, DOWN (-) = onNextPage, SELECT = confirm
// -----------------------------------------------------------
class BolusCustomPickerView extends Ui.View {

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
        dc.drawText(cx, cy - 70, Gfx.FONT_SMALL, "Set Bolus (U)", Gfx.TEXT_JUSTIFY_CENTER);

        // UP hint (top-right button)
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 45, Gfx.FONT_MEDIUM, "+", Gfx.TEXT_JUSTIFY_CENTER);

        // Value
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(cx, cy, Gfx.FONT_NUMBER_HOT, bolusCustom.format("%.1f"), Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);

        // DOWN hint (bottom-right button)
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 40, Gfx.FONT_MEDIUM, "-", Gfx.TEXT_JUSTIFY_CENTER);

        // Instruction
        dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 70, Gfx.FONT_XTINY, "SELECT to confirm", Gfx.TEXT_JUSTIFY_CENTER);
    }

}

class BolusCustomPickerDelegate extends Ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // top-right button on Fenix 7 = UP = increment
    function onPreviousPage() {
        bolusCustom = bolusCustom + 0.1;
        bolusCustom = ((bolusCustom * 10 + 0.5).toNumber()).toFloat() / 10.0;
        if( bolusCustom > 30.0 ) { bolusCustom = 30.0; }
        Ui.requestUpdate();
        return true;
    }

    // bottom-right button on Fenix 7 = DOWN = decrement
    function onNextPage() {
        bolusCustom = bolusCustom - 0.1;
        bolusCustom = ((bolusCustom * 10 + 0.5).toNumber()).toFloat() / 10.0;
        if( bolusCustom < 0.0 ) { bolusCustom = 0.0; }
        Ui.requestUpdate();
        return true;
    }

    // middle button = SELECT = confirm
    function onSelect() {
        bolusValue = bolusCustom;
        bolusCircle = Gfx.COLOR_YELLOW;
        bolusAbfrage = 2;
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onKey(keyEvent) {
        var key = keyEvent.getKey();
        if( key == 4 ) { // SELECT
            return onSelect();
        } else if( key == 13 ) { // UP key
            return onPreviousPage();
        } else if( key == 8 ) { // DOWN key
            return onNextPage();
        }
        return false;
    }
}


class BolusView extends Ui.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // When this view comes back to foreground (e.g. after menu pops),
    // check if we need to open the custom picker
    function onShow() as Void {
        if( bolusOpenCustom == true ) {
            bolusOpenCustom = false;
            WatchUi.pushView(new BolusCustomPickerView(), new BolusCustomPickerDelegate(), WatchUi.SLIDE_LEFT);
        }
    }

    function onUpdate(dc) as Void {
        View.onUpdate(dc);

        var addPadding = dc.getWidth() >= 360 ? 10 : 0;
        // Circle
        dc.setColor(bolusCircle, bolusCircle);
        dc.fillCircle(dc.getWidth() * 0.5, dc.getHeight() * 0.5, dc.getHeight() * 0.5);
        if (bolusErrorCircle == false ) {
            dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        } else {
            dc.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_BLACK);
            bolusErrorCircle = false;
        }
        dc.fillCircle(dc.getWidth() * 0.5, dc.getHeight() * 0.5, dc.getHeight() * 0.5 - 5);

        // Title
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(
                dc.getWidth() * 0.5,
                dc.getHeight() * 0.5 + 10 - dc.getFontHeight(Gfx.FONT_LARGE) * 0.5 - 40 - 5 - dc.getFontHeight(Gfx.FONT_LARGE) - 5 - addPadding,
                Gfx.FONT_LARGE,
                "Bolus",
                Gfx.TEXT_JUSTIFY_CENTER
        );
        // Icon
        dc.drawBitmap(
            dc.getWidth() * 0.5 - 20,
            dc.getHeight() * 0.5 + 10 - dc.getFontHeight(Gfx.FONT_LARGE) * 0.5 - 40 - 5 - addPadding,
            Ui.loadResource(Rez.Drawables.BolusIcon)
        );
        // Value
        dc.drawText(
                dc.getWidth() * 0.5,
                dc.getHeight() * 0.5 + 10 + 5,
                Gfx.FONT_LARGE,
                bolusValue.format("%.1f") + " U",
                Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
        );
        // Instruction
        var fontSize = Gfx.FONT_TINY;
        var anweisung = (bolusValue == 0.0) ? "Click SELECT to start!" : "Push it to\nAAPS?";
        if (bolusError != null ) {
            anweisung = bolusError;
            bolusError = null;
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
