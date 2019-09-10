using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Math;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.ActivityMonitor;

var gIconsFont;

class BasICView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        
        // load icon font
        gIconsFont = WatchUi.loadResource(Rez.Fonts.IconsFont);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        
        var center = dc.getWidth() / 2;
        var middle = dc.getHeight() / 2;
        
        var xOffset;
        
        var textLeft = Graphics.TEXT_JUSTIFY_LEFT;
        var textRight = Graphics.TEXT_JUSTIFY_RIGHT;
        var textCenter = Graphics.TEXT_JUSTIFY_CENTER;
        
        var transparent = Graphics.COLOR_TRANSPARENT;
        var white = Graphics.COLOR_WHITE;
        var yellow = Graphics.COLOR_YELLOW;
        var green = Graphics.COLOR_GREEN;
        var red = Graphics.COLOR_RED;
        
        var fontLarge = Graphics.FONT_LARGE;
        var fontBig = Graphics.FONT_SYSTEM_NUMBER_THAI_HOT;
        var fontBigHight = dc.getFontHeight(fontBig);
        var fontBigHightOffset = 0;
        
        // font hights seems to be different in various models
        switch (System.getDeviceSettings().partNumber) {
			// vivoactive3
        	case "006-B2700-00": {
        		fontBigHightOffset = -20;
        		break;
        	}
        	// fr935
        	case "006-B2691-00": {
        		fontBigHightOffset = 5;
        		break;
        	}
        	default:
        	break;
        }
        
        // display 5 minute makers
    	dc.setColor(yellow, transparent);
    	var fiveMinuteMakerSize = 2;
    	for (var minutes = -5; minutes <= 70; minutes = minutes + 5) {
    		var marker = msCoord(minutes, 120);
    		dc.fillCircle(marker[0], marker[1], fiveMinuteMakerSize);
    	}
    	
    	// display battery state
    	var batteryState = getBattery();
    	var batteryStateColor = white;
    	if (batteryState <= 20) {
    		batteryStateColor = yellow;
    		if (batteryState <= 10) {
    			batteryStateColor = red;
    		}
    	}
    	dc.setColor(batteryStateColor, transparent);
    	dc.drawText(center, 5, fontLarge, batteryState.format("%02d") + "%", textCenter);
    	
    	// icons:
    	xOffset = 35;
    	dc.setColor(yellow, transparent);
    	dc.drawText(center-xOffset, 65, gIconsFont, "0", textLeft);		// steps
    	dc.drawText(center-xOffset, 90, gIconsFont, "1", textLeft);		// floors
    	dc.drawText(center-xOffset, 115, gIconsFont, "6", textLeft);	// calories
    	dc.drawText(center-xOffset, 140, gIconsFont, "3", textLeft);	// heartrate
    	
    	// sensors
    	xOffset = 75;
    	// display steps
    	dc.setColor(yellow, transparent);
    	dc.drawText(xOffset, 60, fontLarge, getSteps(), textRight);
    	// display floors
    	dc.setColor(yellow, transparent);
    	dc.drawText(xOffset, 85, fontLarge, getFloors(), textRight);
    	// display calories
    	dc.setColor(yellow, transparent);
    	dc.drawText(xOffset, 110, fontLarge, getCalories(), textRight);
    	// display heartrate
    	dc.setColor(yellow, transparent);
    	dc.drawText(xOffset, 135, fontLarge, getHeartrate(), textRight);
    	
    	// display hour digit
    	dc.setColor(green, transparent);
    	dc.drawText(center, middle-fontBigHight, fontBig, getHour(), textLeft);
    	
    	//display minute dot
    	dc.setColor(red, transparent);
    	var minuteDotSize = 4;
    	var minute = msCoord(System.getClockTime().min, center-minuteDotSize);
    	dc.fillCircle(minute[0], minute[1], minuteDotSize);
    	
    	// display date
    	dc.setColor(green, transparent);
    	dc.drawText(center, 190, fontLarge, getDate(), textCenter);
    	
    	//display hour dot
    	dc.setColor(green, transparent);
    	var hourDotSize = 2;
    	var hour = hrCoord(System.getClockTime().hour, System.getClockTime().min, center-hourDotSize);
    	dc.fillCircle(hour[0], hour[1], hourDotSize);
    	
    	// display minute digit
    	dc.setColor(white, transparent);
    	dc.drawText(center, middle+fontBigHightOffset, fontBig, getMinute(), textLeft);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }
    
    private function getDate() {
    	var tFormat = Time.FORMAT_MEDIUM;
    	var now = Time.now();
    	var date = Gregorian.info(now, tFormat).day_of_week + " " + Gregorian.info(now, tFormat).day;
    	return date;
    }
    
    private function getHour() {
    	var hour = System.getClockTime().hour.format("%02d").toString();
    	return hour;
    }
    
    private function getMinute() {
    	var minute = System.getClockTime().min.format("%02d").toString();
    	return minute;
    }
    
    private function getBattery() {
    	var battery = System.getSystemStats().battery;
    	return battery;
    }
    
    private function getSteps() {
    	var steps = ActivityMonitor.getInfo().steps.toString();
    	return steps;
    }
    
    private function getFloors() {
    	var floors = ActivityMonitor.getInfo().floorsClimbed.toString();
    	return floors;
    }
    
    private function getCalories() {
    	var calories = ActivityMonitor.getInfo().calories.toString();
    	return calories;
    }
    
    private function getHeartrate() {
    	var heartrate = "";
    	
    	if(ActivityMonitor has :INVALID_HR_SAMPLE) {
    		heartrate = retrieveHeartrateText();
    	}
    	else {
    		heartrate = "";
    	}
    	
		return heartrate;
    }
    
    private function retrieveHeartrateText() {
    	var lastMinute = new Time.Duration(60);
    	var heartrateIterator = ActivityMonitor.getHeartRateHistory(lastMinute, true);
		var currentHeartrate = heartrateIterator.next().heartRate;

		if(currentHeartrate == ActivityMonitor.INVALID_HR_SAMPLE) {
			return "";
		}

		return currentHeartrate.format("%d");
    }
    
	//coord for minute and second hand
	private function msCoord(val, hlen) {
		var coord = new [2];
		val *= 6;	//each minute and second make 6 degree
		var degree = Math.PI * val / 180;
 
		if (val >= 0 && val <= 180) {
			coord[0] = 120 + (hlen * Math.sin(degree));
			coord[1] = 120 - (hlen * Math.cos(degree));
		} else {
			coord[0] = 120 - (hlen * (-Math.sin(degree)));
			coord[1] = 120 - (hlen * Math.cos(degree));
		}
		
		return coord;
	}
 
	//coord for hour hand
	private function hrCoord(hval, mval, hlen) {
		var coord = new [2];
 
		//each hour makes 30 degree
		//each min makes 0.5 degree
		var val = ((hval * 30) + (mval * 0.5));
		var degree = Math.PI * val / 180;

		if (val >= 0 && val <= 180) {
			coord[0] = 120 + (hlen * Math.sin(degree));
			coord[1] = 120 - (hlen * Math.cos(degree));
		} else {
			coord[0] = 120 - (hlen * (-Math.sin(degree)));
			coord[1] = 120 - (hlen * Math.cos(degree));
		}

		return coord;
	}
}