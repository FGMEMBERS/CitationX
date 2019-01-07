### Citation X ###
### Christian Le Moigne (clm76) - 2015 rev. 2018  ###
###														                    ###
###        MESSAGES                               ###
### level 0 = white 					                    ###
### level 1 = cyan 						                    ###
### level 2 = caution = amber                     ###
### level 3 = alert = red 		                    ###

### ANNUNCIATORS ###
var Test_annun = props.globals.initNode("instrumentation/annunciators/test-select",0,"INT");
var MstrWarning = "instrumentation/annunciators/master-warning";
var WarningAck = "instrumentation/annunciators/ack-warning";
var MstrCaution = "instrumentation/annunciators/master-caution";
var Warn = "instrumentation/annunciators/warning";
var Caution = "instrumentation/annunciators/caution";
var CautionAck = "instrumentation/annunciators/ack-caution";
var no_takeoff_l3 = nil;
var msg = nil;
var msg0 = nil;
var msg_tmp = nil;
var alert = nil;
var kias = nil;
var wow1 = nil;
var wow2 = nil;
var stall_warn = nil;
var grdn = nil;
var flap = nil;
var x = 0;

aircraft.light.new("instrumentation/annunciators", [0.5, 0.5], MstrCaution);
aircraft.light.new("instrumentation/annunciators", [0.5, 0.5], MstrWarning);

var annun_init = func {
	  setprop(MstrWarning,0);
    setprop(MstrCaution,0);
		setprop(WarningAck,0);
		setprop(CautionAck,0);
		setprop(Caution,0);
		setprop(Warn,0);
};
	
var ann_stl = setlistener("/sim/signals/fdm-initialized", func {
    annun_init();
    removelistener(ann_stl);
},0,0);

setlistener("/sim/signals/reinit", func {
    annun_init();
},0,0);

var EICAS = {
    new : func {
         m = { parents : [EICAS]};
 
			m.eicas = props.globals.initNode("instrumentation/eicas/");
			m.warn_l0 = m.eicas.initNode("level-0"," ","STRING");
			m.warn_l1 = m.eicas.initNode("level-1"," ","STRING");
			m.warn_l2 = m.eicas.initNode("level-2"," ","STRING");			
			m.warn_l3 = m.eicas.initNode("level-3"," ","STRING");

		return m
		},

		init : func {	
			me.my_caution = 0;
			me.my_warning = 0;
		},

    listen : func {
      setlistener("instrumentation/annunciators/test-select", func(n) {
        me.test_timer = maketimer(0,func() {
          me.Tests(n.getValue());
        });
        if (n.getValue() > 0 and !me.test_timer.isRunning) {
          me.test_timer.start();
        } else {me.test_timer.stop()}
      },0,0);
    }, # end of listen

		update : func {
			me.eng0_shutdown = getprop("controls/engines/engine[0]/cutoff");
			me.eng1_shutdown = getprop("controls/engines/engine[1]/cutoff");
			me.parkbrake = getprop("controls/gear/brake-parking");
			me.emerbrake = getprop("controls/gear/emer-brake");
			me.apu_running = getprop("controls/electric/APU-generator");
			me.ext_pwr = getprop("controls/electric/external-power");
			me.cabin_door = getprop("controls/cabin-door/open");
			me.cabin_alt = getprop("systems/pressurization/cabin-alt-ft");
			me.boost_pump_L = getprop("controls/fuel/tank[0]/boost_pump");
			me.boost_pump_R = getprop("controls/fuel/tank[1]/boost_pump");
			me.level_tank_L = getprop("consumables/fuel/tank[0]/level-lbs");
			me.level_tank_R = getprop("consumables/fuel/tank[1]/level-lbs");
			me.total_fuel = getprop("consumables/fuel/total-ctrtk-lbs");
			me.grav_xflow = getprop("controls/fuel/gravity-xflow");
			me.xfeed_L = getprop("controls/engines/engine[0]/feed-tank");
			me.xfeed_R = getprop("controls/engines/engine[1]/feed-tank");
			me.xfer_L = getprop("controls/fuel/xfer-L");
			me.xfer_R = getprop("controls/fuel/xfer-R");
			me.gen_L = getprop("controls/electric/engine[0]/generator");
			me.gen_R = getprop("controls/electric/engine[1]/generator");
			me.oil_L = getprop("systems/hydraulics/psi-norm[0]");
			me.oil_R = getprop("systems/hydraulics/psi-norm[1]");
			me.speedbrake = getprop("controls/flight/speedbrake");
			me.flaps = getprop("controls/flight/flaps");
      me.flaps_sel = getprop("controls/flight/flaps-select");
			me.throttle_L = getprop("controls/engines/engine[0]/throttle");
			me.throttle_R = getprop("controls/engines/engine[1]/throttle");
			me.wow = getprop("gear/gear[0]/wow");
			me.test = getprop("instrumentation/annunciators/test-select");
			me.vmo = getprop("instrumentation/pfd/vmo-diff");
			me.stall = getprop("sim/sound/stall-horn");
			me.state = getprop("instrumentation/annunciators/state");
      me.agl = getprop("position/altitude-agl-ft");
      me.gear0 = getprop("gear/gear[0]/position-norm");
      me.gear1 = getprop("gear/gear[1]/position-norm");
      me.gear2 = getprop("gear/gear[2]/position-norm");
      if (getprop("systems/electrical/outputs/efis") > 12) me.enabled = 1;
      else {me.enabled = 0}

      me.msg_l0 = [];
			me.msg_l1 = [];
			me.msg_l2 = [];
			me.msg_l3 = [];
			me.nb_warning = 0;
			me.nb_caution = 0;
			me.nb_l1 = 0;
			me.nb_l0 = 0;
			no_takeoff_l3 = 0;

			if (me.enabled and me.test == 0) {		

					### lEVEL 3 ###
				if (me.cabin_alt > 10000) {
          append(me.msg_l3,"CABIN ALTITUDE");
					me.nb_warning +=1;
				}
				if (!me.gen_L and !me.gen_R) {			
         	append(me.msg_l3,"GEN OFF L-R");
					me.nb_warning +=1;
				}
				if (me.oil_L < 0.080 and me.oil_R < 0.080) {
          append(me.msg_l3,"OIL PRESS LOW L-R");
					me.nb_warning +=1;
				}	else if(me.oil_L < 0.4) {
          append(me.msg_l3,"OIL PRESS LOW L");
					me.nb_warning +=1;
				}	else if(me.oil_R < 0.4) {
          append(me.msg_l3,"OIL PRESS LOW R");
					me.nb_warning +=1;
				}
				if(me.wow and !me.eng0_shutdown and !me.eng1_shutdown and (
						me.ext_pwr
						or me.parkbrake 
						or me.emerbrake 
						or me.speedbrake
						or me.total_fuel <= 500)) {
					append(me.msg_l3,"NO TAKEOFF");
					me.nb_warning +=1;
					no_takeoff_l3 = 1;
				}			
				if(me.vmo >= -59) {
					append(me.msg_l3,"OVERSPEED");
					setprop("sim/alarms/overspeed-alarm",1);
					me.nb_warning +=1;
				} else {
					setprop("sim/alarms/overspeed-alarm",0);
				}
				if(me.stall and me.cabin_alt > 35000) {
					append(me.msg_l3,"MINIMUM SPEED");
					me.nb_warning +=1;
				}

					### LEVEL 2 ###
				if(!me.gen_L and me.gen_R) {
         	append(me.msg_l2,"GEN OFF L");
					me.nb_caution +=1;
				}	else if(!me.gen_R and me.gen_L) {
          append(me.msg_l2,"GEN OFF R");;
					me.nb_caution +=1;
				}
				if (me.cabin_door) {
          append(me.msg_l2,"CABIN DOOR OPEN");
					me.nb_caution +=1;
				}
				if (me.cabin_alt > 8500) {
          append(me.msg_l2,"CABIN ALTITUDE");
					me.nb_caution +=1;
				}
				if (me.level_tank_L < 100 and me.level_tank_R < 100) {
          append(me.msg_l2,"FUEL LEVEL L-R");
					me.nb_caution +=2;
				}	else if( me.level_tank_L < 100) {
          append(me.msg_l2,"FUEL LEVEL L");
					me.nb_caution +=1;
				}	else if( me.level_tank_R < 100) {
          append(me.msg_l2,"FUEL LEVEL R");
					me.nb_caution +=1;
				}
				if (me.speedbrake and me.cabin_alt < 500) {
          append(me.msg_l2,"SPEEDBRAKES");
					me.nb_caution +=1;
				}

					### LEVEL 1 ###
				if (me.eng0_shutdown and me.eng1_shutdown){
					append(me.msg_l1,"ENG SHUTDWN L-R");
					me.nb_l1 +=1;
				} else if (me.eng0_shutdown) {
						append(me.msg_l1,"ENG SHUTDWN L");
						me.nb_l1 +=1;
				}	else if (me.eng1_shutdown) {
						append(me.msg_l1,"ENG SHUTDWN R");
						me.nb_l1 +=1;
				}
				if (me.parkbrake) {
					append(me.msg_l1,"PARK BRK SET");
					me.nb_l1 +=1;
				}
				if (me.emerbrake) {
					append(me.msg_l1,"EMERGENCY BRAKE");
					me.nb_l1 +=1;
				}
				if(me.wow and (me.flaps < 0.140	or me.flaps > 0.430)and !no_takeoff_l3) {
					append(me.msg_l1,"NO TAKEOFF");
					me.nb_l1 +=1;
				}			

					### LEVEL 0 ###
				if (me.apu_running) {
          append(me.msg_l0,"APU RUNNING");
				#	me.nb_l0 +=1;
				}
				if (me.boost_pump_L and me.boost_pump_R) {
          	append(me.msg_l0,"BOOST PUMP L-R");
						me.nb_l0 +=1;
				}	else if (me.boost_pump_L) {
          	append(me.msg_l0,"BOOST PUMP L");
						me.nb_l0 +=1;
				}	else if (me.boost_pump_R) {
          	append(me.msg_l0,"BOOST PUMP R");
						me.nb_l0 +=1;
				}
				if (me.xfer_L and me.xfer_R) {
          	append(me.msg_l0,"CTR XFER XSIT L-R");
						me.nb_l0 +=1;
				}	else if (me.xfer_L) {
          	append(me.msg_l0,"CTR XFER XSIT L");
						me.nb_l0 +=1;
				}	else if (me.xfer_R) {
          	append(me.msg_l0,"CTR XFER XSIT R");
						me.nb_l0 +=1;
				}
				if (me.xfeed_L or me.xfeed_R) {
          	append(me.msg_l0,"FUEL XFEED OPEN");
						me.nb_l0 +=1;
				}
				if (me.grav_xflow) {
          	append(me.msg_l0,"FUEL XFLOW OPEN");
						me.nb_l0 +=1;
				}
				if (me.ext_pwr) {
						append(me.msg_l0,"EXT POWER ON");
						me.nb_l0 +=1;
				}
			  nb_msg = me.nb_warning + me.nb_caution + me.nb_l1 + me.nb_l0;
			  setprop("instrumentation/annunciators/nb-warning",nb_msg);
			  me.AnnunOutput();
			  me.EicasOutput();			
			} 

      ### Stall ###
			stall_speed();

      ### Gear oversight ###
      if ((me.flaps_sel == 4 or me.agl < 500) and !me.gear0 and !me.gear1 and !me.gear2 and getprop("velocities/vertical-speed-fps") <= 0) {
        setprop("instrumentation/alerts/gear-horn",1);
      } else setprop("instrumentation/alerts/gear-horn",0);
      
      #######

			settimer(func {me.update();},0);
		}, # end of update

    Tests : func (test_nb) {
      	me.msg_l0 = [];
				me.msg_l1 = [];
				me.msg_l2 = [];
				me.msg_l3 = [];
				setprop(WarningAck,0);
				setprop(CautionAck,0);
				me.warn_l3.setValue("");
				me.warn_l2.setValue("");
				me.warn_l1.setValue("");
				me.warn_l0.setValue("");
				append(me.msg_l3,"   ### TESTS ###");
				append(me.msg_l3," ");
				if (test_nb == 1) {
					append(me.msg_l3,"BAGGAGE SMOKE");
					setprop(MstrWarning,1);
					setprop(Warn,me.state);
					setprop(MstrCaution,0);
					setprop(Caution,0);
				}
				if (test_nb == 2) {
					append(me.msg_l0,"LANDING GEARS");
					setprop(MstrWarning,0);
					setprop(Warn,0);
				}
				if (test_nb == 3) {
					append(me.msg_l3,"ENGINE FIRE L-R");
					setprop(MstrWarning,1);
					setprop(Warn,me.state);
				}
				if (test_nb == 4) {
					append(me.msg_l3,"THRUST REVERSER");
					setprop(MstrWarning,1);
					setprop(Warn,me.state);
				}
				if (test_nb == 5) {
					append(me.msg_l2,"FLAPS FAIL");
					setprop(MstrWarning,0);
					setprop(MstrCaution,1);								
					setprop(Warn,0);
					setprop(Caution,me.state);
				}
				if (test_nb == 6) {
					append(me.msg_l2,"WSHLD HEAT L");
					append(me.msg_l2,"WSHLD HEAT R");
					append(me.msg_l2,"WSHLD TEMP L-R");
					setprop(MstrCaution,1);
					setprop(Caution,me.state);
				}
				if (test_nb == 7) {
					append(me.msg_l0,"OVERSPEED");
					setprop(MstrCaution,0);
					setprop(Caution,0);
				}
				if (test_nb == 8) {
					append(me.msg_l1,"AOA PROBE FAIL");
					append(me.msg_l1,"AUTO SLATS FAIL");
					append(me.msg_l1,"STALL WARN L-R");
					setprop(MstrCaution,0);
				}
				if (test_nb == 9) {
					append(me.msg_l1,"OIL PRESS L-R");
					append(me.msg_l1,"FUEL PRESS L-R");
					append(me.msg_l1,"HYD PUMPS FAIL");
					setprop(MstrWarning,1);
					setprop(Warn,me.state);
					setprop(MstrCaution,1);
					setprop(Caution,me.state);
				}
			  nb_msg = me.nb_warning + me.nb_caution + me.nb_l1 + me.nb_l0;
			  setprop("instrumentation/annunciators/nb-warning",nb_msg);
			  me.EicasOutput();			
    }, # end of Tests

		EicasOutput : func {	### MSG TO EICAS ###
				msg = "";
				msg0 = "               \n";
				msg_tmp = "";
				
					### LEVEL 3 - RED ###
        for(var i=0; i<size(me.msg_l3); i+=1) {
            msg = msg ~ me.msg_l3[i] ~ "\n";
						msg_tmp = msg_tmp~msg0;				
        }
        me.warn_l3.setValue(msg);

					### LEVEL 2 - AMBER ###
				msg = msg_tmp;
        for(var i=0; i<size(me.msg_l2); i+=1) {
            msg = msg ~ me.msg_l2[i] ~ "\n";
						msg_tmp = msg_tmp~msg0;			
        }
				me.warn_l2.setValue(msg);

					### LEVEL 1 - CYAN ###
				msg = msg_tmp;
        for(var i=0; i<size(me.msg_l1); i+=1) {
            msg = msg ~ me.msg_l1[i] ~ "\n";
						msg_tmp = msg_tmp~msg0;	
        }
				me.warn_l1.setValue(msg);

					### LEVEL 0 - WHITE ###
				msg = msg_tmp;
        for(var i=0; i<size(me.msg_l0); i+=1) {
            msg = msg ~ me.msg_l0[i] ~ "\n";
						msg_tmp = msg_tmp~msg0;	 
       	}
        me.warn_l0.setValue(msg);
		}, # end of EicasOutput

		AnnunOutput : func {	### ANNUNCIATORS ###

					### WARNING ###
				if (me.nb_warning == 0) {
					setprop(MstrWarning,0);
					setprop(Warn,0);
					setprop(WarningAck,0);
				} 
				else if (me.nb_warning > me.my_warning) {
					setprop(MstrWarning,1);
					setprop(Warn,me.state);
					setprop(WarningAck,0);
				} else {
					setprop(MstrWarning,1);
					setprop(Warn,me.state);
					if (getprop(WarningAck)) setprop(Warn,1);
				}
				me.my_warning = me.nb_warning;		

					### CAUTION ###
				if (me.nb_caution == 0) {
					setprop(MstrCaution,0);
					setprop(Caution,0);										
					setprop(CautionAck,0);
				} 
				else if (me.nb_caution > me.my_caution) {
					setprop(MstrCaution,1);
					setprop(Caution,me.state);
					setprop(CautionAck,0);
				} else {
					setprop(MstrCaution,1);
					setprop(Caution,me.state);														
					if (getprop(CautionAck)) setprop(Caution,1);
				}
				me.my_caution = me.nb_caution;
		}, # end of AnnunOutput

};

var	stall_speed = func {
    alert = 0;
    kias = getprop("velocities/airspeed-kt");
    wow1 = getprop("gear/gear[1]/wow");
    wow2 = getprop("gear/gear[2]/wow");;
		stall_warn = getprop("instrumentation/pfd/stall-warning");
    grdn = getprop("controls/gear/gear-down");
    flap = getprop("controls/flight/flaps");

		### Activation Stall System ###
		if (getprop("position/altitude-agl-ft") > 400) {
			setprop("instrumentation/pfd/stall-warning",1);
		} else if (wow1 or wow2){
				setprop("instrumentation/pfd/stall-warning",0);		
		}
		### Set Stall Speed Alarm / Flaps ###
    if(stall_warn and (!wow1 or !wow2)){
			if (flap == 0.0){
				setprop("instrumentation/pfd/stall-speed",145);			
      	if(kias<=145){
					alert=1;
					setprop("controls/flight/flaps",0.0428); ### Extension Slats ###
				}
			}
			if (flap == 0.0428){
				setprop("instrumentation/pfd/stall-speed",135);
				if (kias<=135){alert=1}
			}
			if (flap == 0.142){
				setprop("instrumentation/pfd/stall-speed",130);
				if (kias<=130){alert=1}
			}
			if (flap == 0.428){
				setprop("instrumentation/pfd/stall-speed",125);
				if (kias<=125){alert=1}
			}
			if (flap == 1){
				setprop("instrumentation/pfd/stall-speed",115);
				if (kias<=115){alert=1}
			}
    }
   setprop("sim/sound/stall-horn",alert);
} # end of stall_speed

### MAIN ###
var alarms = EICAS.new();
	var warn_stl = setlistener("/sim/signals/fdm-initialized", func {
		alarms.init();
    alarms.listen();
		alarms.update();	
		removelistener(warn_stl);
	});
