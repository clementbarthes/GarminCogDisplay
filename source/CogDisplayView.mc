using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class CogDisplayView extends Ui.DataField {

    hidden var mValue;

    function initialize() {
        DataField.initialize();
        mValue = 0.0f;
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc) {
        var obscurityFlags = DataField.getObscurityFlags();

        // Top left quadrant so we'll use the top left layout
        if (obscurityFlags == (OBSCURE_TOP | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.TopLeftLayout(dc));

        // Top right quadrant so we'll use the top right layout
        } else if (obscurityFlags == (OBSCURE_TOP | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.TopRightLayout(dc));

        // Bottom left quadrant so we'll use the bottom left layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.BottomLeftLayout(dc));

        // Bottom right quadrant so we'll use the bottom right layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.BottomRightLayout(dc));

        // Use the generic, centered layout
        } else {
            View.setLayout(Rez.Layouts.MainLayout(dc));
            var labelView = View.findDrawableById("label");
            labelView.locY = labelView.locY - 16;
            var valueView = View.findDrawableById("value");
            valueView.locY = valueView.locY + 7;
        }

        View.findDrawableById("label").setText(Rez.Strings.cogLabel);
        return true;
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        // See Activity.Info in the documentation for available information.
        if(info has :currentHeartRate){
            if(info.currentHeartRate != null){
                mValue = info.currentHeartRate;
            } else {
                mValue = 0.0f;
            }
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
        // Set the background color
        View.findDrawableById("Background").setColor(getBackgroundColor());

        // Set the foreground color and value
        var value = View.findDrawableById("value");
        if (getBackgroundColor() == Gfx.COLOR_BLACK) {
            value.setColor(Gfx.COLOR_WHITE);
        } else {
            value.setColor(Gfx.COLOR_BLACK);
        }
        value.setText(mValue.format("%.2f"));
		value.setFont(Gfx.FONT_LARGE);
        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}

/*
	// Load user settings (wheel size, number of teeth, etc...)
    var nChainRings = Application.getApp().getProperty("chainRingCount");
	var wheelCircumference = Application.getApp().getProperty("wheelCircumference")/1000.0;
	var chainRings = [Application.getApp().getProperty("chainRing1"), 
						Application.getApp().getProperty("chainRing2"),
						Application.getApp().getProperty("chainRing3")];
	var cogs = [Application.getApp().getProperty("cog1"), 
						Application.getApp().getProperty("cog2"), 
						Application.getApp().getProperty("cog3"), 
						Application.getApp().getProperty("cog4"), 
						Application.getApp().getProperty("cog5"), 
						Application.getApp().getProperty("cog6"), 
						Application.getApp().getProperty("cog7"), 
						Application.getApp().getProperty("cog8"), 
						Application.getApp().getProperty("cog9"), 
						Application.getApp().getProperty("cog10"), 
						Application.getApp().getProperty("cog11")];
	
	
						
	// Initialize variables
	var wheelRotSpeed = 0.0;  //wheel speed in rpm					
	var measuredRatio = 0.0;  //Ratio computed from cadence and speed					
	var ringRatios = new [nChainRings];
	var cogNumber = [0, 0, 0];
	
    function initialize() {
    	// Create an array of [nChainRings, 11]
    	for (var i = 0; i<nChainRings; i++){
    		ringRatios[i] = new [11];
		}
	    for (var i = 0; i<nChainRings; i++){
	    	for (var j = 0; j<11; j++){
				self.ringRatios[i][j] = 1.0*self.cogs[j]/self.chainRings[i];
	    	}
    	}
    	System.println(chainRings);
    	System.println(self.ringRatios);
        SimpleDataField.initialize();
        // Load up the displayed label (based on user language)
        label = Ui.loadResource( Rez.Strings.cogLabel );
        
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
		if (info.currentCadence != null && info.currentSpeed != null 
		&& info.currentSpeed != 0.0 && info.currentCadence != 0  && info.currentCadence < 500){
			wheelRotSpeed = 60.0*info.currentSpeed/wheelCircumference;
			measuredRatio = wheelRotSpeed/info.currentCadence;
			// System.println("speed= " +3.6*info.currentSpeed + " cadence= " + info.currentCadence);
			// System.println("wheel rot= " + wheelRotSpeed + " ratio=" + measuredRatio);
		
			// Find the best correlation
			var correlationCoef = [100.0, 100.0, 100.0];
			for (var i = 0; i<nChainRings; i++){
		    	for (var j = 0; j<11; j++){
		    	var currentCoef = measuredRatio*ringRatios[i][j] - 1.0;
		    	// If negative, make it positive (since there is no absolute value function)
		    	if (currentCoef < 0.0){
		    		currentCoef = -currentCoef;
		    	}
					if (currentCoef < correlationCoef[i]){
						correlationCoef[i] = currentCoef;
						cogNumber[i] = cogs[j];
					}
		    	}
	    	}
	    	// System.println("cogs= " + cogNumber + "  Corr. coef. = " + correlationCoef);
		} else {
			// System.println("STOP speed= " +info.currentSpeed + " cadence= " + info.currentCadence);
		}
		var printCog;
		if (nChainRings == 1){
			printCog = cogNumber[0].toString();
		} else if (nChainRings == 2){
			printCog = cogNumber[0].toString() + "," + cogNumber[1].toString();
		} else {
			printCog = cogNumber[0].toString() + "," + 
			cogNumber[1].toString() + "," + cogNumber[2].toString();
		}
		
        return printCog;
    }

}  */