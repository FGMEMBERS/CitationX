## Checklists System ##
## Christian Le Moigne (clm76) - Avril 2016 ##

props.globals.initNode("instrumentation/checklists/skip",0,"BOOL");
props.globals.initNode("instrumentation/checklists/chklst-pilot",0,"BOOL");
var norm_p = "instrumentation/checklists/norm";
var abn_p = "instrumentation/checklists/abn";
var nr_page = "instrumentation/checklists/nr-page";
var page = 0;
var tittle = "";
var lines_L = "";
var lines_R = "";
var chklst = 0;
var nr_voice = 1;
var upd = 0;
var nb = 0;

for (var ind=0;ind<15;ind+=1) {
	props.globals.initNode("instrumentation/checklists/chk["~ind~"]",0,"BOOL");
}

setlistener("/sim/signals/fdm-initialized", func {
    print("Vocal Checklists ... Ok");
});

####################### CHECKLISTS ######################

### PRESTART ###
var T0 = "PRESTART";
var L0 = ['External Preflight','Documents','Passengers','Parking Brake','Throttles','L / R Generator Switches','L / R Fuel Boost Switches','L / R Ignition Switches','L / R Center Wing Transfer','Standby Power','Engine Area','Cabin Doors','Seat Belts','Battery 1 / 2','Gnd Rec Lights'];
var R0 = ['COMPLETE','ON BOARD','BOARD / BRIEF', 'SET','CUTOFF','GEN','NORM','NORM','NORM','ON','CLEAR','CLOSE AND LATCH','FASTEN','ON','ON'];

### APU START ###
var T1 = "APU START";
var L1 = ['APU MasterSwitch','APU Test Button','APU Start','APU Ready To Load','APU Generator Switch','APU DC Volts','APU Bleed Air','Bleed Valve Open'];
var R1 = ['ON','PUSH / VERIFY','ON','ILLUMINATED','ON','CHECK 22v min','ON', 'ILLUMINATED'];

### STARTUP ###
var T2 = "STARTUP";
var L2 = ['Avionics Switch','Radio','Autopilot','Fuel','Warning Test','Altimeter','Hydraulics','Seat Belt Lts'];
var R2 = ['ON','CHECK','DISENGAGED','CHECK QTY LBS','COMPLETE','SET','CHECK','PASS SAFETY'];

### CABIN PRESSURIZATION ###
var T3 = "CABIN PRESSURIZATION";
var L3 = ['Pressurization Switches','            or','Pressurization Control','Rate Control','ALT Select'];
var R3 = ['NORM','','ALT SELECT','SET 500 fpm','SET 1000 ab Cruise Alt'];

###  START ENGINES ###
var T4 = "LEFT ENGINE START";
var L4 = ['Throttle','Starter','Left Engine','N2 at 56%','N1 Rotation','Oil Pressure','ITT Stable','Volts / Amp / Oil'];
var R4 = ['CUTOFF','ON','START','VERIFY','CONFIRM','CHECK','VERIFY','CHECK'];

var T5 = "RIGHT ENGINE START";
var L5 = ['Throttle','Starter','Right Engine','N2 at 56%','N1 Rotation','Oil Pressure','ITT Stable','Volts / Amp / Oil'];
var R5 = ['CUTOFF','ON','START','VERIFY','CONFIRM','CHECK','VERIFY','CHECK'];

###  BEFORE TAXI ###
var T6 = "BEFORE TAXI";
var L6 = ['Flight Controls','L / R Pitot Heat','Taxi Lights','Transponder','(AP) Initial Altitude','(AP) Initial HDG','(AP) Initial CRS','Flight Plan Clearance','Taxi Instructions','Anti Coll Lights'];
var R6 = ['FREE & CORRECT','ON','ON','CODE SET / STBY','SET','SET','SET','COPIED','RECEIVED','ON'];

### TAXIING ###
var T7 = "TAXIING";
var L7 = ['Parking Brake','Taxi Area','Throttles','Brakes','Flight Instruments',''];
var R7 = ['OFF','CLEAR','ADVANCE SLOWLY','CHECK','CHECK','','TAXI TO RUNWAY : Max 20 kts   '];

### BEFORE TAKEOFF ###
var T8 = "BEFORE TAKEOFF";
var L8 = ['Flight Timer','Flaps Slats','Speed Brakes','Taxi Lights','Landing Lights','Navigation Lights','Annunciator Panel','Transponder'];
var R8 = ['SET','15 deg','RETRACTED','OFF','ON','ON','CLEAR','SET ALT'];

### TAKEOFF ###
var T9 = "TAKEOFF";
var L9 = ['Brakes','Throttles','Brakes','Landing Gear','','','Flaps / Slats','EICAS','Annunciator','Instruments','Throttles','EICAS:Both Engines'];
var R9 = ['HOLD','TAKEOFF THRUST','RELEASE','RETRACT','','Above 170 KIAS         ','RETRACT','CHECK NORMAL','CHECK','CHECK','SET CLIMB POWER','N1 max 98%'];

### APU SHUTDOWN ###
var T10 = "APU SHUTDOWN";
var L10 = ['APU Start Switch','APU Bleed Air','READY TO LOAD','APU Generator','APU Master'];
var R10 = ['STOP','OFF','EXTINGUISHED','OFF','OFF'];  

### CRUISE CLIMB ###
var T11 = "CRUISE CLIMB";
var L11 = ['','','Autopilot','Fuel Quantity','Seat Belts Switch','Landing Lights','Pressurization System'];
var R11 = ['Trim Initial Climb 250 KIAS/2500 fpm','','CHECK','CHECK','OFF','OFF','CHECK','','Max Speed below 8,000 is 270 KIAS','','Above FL180 set altimeters to 29.92'];

### CRUISE ###
var T12 = "CRUISE";
var L12 = ['Engines Instruments','Fuel Quantity'];
var R12 = ['CHECK','CHECK'];

### DESCENT ###
var T13 = "DESCENT";
var L13 = ['LH / RH Windshield Anti-Ice','APU','Seat Belt Switch','','','','','','',''];
var R13 = ['ON','AS DESIRED below FL310','ON','','Desc Airspeed to FL310  0.65 mach','','','Max Speed above 8,000 is 280 KIAS','Max Speed below 8,000 is 250 KIAS'];

### APPROACH ###
var T14 = "APPROACH";
var L14 = ['Altimeter','Seat Belt Lts','Landing Lights','Airspeed','Slats','','Flaps','Airspeed','Flaps','Airspeed','Landing Gear','','Flaps','Airspeed','Parking Brake'];
var R14 = ['SET TO LOCAL','PASS SAFETY','ON','200 KIAS','DEPLOY','At approximately 7nm from Runway ','SET 5 deg','180 KIAS','SET 15 deg','160 KIAS','DOWN','Short Final              ','FULL 35 deg','140 KIAS','OFF'];

### BEFORE LANDING ###
var T15 = "BEFORE LANDING";
var L15 = ['Landing Gear','Autopilot','Landing Speed'];
var R15 = ['3 GREEN LIGHTS','DISENGAGE','120 KIAS'];

### LANDING ###
var T16 = "LANDING";
var L16 = ['Throttles','','','','Brakes','Reverse Thrust',''];
var R16 = ['IDLE','','After Nose Wheel Touchdown   ','','AS REQUIRED','AS REQUIRED','','At 65 kts Disengage Reverse Thrust '];

### AFTER LANDING ###
var T17 = "AFTER LANDING";
var L17 = ['Flaps','Landing Lights','Taxi Lights','Flight Timer','Transponder'];
var R17 = ['RETRACT','OFF','ON','STOP','STANDBY'];

### SHUTDOWN ###
var T18 = "SHUTDOWN";
var L18 = ['Ice Equipment','Throttles','Parking Brake','Seat Belt Lts','L / R Ignition Switches','L / R Generator Switches','Standby Power','Nav lights','Taxi lights','Anti Coll Lights','APU','Avionics Switch','Battery 1 / 2'];
var R18 = ['OFF','CUTOFF','SET','OFF','OFF','OFF','OFF','OFF','OFF','OFF','SHUTDOWN','OFF','OFF'];

var L = [L0,L1,L2,L3,L4,L5,L6,L7,L8,L9,L10,L11,L12,L13,L14,L15,L16,L17,L18];
var n = 0;

### Listener Norm Button ###
var norm_l = setlistener(norm_p, func(n) {
	if (n.getValue()) {
		page = getprop(nr_page);		
		display(page);
	} else {
		if (timer.isRunning) {timer.stop()}
		page_btn();
		nb = 0;
		nr_voice = 0;
		upd = 0;
	}
},0,0);

### Listener Page Button ###
var pg = setlistener(nr_page, func(n) {
	if (getprop(norm_p)) {
		if (timer.isRunning) {timer.stop()}	
			page = n.getValue();
			setprop("instrumentation/checklists/nr-voice",0);
			upd = 0;
			display(page);
			clear_voice();
	}
},0,0);

### Listener abn Button ###
var abn	= setlistener(abn_p, func(n) {
	if (n.getValue() and !timer.isRunning and getprop(norm_p)) {	
			clear_voice();
			upd = 1;
			nb = 1;
			voices_prop(page);
			timer.start();
	}
},0,0);

### RAZ Voices Checks ###
var clear_voice = func {
	for (var ind=0;ind<15;ind+=1) {
		setprop("instrumentation/checklists/chk["~ind~"]",0);
	}
}
### Timer ###
var timer = maketimer(1.8,func {	
	 	var np = size(L[page])*2;
		if (nb <= np) {
			nr_voice = nb;
		  setprop("instrumentation/checklists/nr-voice",nr_voice);
		  test_prop(nb,timer);
			nb += 1;		
		}	else {upd = 0;timer.stop()}
});

### Display ###
var clear_display = func {
	var init = [];
	for (var i=0; i<16; i+=1) {
		append(init,"");
	}
	var tittle = "";
	var lines_L = var lines_R = init;
	setprop("instrumentation/checklists/Tittle", tittle);
	forindex (var ind; lines_L) {
		setprop("instrumentation/checklists/L["~ind~"]",lines_L[ind]);
	}
	forindex (var ind; lines_R) {
		setprop("instrumentation/checklists/R["~ind~"]",lines_R[ind]);
	}
}

var display = func(page) {
	var T =[T0,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18];
	var L = [L0,L1,L2,L3,L4,L5,L6,L7,L8,L9,L10,L11,L12,L13,L14,L15,L16,L17,L18];
	var R = [R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,R13,R14,R15,R16,R17,R18];
	clear_display();
	setprop("instrumentation/checklists/Tittle", T[page]);
	forindex (var ind; L[page]) {
		setprop("instrumentation/checklists/L["~ind~"]",L[page][ind]);
	}
	forindex (var ind; R[page]) {
		setprop("instrumentation/checklists/R["~ind~"]",R[page][ind]);
	}
}

### Next page ###
var next = func {
	page = getprop(nr_page);
	upd = 0;
	if (page < 18) {
		page += 1;
		setprop(nr_page,page);
	}
}

### Previous page ###
var previous = func {
	page = getprop(nr_page);
	upd = 0;
	if (page >= 1) {
		page -= 1;		
		setprop(nr_page,page);
	}
}

### Page Button ###
var page_btn = func() {
	var chk_pil = "instrumentation/checklists/chklst-pilot";
	if (!getprop(chk_pil) and getprop(norm_p)) {setprop(chk_pil,1)}
	else if (getprop(chk_pil) or !getprop(norm_p)) {setprop(chk_pil,0)}
}

### Properties Checks ###
var test_prop = func(nb,timer) {
	var skp = "instrumentation/checklists/skip";
	var prop = "";
		if (nb == 1) {prop = "instrumentation/checklists/chk[0]"}
		if (nb == 3) {prop = "instrumentation/checklists/chk[1]"}
		if (nb == 5) {prop = "instrumentation/checklists/chk[2]"}
		if (nb == 7) {prop = "instrumentation/checklists/chk[3]"}
		if (nb == 9) {prop = "instrumentation/checklists/chk[4]"}
		if (nb == 11) {prop = "instrumentation/checklists/chk[5]"}
		if (nb == 13) {prop = "instrumentation/checklists/chk[6]"}
		if (nb == 15) {prop = "instrumentation/checklists/chk[7]"}
		if (nb == 17) {prop = "instrumentation/checklists/chk[8]"}
		if (nb == 19) {prop = "instrumentation/checklists/chk[9]"}
		if (nb == 21) {prop = "instrumentation/checklists/chk[10]"}
		if (nb == 23) {prop = "instrumentation/checklists/chk[11]"}
		if (nb == 25) {prop = "instrumentation/checklists/chk[12]"}
		if (nb == 27) {prop = "instrumentation/checklists/chk[13]"}
		if (nb == 29) {prop = "instrumentation/checklists/chk[14]"}

	if(prop != ""){
		if (!getprop(prop)){
			timer.stop();
			var running = 1;
			var loop = func {   ### boucle d'attente de validation ###
				if (running and upd) {
					if (getprop(prop) or getprop(skp)) {				
						running = 0;
						timer.restart(1.8);				
					}
					settimer(loop,0);
				}       
			}
			loop();
		}
	}
}

### Update Voices Properties ###
var voices_prop = func {
	if (upd) {
		if (page == 0) {   ### Prestart ###
			setprop("instrumentation/checklists/chk[0]",1);
			setprop("instrumentation/checklists/chk[1]",1);
			setprop("instrumentation/checklists/chk[2]",1);
			if (getprop("controls/gear/brake-parking")) {setprop("instrumentation/checklists/chk[3]",1)}
			if (getprop("controls/engines/engine[0]/throttle") == 0 and getprop("controls/engines/engine[1]/throttle") == 0) {setprop("instrumentation/checklists/chk[4]",1)}
			if (getprop("controls/electric/engine[0]/generator") and getprop("controls/electric/engine[1]/generator")) {setprop("instrumentation/checklists/chk[5]",1)}
			if (getprop("controls/fuel/tank[0]/boost_pump")== 0 and getprop("controls/fuel/tank[1]/boost_pump")== 0) {setprop("instrumentation/checklists/chk[6]",1)}
			if (getprop("controls/engines/engine[0]/ignit")== -1 and getprop("controls/engines/engine[1]/ignit")== -1) {setprop("instrumentation/checklists/chk[7]",1)}
			if (getprop("controls/fuel/xfer-L")== 0 and getprop("controls/fuel/xfer-R")== 0) {setprop("instrumentation/checklists/chk[8]",1)}
			if (getprop("controls/electric/std-by-pwr")) {setprop("instrumentation/checklists/chk[9]",1)}
			setprop("instrumentation/checklists/chk[10]",1);
			if (getprop("controls/cabin-door/position-norm")== 0) {setprop("instrumentation/checklists/chk[11]",1)}
			setprop("instrumentation/checklists/chk[12]",1);
			if (getprop("controls/electric/battery-switch") and getprop("controls/electric/battery-switch[1]")) {setprop("instrumentation/checklists/chk[13]",1)}
			if (getprop("controls/lighting/beacon")) {setprop("instrumentation/checklists/chk[14]",1)}
		}

		if (page == 1){   ### APU Start ###
			if (getprop("controls/APU/master")) {setprop("instrumentation/checklists/chk[0]",1)}
			if (getprop("controls/APU/test")) {setprop("instrumentation/checklists/chk[1]",1)}
			if (getprop("controls/APU/start-stop")== 1 or getprop("controls/APU/rpm")== 1) {setprop("instrumentation/checklists/chk[2]",1)}
			if (getprop("controls/APU/rpm")== 1) {setprop("instrumentation/checklists/chk[3]",1)}
			if (getprop("controls/electric/APU-generator")) {setprop("instrumentation/checklists/chk[4]",1)}
			if (getprop("controls/APU/battery")== 28) {setprop("instrumentation/checklists/chk[5]",1)}
			if (getprop("controls/APU/bleed")!= 0) {setprop("instrumentation/checklists/chk[6]",1)}
			if (getprop("controls/APU/bleed")!= 0 and getprop("controls/APU/rpm") ==1) {setprop("instrumentation/checklists/chk[7]",1)}
		}

		if (page == 2){   ### Startup ###
			if (getprop("controls/electric/avionics-switch")==2) {setprop("instrumentation/checklists/chk[0]",1)}
			setprop("instrumentation/checklists/chk[1]",1);
			setprop("instrumentation/checklists/chk[2]",1);
			setprop("instrumentation/checklists/chk[3]",1);
			if (getprop("instrumentation/annunciators/test-select")==9) {setprop("instrumentation/checklists/chk[4]",1)}
			if (getprop("instrumentation/altimeter/indicated-altitude-ft")>-10 and getprop("instrumentation/altimeter/indicated-altitude-ft")< 20) {setprop("instrumentation/checklists/chk[5]",1)}
			setprop("instrumentation/checklists/chk[6]",1);
			if (getprop("controls/electric/seat-belts-switch")== -1) {setprop("instrumentation/checklists/chk[7]",1)}
		}

		if (page == 3){   ### Cabin Pressurization ###
			if (!getprop("controls/pressurization/alt-sel") and !getprop("controls/pressurization/press-man")) {setprop("instrumentation/checklists/chk[0]",1)}
		}

		if (page == 4) {   ### Left Engine Start ###
			if (getprop("controls/engines/engine[0]/throttle") == 0) {setprop("instrumentation/checklists/chk[0]",1)}
			if (getprop("controls/engines/engine[0]/starter")) {setprop("instrumentation/checklists/chk[1]",1)}
			if (!getprop("controls/engines/engine[0]/cutoff")) {setprop("instrumentation/checklists/chk[2]",1)}
			if (getprop("engines/engine[0]/n2") >= 56) {setprop("instrumentation/checklists/chk[3]",1)}
			if (getprop("engines/engine[0]/n1") >= 40) {setprop("instrumentation/checklists/chk[4]",1)}
			if (getprop("systems/hydraulics/psi-norm")) {setprop("instrumentation/checklists/chk[5]",1)}
			setprop("instrumentation/checklists/chk[6]",1);
			setprop("instrumentation/checklists/chk[7]",1);
		}
		if (page == 5) {   ### Right Engine Start ###
			if (getprop("controls/engines/engine[1]/throttle") == 0) {setprop("instrumentation/checklists/chk[0]",1)}
			if (getprop("controls/engines/engine[1]/starter")) {setprop("instrumentation/checklists/chk[1]",1)}
			if (!getprop("controls/engines/engine[1]/cutoff")) {setprop("instrumentation/checklists/chk[2]",1)}
			if (getprop("engines/engine[1]/n2") >= 56) {setprop("instrumentation/checklists/chk[3]",1)}
			if (getprop("engines/engine[1]/n1") >= 40) {setprop("instrumentation/checklists/chk[4]",1)}
			if (getprop("systems/hydraulics/psi-norm")) {setprop("instrumentation/checklists/chk[5]",1)}
			setprop("instrumentation/checklists/chk[6]",1);
			setprop("instrumentation/checklists/chk[7]",1);
		}

		if (page == 6) {   ### Before Taxi ###
			setprop("instrumentation/checklists/chk[0]",1);
			if (getprop("controls/anti-ice/pitot-heat") and getprop("controls/anti-ice/pitot-heat[1]")) {setprop("instrumentation/checklists/chk[1]",1)}
			if (getprop("controls/lighting/taxi-lights")) {setprop("instrumentation/checklists/chk[2]",1)}
			setprop("instrumentation/checklists/chk[3]",1);
			if (getprop("autopilot/settings/asel")> 0) {setprop("instrumentation/checklists/chk[4]",1)}

			var old_hdg = getprop("autopilot/settings/heading-bug-deg");
				var hdg = setlistener("autopilot/settings/heading-bug-deg", func (n) {
					if (n.getValue() != old_hdg) {
						setprop("instrumentation/checklists/chk[5]",1);
						removelistener(hdg);
					}
				},0,0);

			if (getprop("autopilot/settings/nav-source")=="NAV1" or getprop("autopilot/settings/nav-source")=="NAV2") {
				var old_crs = getprop("autopilot/internal/selected-crs");
				var crs = setlistener("autopilot/internal/selected-crs", func (n) {
					if (n.getValue() != old_crs) {
						setprop("instrumentation/checklists/chk[6]",1);
						removelistener(crs);
					}
				},0,0);
			} else {setprop("instrumentation/checklists/chk[6]",1)}

			setprop("instrumentation/checklists/chk[7]",1);
			setprop("instrumentation/checklists/chk[8]",1);
			if (getprop("controls/lighting/strobe")) {setprop("instrumentation/checklists/chk[9]",1)}
		}

		if (page == 7) {   ### Taxiing ###
			if (!getprop("controls/gear/brake-parking")) {setprop("instrumentation/checklists/chk[0]",1)}
			setprop("instrumentation/checklists/chk[1]",1);
			setprop("instrumentation/checklists/chk[2]",1);
			if (getprop("controls/gear/brake-left") and getprop("controls/gear/brake-right")) {setprop("instrumentation/checklists/chk[3]",1)}
			setprop("instrumentation/checklists/chk[4]",1);
			setprop("instrumentation/checklists/chk[5]",1);
		}

		if (page == 8) {   ### Before Takeoff ###
			if (getprop("instrumentation/primus2000/dc840/etx")==1) {setprop("instrumentation/checklists/chk[0]",1)}	
			if (getprop("controls/flight/flaps-select")>1) {setprop("instrumentation/checklists/chk[1]",1)}	
			if (!getprop("controls/flight/speedbrake")) {setprop("instrumentation/checklists/chk[2]",1)}	
			if (!getprop("controls/lighting/taxi-lights")) {setprop("instrumentation/checklists/chk[3]",1)}
			if (getprop("controls/lighting/landing-light") or getprop("controls/lighting/landing-light[1]")) {setprop("instrumentation/checklists/chk[4]",1)}
			if (getprop("controls/lighting/nav-lights")) {setprop("instrumentation/checklists/chk[5]",1)}
			if (getprop("instrumentation/annunciators/nb-warning")==0) {setprop("instrumentation/checklists/chk[6]",1)}
			setprop("instrumentation/checklists/chk[7]",1);
		}

		if (page == 9) {   ### Takeoff ###
			if (getprop("controls/gear/brake-left") and getprop("controls/gear/brake-right")) {setprop("instrumentation/checklists/chk[0]",1)}
			if (getprop("controls/engines/engine[0]/throttle")>0.75 and getprop("controls/engines/engine[1]/throttle")>0.75) {setprop("instrumentation/checklists/chk[1]",1)}
			if (!getprop("controls/gear/brake-left") and !getprop("controls/gear/brake-right")) {setprop("instrumentation/checklists/chk[2]",1)}
			if (!getprop("controls/gear/gear-down")) {setprop("instrumentation/checklists/chk[3]",1)}
			setprop("instrumentation/checklists/chk[4]",1);
			setprop("instrumentation/checklists/chk[5]",1);
			if (getprop("controls/flight/flaps-select")==0) {setprop("instrumentation/checklists/chk[6]",1)}	
			setprop("instrumentation/checklists/chk[7]",1);
			setprop("instrumentation/checklists/chk[8]",1);
			setprop("instrumentation/checklists/chk[9]",1);
			setprop("instrumentation/checklists/chk[10]",1);
			if (getprop("engines/engine[0]/n1")<98 and getprop("engines/engine[1]/n1")<98) {setprop("instrumentation/checklists/chk[11]",1)}
		}

		if (page == 10) {   ### APU Shutdown ###
			if (getprop("controls/APU/start-stop")== -1) {setprop("instrumentation/checklists/chk[0]",1)}
			if (getprop("controls/APU/bleed")== 0) {setprop("instrumentation/checklists/chk[1]",1)}
			if (getprop("controls/APU/rpm")< 1) {setprop("instrumentation/checklists/chk[2]",1)}
			if (!getprop("controls/electric/APU-generator")) {setprop("instrumentation/checklists/chk[3]",1)}
			if (!getprop("controls/APU/master")) {setprop("instrumentation/checklists/chk[4]",1)}
		}

		if (page == 11) {   ### Cruise Climb ###
			setprop("instrumentation/checklists/chk[0]",1);
			setprop("instrumentation/checklists/chk[1]",1);
			setprop("instrumentation/checklists/chk[2]",1);
      if (getprop("consumables/fuel/total-fuel-lbs") > 1200) {setprop("instrumentation/checklists/chk[3]",1)}
			if (getprop("controls/electric/seat-belts-switch")== 0) {setprop("instrumentation/checklists/chk[4]",1)}
			if (!getprop("controls/lighting/landing-light") and !getprop("controls/lighting/landing-light[1]")) {setprop("instrumentation/checklists/chk[5]",1)}
			setprop("instrumentation/checklists/chk[6]",1);
		}

		if (page == 12) {   ### Cruise ###
			setprop("instrumentation/checklists/chk[0]",1);
			if (getprop("consumables/fuel/total-fuel-lbs")>1000) {setprop("instrumentation/checklists/chk[1]",1)}
		}

		if (page == 13) {   ### Descent ###
			if (getprop("controls/anti-ice/window-heat") and getprop("controls/anti-ice/window-heat[1]")) {setprop("instrumentation/checklists/chk[0]",1)}
			setprop("instrumentation/checklists/chk[1]",1);
			if (getprop("controls/electric/seat-belts-switch")==1) {setprop("instrumentation/checklists/chk[2]",1)}
			setprop("instrumentation/checklists/chk[3]",1);
			setprop("instrumentation/checklists/chk[4]",1);
			setprop("instrumentation/checklists/chk[5]",1);
			setprop("instrumentation/checklists/chk[6]",1);
			setprop("instrumentation/checklists/chk[7]",1);
			setprop("instrumentation/checklists/chk[8]",1);
			setprop("instrumentation/checklists/chk[9]",1);
			setprop("instrumentation/checklists/chk[10]",1);
		}

		if (page == 14) {   ### Approach ###
			var alt_ind = getprop("instrumentation/altimeter/setting-inhg");
			var alt = setlistener("instrumentation/altimeter/setting-inhg", func (n) {
				if (n.getValue() != alt_ind) {
					setprop("instrumentation/checklists/chk[0]",1);
					removelistener(alt);
				}
			},0,0);
			if (getprop("controls/electric/seat-belts-switch")== -1) {setprop("instrumentation/checklists/chk[1]",1)}
			if (getprop("controls/lighting/landing-light") and getprop("controls/lighting/landing-light[1]")) {setprop("instrumentation/checklists/chk[2]",1)}
			setprop("instrumentation/checklists/chk[3]",1);
			if (getprop("controls/flight/flaps-select")==1) {setprop("instrumentation/checklists/chk[4]",1)}	
			setprop("instrumentation/checklists/chk[5]",1);
			if (getprop("controls/flight/flaps-select")==2 and getprop("autopilot/route-manager/distance-remaining-nm") < 8) {setprop("instrumentation/checklists/chk[6]",1)}	
			setprop("instrumentation/checklists/chk[6]",1);
			if (getprop("controls/flight/flaps-select")==3) {setprop("instrumentation/checklists/chk[8]",1)}	
			setprop("instrumentation/checklists/chk[9]",1);
			if (getprop("controls/gear/gear-down")) {setprop("instrumentation/checklists/chk[10]",1)}
			setprop("instrumentation/checklists/chk[11]",1);
			if (getprop("controls/flight/flaps-select")==4 and getprop("autopilot/route-manager/distance-remaining-nm") < 3) {setprop("instrumentation/checklists/chk[12]",1)}	
			setprop("instrumentation/checklists/chk[13]",1);
			if (!getprop("controls/gear/brake-parking")) {setprop("instrumentation/checklists/chk[14]",1)}
		}

		if (page == 15) {   ### Before Landing ###
			if (getprop("gear/gear[0]/position-norm") and getprop("gear/gear[1]/position-norm")and getprop("gear/gear[2]/position-norm")) {setprop("instrumentation/checklists/chk[0]",1)}
			if (getprop("autopilot/locks/disengage")) {setprop("instrumentation/checklists/chk[1]",1)}
			setprop("instrumentation/checklists/chk[2]",1);
		}

		if (page == 17) {   ### After Landing ###
			if (getprop("controls/flight/flaps-select")==0) {setprop("instrumentation/checklists/chk[0]",1)}	
			if (!getprop("controls/lighting/landing-light") or !getprop("controls/lighting/landing-light[1]")) {setprop("instrumentation/checklists/chk[1]",1)}
			if (getprop("controls/lighting/taxi-lights")) {setprop("instrumentation/checklists/chk[2]",1)}
			if (getprop("instrumentation/primus2000/dc840/etx")==2) {setprop("instrumentation/checklists/chk[3]",1)}	
			setprop("instrumentation/checklists/chk[4]",1);
		}

		if (page == 18) {   ### Shutdown ###
			if (!getprop("controls/anti-ice/window-heat") and !getprop("controls/anti-ice/window-heat[1]") and !getprop("controls/anti-ice/pitot-heat") and !getprop("controls/anti-ice/window-heat[1]")) {setprop("instrumentation/checklists/chk[0]",1)}
			if (getprop("controls/engines/engine[0]/throttle") == 0 and getprop("controls/engines/engine[1]/throttle") == 0) {setprop("instrumentation/checklists/chk[1]",1)}
			if (getprop("controls/gear/brake-parking")) {setprop("instrumentation/checklists/chk[2]",1)}
			if (getprop("controls/electric/seat-belts-switch")==0) {setprop("instrumentation/checklists/chk[3]",1)}
			if (getprop("controls/engines/engine[0]/ignit")== 0 and getprop("controls/engines/engine[1]/ignit")== 0) {setprop("instrumentation/checklists/chk[4]",1)}
			if (!getprop("controls/electric/engine[0]/generator") and !getprop("controls/electric/engine[1]/generator")) {setprop("instrumentation/checklists/chk[5]",1)}
			if (!getprop("controls/electric/std-by-pwr")) {setprop("instrumentation/checklists/chk[6]",1)}
			if (!getprop("controls/lighting/nav-lights")) {setprop("instrumentation/checklists/chk[7]",1)}
			if (!getprop("controls/lighting/taxi-lights")) {setprop("instrumentation/checklists/chk[8]",1)}
			if (getprop("controls/lighting/anti-coll")==0) {setprop("instrumentation/checklists/chk[9]",1)}
			if (!getprop("controls/APU/master")) {setprop("instrumentation/checklists/chk[10]",1)}
			if (getprop("controls/electric/avionics-switch")==0) {setprop("instrumentation/checklists/chk[11]",1)}
			if (!getprop("controls/electric/battery-switch") and !getprop("controls/electric/battery-switch[1]")) {setprop("instrumentation/checklists/chk[12]",1)}
		}
		settimer(voices_prop,0);
	}
}

