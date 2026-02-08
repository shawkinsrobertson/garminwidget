using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class MainMenuView extends Ui.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    function onShow() as Void {
    }

    function onUpdate(dc) as Void {
        View.onUpdate(dc);

        var cx = dc.getWidth() * 0.5;
        var cy = dc.getHeight() * 0.5;

        // Black background
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();

        // Title
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(
            cx,
            cy - dc.getFontHeight(Gfx.FONT_LARGE) - 10,
            Gfx.FONT_LARGE,
            "AAPS",
            Gfx.TEXT_JUSTIFY_CENTER
        );

        // Instruction
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText(
            cx,
            cy + 10,
            Gfx.FONT_SMALL,
            "Press SELECT",
            Gfx.TEXT_JUSTIFY_CENTER
        );
        dc.drawText(
            cx,
            cy + 10 + dc.getFontHeight(Gfx.FONT_SMALL) + 2,
            Gfx.FONT_SMALL,
            "to choose action",
            Gfx.TEXT_JUSTIFY_CENTER
        );
    }

    function onHide() as Void {
    }

}

class MainMenuDelegate extends Ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onKey(keyEvent) {
        if( keyEvent.getKey() == 4 ) { // SELECT
            showMainMenu();
            return true;
        }
        return false;
    }

    function onHold(touchEvent) {
        showMainMenu();
        return true;
    }

    function onSelect() {
        showMainMenu();
        return true;
    }

    function showMainMenu() {
        var menu = new Ui.Menu();
        menu.setTitle("AAPS Action");
        menu.addItem("Bolus", :bolus);
        menu.addItem("Carbs", :carbs);
        menu.addItem("TempTarget", :temptarget);
        WatchUi.pushView(menu, new MainMenuInputDelegate(), WatchUi.SLIDE_IMMEDIATE);
    }

}

class MainMenuInputDelegate extends Ui.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        if (item == :bolus) {
            WatchUi.pushView(new BolusView(), new BolusBehaviorDelegate(), WatchUi.SLIDE_LEFT);
        } else if (item == :carbs) {
            WatchUi.pushView(new CarbsView(), new CarbsBehaviorDelegate(), WatchUi.SLIDE_LEFT);
        } else if (item == :temptarget) {
            WatchUi.pushView(new TempTargetView(), new TempTargetBehaviorDelegate(), WatchUi.SLIDE_LEFT);
        }
    }

}
