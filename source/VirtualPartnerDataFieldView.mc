using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;

class VirtualPartnerDataFieldView extends Ui.DataField {

	hidden var distanceParameter;
	hidden var allureParameter;
	hidden var estimateTime=0;
	hidden var estimateTimeRest=0;
	hidden var gapTime=0;
	hidden var runnerIcon;
	hidden var virtualPartnerIcon;	
	hidden var heightFontMedium;
	hidden var displayChronoEstimate;
	hidden var avaTps;
	hidden var retTps;
	hidden var chronoEstimate;
	hidden var tpsRest;
	hidden var errorFormat=false;
	hidden var timeScalePartner;
		
    function initialize() {
        
        runnerIcon = Ui.loadResource(Rez.Drawables.Runner);
        virtualPartnerIcon = Ui.loadResource(Rez.Drawables.VirtualPartner);
        avaTps = Ui.loadResource(Rez.Strings.AvaTps);
        retTps = Ui.loadResource(Rez.Strings.RetTps);
        chronoEstimate = Ui.loadResource(Rez.Strings.ChronoEstimate);
        tpsRest = Ui.loadResource(Rez.Strings.TpsRest);
        
        distanceParameter = App.getApp().getProperty("distance").toFloat();
        displayChronoEstimate = App.getApp().getProperty("displayChronoEstimate");
        var scalePartner = App.getApp().getProperty("scalePartner");

        var timeParameter = App.getApp().getProperty("time");

		var timeExtract = extract(timeParameter);
		if(distanceParameter ==null ||timeExtract[0]==null || timeExtract[1]==null || timeExtract[2]==null){
			errorFormat=true;
			allureParameter = 0;
			distanceParameter = 0;
		}else{
			errorFormat=false;
			var time = 	timeExtract[0]*60*60+timeExtract[1]*60+timeExtract[2];
			allureParameter = (time/distanceParameter).toLong();
		}
		
		var scalePartnerExtract = extract(scalePartner);
		if(scalePartnerExtract[0]==null || scalePartnerExtract[1]==null || scalePartnerExtract[2]==null){
			timeScalePartner = 3600;
		}else{
			timeScalePartner = 	scalePartnerExtract[0]*60*60+scalePartnerExtract[1]*60;
		
		}
		
		DataField.initialize();
    }
	
	function extract(timeString){
		var timeExtract = new [3];
		var separatorIndex;
		for( var i=0;i<3;i++){
			separatorIndex = timeString.find(":");
			if(separatorIndex!=null){
				timeExtract[i] = timeString.substring(0, separatorIndex).toNumber();
				timeString = timeString.substring(separatorIndex+1,timeString.length());
			}else if(i==2 && timeExtract[0]!=null && timeExtract[1]!=null){
				timeExtract[i] = timeString.toNumber();
			}
		}
		return timeExtract;
	}

    function onLayout(dc) {
		heightFontMedium = dc.getFontHeight(Gfx.FONT_NUMBER_MEDIUM);
    }

    function compute(info) {
		var distanceRunner = info.elapsedDistance;
		var mpsRunner = info.averageSpeed;
		
		var allureRunner; 
		if(distanceRunner==null){
			distanceRunner=0;
		}else{
			distanceRunner=distanceRunner/1000;
		}
		if(mpsRunner==null ||mpsRunner==0){
			allureRunner=0; 
		}else{
			allureRunner = (1000/mpsRunner).toLong();
		}
		
		var distanceToDestination = distanceParameter - distanceRunner;
		estimateTimeRest = (allureRunner*distanceToDestination).toLong();
		estimateTime = (allureRunner*distanceParameter).toLong();
		gapTime = (allureRunner*distanceRunner-allureParameter*distanceRunner).toLong();

    }

    function onUpdate(dc) {
    	dc.clear();
        var center_x = dc.getWidth()/2;
    	var center_y = dc.getHeight()/2;
    	var y = dc.getHeight()/3;
    	
    	dc.setColor(Gfx.COLOR_WHITE,Gfx.COLOR_WHITE);
		dc.fillRectangle(0,0,dc.getWidth(),dc.getHeight());
		dc.setColor(Gfx.COLOR_BLACK,Gfx.COLOR_WHITE);
    	if(errorFormat){
    		dc.drawText(center_x, center_y, Gfx.FONT_SYSTEM_SMALL, "Error parsing format",  Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);				
    	}else{
    		dc.drawLine(0, y, dc.getWidth(), y);
			dc.drawLine(0, y*2, dc.getWidth(), y*2);
    		var gap="";
    		var gapRunner = center_y*gapTime/timeScalePartner;

    		if(gapTime>0){
				dc.fillRectangle(0, 0, dc.getWidth(), y);
				dc.fillRectangle(0, y*2, dc.getWidth(), dc.getHeight());
				dc.setColor(Gfx.COLOR_WHITE,Gfx.COLOR_TRANSPARENT);
				gap=retTps;
			}else{
				gapTime=gapTime*-1;
				dc.setColor(Gfx.COLOR_BLACK,Gfx.COLOR_TRANSPARENT);
				gap=avaTps;
			}
			var font=Gfx.FONT_NUMBER_MEDIUM;
			
			if(heightFontMedium<=45 && heightFontMedium>=y*0.70){
				font=Gfx.FONT_NUMBER_MILD;
			}
			
			dc.drawText(center_x, y/2-y/4, Gfx.FONT_SYSTEM_TINY, gap,  Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(center_x, y/2+y/6,font, timeToString(gapTime), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
		
			if(estimateTimeRest>=0){
				if(displayChronoEstimate){
					dc.drawText(center_x, y*2+y/2-y/2.8, Gfx.FONT_SYSTEM_TINY, chronoEstimate,  Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);		
					dc.drawText(center_x, y*2+y/2, font, timeToString(estimateTime), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
				}else{
					dc.drawText(center_x, y*2+y/2-y/2.8, Gfx.FONT_SYSTEM_TINY, tpsRest,  Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);		
					dc.drawText(center_x, y*2+y/2, font, timeToString(estimateTimeRest), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);	
				}
			}
		
			if(gapTime.abs()<timeScalePartner*0.1){
				gapRunner = 0;
			}
			dc.drawBitmap(center_x-virtualPartnerIcon.getWidth()/2+10+gapRunner,center_y-virtualPartnerIcon.getHeight()/2,virtualPartnerIcon);
			if(gapRunner > center_y-30){
				gapRunner=center_y-30;
			}else if(gapRunner<-(center_y-30)){
				gapRunner=-(center_y-30);
			}
			dc.drawBitmap(center_x-runnerIcon.getWidth()/2+(gapRunner*-1),center_y-runnerIcon.getHeight()/2,runnerIcon);
    	}
    }
        
    function timeToString(long){
		var seconds = long % 60;
		var minutes = (long / 60) % 60;
		var hour = long/60/60;
		if(hour>0){
			return hour+":"+minutes.format("%02d")+":"+seconds.format("%02d");
		}else{
			return minutes+":"+seconds.format("%02d");
		}
	}
}
