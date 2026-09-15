import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Weather;
import Toybox.WatchUi;

class invincilbe_watchfaceView extends WatchUi.WatchFace {

    var background as Graphics.BitmapType?;
    var foreground as Graphics.BitmapType?;

    var quotes as Array<String> = [
        "DROPS OF WATER\nTHAT MAKE AN OCEAN",
        "THOUGH THE NIGHT IS DARK\nIT WON'T BE VERY LONG",
        "YOU WILL NEVER KNOW\nIF YOU NEVER TRY",
        "QUOTES WON'T WORK\nUNLESS YOU DO",
    ];
    var currentQuote as String = "";

    function initialize() {
        WatchFace.initialize();
        pickRandomQuote();
    }

    function pickRandomQuote() as Void {
        currentQuote = quotes[Math.rand() % quotes.size()];
    }

    function conditionToString(condition as Number?) as String {
        switch (condition) {
            case Weather.CONDITION_CLEAR:
                return "SUNNY";
            case Weather.CONDITION_MOSTLY_CLEAR:
            case Weather.CONDITION_FAIR:
                return "MOSTLY SUNNY";
            case Weather.CONDITION_PARTLY_CLOUDY:
            case Weather.CONDITION_PARTLY_CLEAR:
                return "PARTLY CLOUDY";
            case Weather.CONDITION_MOSTLY_CLOUDY:
            case Weather.CONDITION_THIN_CLOUDS:
                return "MOSTLY CLOUDY";
            case Weather.CONDITION_CLOUDY:
                return "CLOUDY";
            case Weather.CONDITION_RAIN:
            case Weather.CONDITION_SHOWERS:
                return "RAINY";
            case Weather.CONDITION_LIGHT_RAIN:
            case Weather.CONDITION_LIGHT_SHOWERS:
            case Weather.CONDITION_DRIZZLE:
                return "LIGHT RAIN";
            case Weather.CONDITION_HEAVY_RAIN:
            case Weather.CONDITION_HEAVY_SHOWERS:
                return "HEAVY RAIN";
            case Weather.CONDITION_SNOW:
                return "SNOWY";
            case Weather.CONDITION_LIGHT_SNOW:
                return "LIGHT SNOW";
            case Weather.CONDITION_HEAVY_SNOW:
                return "HEAVY SNOW";
            case Weather.CONDITION_WINDY:
                return "WINDY";
            case Weather.CONDITION_FOG:
            case Weather.CONDITION_MIST:
            case Weather.CONDITION_HAZY:
            case Weather.CONDITION_HAZE:
                return "FOGGY";
            case Weather.CONDITION_THUNDERSTORMS:
            case Weather.CONDITION_SCATTERED_THUNDERSTORMS:
            case Weather.CONDITION_CHANCE_OF_THUNDERSTORMS:
                return "STORMY";
            default:
                return "UNKNOWN";
        }
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
        var timeLabel = View.findDrawableById("TimeLabel") as Text;
        timeLabel.setFont(WatchUi.loadResource(Rez.Fonts.ShaxizorFont) as Graphics.FontType);
        var batteryLabel = View.findDrawableById("BatteryLabel") as Text;
        batteryLabel.setFont(WatchUi.loadResource(Rez.Fonts.FuturaBatteryFont) as Graphics.FontType);
        var dayLabel = View.findDrawableById("DayLabel") as Text;
        dayLabel.setFont(WatchUi.loadResource(Rez.Fonts.FuturaBatteryFont) as Graphics.FontType);
        var quoteLabel = View.findDrawableById("QuoteLabel") as Text;
        quoteLabel.setFont(WatchUi.loadResource(Rez.Fonts.FuturaBatteryFont) as Graphics.FontType);
        background = WatchUi.loadResource(Rez.Drawables.Background) as Graphics.BitmapType;
        foreground = WatchUi.loadResource(Rez.Drawables.Foreground) as Graphics.BitmapType;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.clear();
        dc.drawBitmap(0, 0, background);

        // Get and show the current time
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour.format("%02d"), clockTime.min.format("%02d")]);
        var view = View.findDrawableById("TimeLabel") as Text;
        view.setText(timeString);

        // Draw just the time label onto our prepared canvas. We don't call
        // View.onUpdate(dc) here because it clears the whole screen first,
        // which would wipe out the background bitmap drawn above.
        view.draw(dc);

        dc.setBlendMode(Graphics.BLEND_MODE_MULTIPLY);
        dc.drawBitmap(0, 0, foreground);
        dc.setBlendMode(Graphics.BLEND_MODE_DEFAULT);

        // Show the remaining battery percentage, on top of the foreground layer
        var battery = System.getSystemStats().battery;
        var batteryLabel = View.findDrawableById("BatteryLabel") as Text;
        batteryLabel.setText("BATTERY: " + battery.format("%d") + "%");
        batteryLabel.draw(dc);

        // Show the current day of the week and date, same style as the battery label
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dayNames = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        var dayLabel = View.findDrawableById("DayLabel") as Text;
        var conditions = Weather.getCurrentConditions();
        var weatherText = (conditions != null && conditions.condition != null) ? conditionToString(conditions.condition) : "UNKNOWN";
        dayLabel.setText(
            dayNames[today.day_of_week - 1] + " " +
            today.day.format("%02d") + "." + today.month.format("%02d") +
            " " + weatherText
        );
        dayLabel.draw(dc);

        // Show a quote that changes each time the watch face lights up
        var quoteLabel = View.findDrawableById("QuoteLabel") as Text;
        quoteLabel.setText(currentQuote);
        quoteLabel.draw(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        pickRandomQuote();
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
