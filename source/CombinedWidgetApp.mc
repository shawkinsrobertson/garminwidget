import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class CombinedWidgetApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view — the main menu chooser
    function getInitialView() {
        return [ new MainMenuView(), new MainMenuDelegate() ];
    }

    (:glance)
    function getGlanceView() {
        return [ new CombinedGlanceView() ];
    }

}

function getApp() as CombinedWidgetApp {
    return Application.getApp() as CombinedWidgetApp;
}
