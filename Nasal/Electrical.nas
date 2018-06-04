####    jet engine electrical system    ####
####    Syd Adams    ####

props.globals.initNode("/systems/electrical/left-bus",0,"DOUBLE");
props.globals.initNode("/systems/electrical/right-bus",0,"DOUBLE");
props.globals.initNode("/systems/electrical/amps",0,"DOUBLE");
props.globals.initNode("/systems/electrical/xtie",0,"BOOL");
props.globals.initNode("controls/electric/avionics-power",0,"BOOL");
props.globals.initNode("controls/lighting/anti-coll",0,"INT");
var Lbus = "systems/electrical/left-bus";
var Rbus= "systems/electrical/right-bus";
var XTie  = "systems/electrical/xtie";
var AvPwr = "controls/electric/avionics-power";
var lbus_volts = 0.0;
var rbus_volts = 0.0;
var ammeter_ave = 0.0;
var count=0;

var lbus_input=[];
var lbus_output=[];
var lbus_load=[];

var rbus_input=[];
var rbus_output=[];
var rbus_load=[];

var lights_input=[];
var lights_output=[];
var lights_load=[];

var scnd = nil;
var bat1_sw = nil;
var bat2_sw = nil;
var l_emer = nil;
var l_norm = nil;
var r_emer = nil;
var r_norm = nil;
var apu_gen = nil;
var ext_pwr = nil;
var l_gen = nil;
var r_gen = nil;
var avionics = nil;
var PWR = nil;
var apu_volts = nil;
var xtie = nil;
var load = nil;;
var power_source = nil;
var bus_volts = nil;
var srvc = nil;

var strobe_switch = props.globals.getNode("controls/lighting/strobe", 1);
aircraft.light.new("controls/lighting/strobe-state", [0.05, 1.30], strobe_switch);
var beacon_switch = props.globals.getNode("controls/lighting/beacon", 1);
aircraft.light.new("controls/lighting/beacon-state", [1.0, 1.0], beacon_switch);
setprop("/controls/electric/external-power",0);
setprop("/systems/electrical/left-emer-bus",0);
setprop("/systems/electrical/left-bus-norm",0);
setprop("/systems/electrical/right-emer-bus",0);
setprop("/systems/electrical/right-bus-norm",0);

var Battery = {
    new : func(swtch,vlt,amp,hr,chp,cha){
    m = { parents : [Battery] };
            m.switch = props.globals.getNode(swtch,1);
            m.switch.setBoolValue(0);
            m.ideal_volts = vlt;
            m.ideal_amps = amp;
            m.amp_hours = hr;
            m.charge_percent = chp;
            m.charge_amps = cha;
    return m;
    },

    apply_load : func(load,dt) {
        if(me.switch.getValue()){
        var amphrs_used = load * dt / 3600.0;
        var percent_used = amphrs_used / me.amp_hours;
        me.charge_percent -= percent_used;
        if ( me.charge_percent < 0.0 ) {
            me.charge_percent = 0.0;
        } elsif ( me.charge_percent > 1.0 ) {
        me.charge_percent = 1.0;
        }
        var output =me.amp_hours * me.charge_percent;
        return output;
        }else return 0;
    },

    get_output_volts : func {
        if(me.switch.getValue()){
        var x = 1.0 - me.charge_percent;
        var tmp = -(3.0 * x - 1.0);
        var factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
        var output =me.ideal_volts * factor;
        return output;
        }else return 0;
    },

    get_output_amps : func {
        if(me.switch.getValue()){
        var x = 1.0 - me.charge_percent;
        var tmp = -(3.0 * x - 1.0);
        var factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
        var output =me.ideal_amps * factor;
        return output;
        }else return 0;
    }
}; # end of Battery

var Alternator = {
    new : func (num,switch,src,thr,vlt,amp){
        m = { parents : [Alternator] };
        m.switch =  props.globals.getNode(switch,1);
        m.switch.setBoolValue(0);
        m.meter =  props.globals.getNode("systems/electrical/gen-load["~num~"]",1);
        m.meter.setDoubleValue(0);
        m.gen_output =  props.globals.getNode("engines/engine["~num~"]/amp-v",1);
        m.gen_output.setDoubleValue(0);
        m.meter.setDoubleValue(0);
        m.rpm_source =  props.globals.getNode(src,1);
        m.rpm_threshold = thr;
        m.ideal_volts = vlt;
        m.ideal_amps = amp;
        return m;
    },

    apply_load : func(load) {
        var cur_volt=me.gen_output.getValue();
        var cur_amp=me.meter.getValue();
        if(cur_volt >1){
            var factor=1/cur_volt;
            gout = (load * factor);
            if(gout>1)gout=1;
        }else{
            gout=0;
        }
        me.meter.setValue(gout);
    },

    get_output_volts : func {
        var out = 0;
        if(me.switch.getBoolValue()){
            var factor = me.rpm_source.getValue() / me.rpm_threshold or 0;
            if ( factor > 1.0 )factor = 1.0;
            var out = (me.ideal_volts * factor);
        }
        me.gen_output.setValue(out);
        return out;
    },

    get_output_amps : func {
        var ampout =0;
        if(me.switch.getBoolValue()){
            var factor = me.rpm_source.getValue() / me.rpm_threshold or 0;
            if ( factor > 1.0 ) {
                factor = 1.0;
            }
            ampout = me.ideal_amps * factor;
        }
        return ampout;
    }
}; # end of Alternator

var battery = Battery.new("/controls/electric/battery-switch",24,30,34,1.0,7.0);
var battery1 = Battery.new("/controls/electric/battery-switch[1]",24,30,34,1.0,7.0);
var alternator1 = Alternator.new(0,"controls/electric/engine[0]/generator","/engines/engine[0]/fan",20.0,28.0,60.0);
var alternator2 = Alternator.new(1,"controls/electric/engine[1]/generator","/engines/engine[1]/fan",20.0,28.0,60.0);

#############
var init_switches = func{
    var AVswitch=props.globals.initNode("controls/electric/avionics-switch",0,"INT");
    setprop("controls/lighting/instruments-norm",0.0);
    setprop("controls/lighting/engines-norm",0.8);
    props.globals.initNode("controls/electric/ammeter-switch",0,"BOOL");
    props.globals.initNode("controls/electric/seat-belts-switch",0,"INT");
    props.globals.initNode("systems/electrical/serviceable",0,"BOOL");
    props.globals.initNode("controls/electric/external-power",0,"BOOL");
    props.globals.initNode("controls/electric/std-by-pwr",0,"INT");
    setprop("controls/lighting/efis-norm",0.8);
    setprop("controls/lighting/cdu",0.8);
    setprop("controls/lighting/cdu[1]",0.8);
#    setprop("controls/lighting/panel-norm",0.8);
    setprop("controls/lighting/nav-lights",0);
    setprop("controls/lighting/rmu",0.3);
    setprop("controls/lighting/rmu[1]",0.3);

    append(lights_input,props.globals.initNode("controls/lighting/landing-light[0]",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/landing-light[0]",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/landing-light[1]",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/landing-light[1]",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/nav-lights",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/nav-lights",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/cabin-lights",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/cabin-lights",0,"DOUBLE"));
    append(lights_load,1);
#    append(lights_input,props.globals.initNode("controls/lighting/instrument-lights",0,"BOOL"));
#    append(lights_output,props.globals.initNode("systems/electrical/outputs/instrument-lights",0,"DOUBLE"));
#    append(lights_load,1);
#    append(lights_input,props.globals.initNode("controls/lighting/map-light",0,"BOOL"));
#    append(lights_output,props.globals.initNode("systems/electrical/outputs/map-light",0,"DOUBLE"));
#    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/wing-lights",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/wing-lights",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/recog-lights",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/recog-lights",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/logo-lights",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/logo-lights",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/taxi-lights",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/taxi-lights",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/beacon-state/state",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/beacon",0,"DOUBLE"));
    append(lights_load,1);
    append(lights_input,props.globals.initNode("controls/lighting/strobe-state/state",0,"BOOL"));
    append(lights_output,props.globals.initNode("systems/electrical/outputs/strobe",0,"DOUBLE"));
    append(lights_load,1);

    append(rbus_input,props.globals.initNode("controls/electric/wiper-switch",0,"BOOL"));
    append(rbus_output,props.globals.initNode("systems/electrical/outputs/wiper",0,"DOUBLE"));
    append(rbus_load,1);
    append(rbus_input,props.globals.initNode("controls/engines/engine[0]/fuel-pump",0,"BOOL"));
    append(rbus_output,props.globals.initNode("systems/electrical/outputs/fuel-pump[0]",0,"DOUBLE"));
    append(rbus_load,1);
    append(rbus_input,props.globals.initNode("controls/engines/engine[1]/fuel-pump",0,"BOOL"));
    append(rbus_output,props.globals.initNode("systems/electrical/outputs/fuel-pump[1]",0,"DOUBLE"));
    append(rbus_load,1);
    append(rbus_input,props.globals.initNode("controls/engines/engine[0]/starter",0,"BOOL"));
    append(rbus_output,props.globals.initNode("systems/electrical/outputs/starter",0,"DOUBLE"));
    append(rbus_load,1);
    append(rbus_input,props.globals.initNode("controls/engines/engine[1]/starter",0,"BOOL"));
    append(rbus_output,props.globals.initNode("systems/electrical/outputs/starter[1]",0,"DOUBLE"));
    append(rbus_load,1);
    append(rbus_input,AVswitch);
    append(rbus_output,props.globals.initNode("systems/electrical/outputs/KNS80",0,"DOUBLE"));
    append(rbus_load,1);
    append(rbus_input,AVswitch);
    append(rbus_output,props.globals.initNode("systems/electrical/outputs/efis",0,"DOUBLE"));
    append(rbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/adf",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/dme",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/gps",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/DG",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/transponder",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/mk-viii",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/turn-coordinator",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/comm",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/comm[1]",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/nav",0,"DOUBLE"));
    append(lbus_load,1);
    append(lbus_input,AVswitch);
    append(lbus_output,props.globals.initNode("systems/electrical/outputs/nav[1]",0,"DOUBLE"));
    append(lbus_load,1);
}


update_virtual_bus = func(dt) {
    PWR = getprop("systems/electrical/serviceable");
		apu_volts = getprop("controls/APU/battery");
    xtie=0;
    load = 0.0;
    if(count==0){
        var battery_volts = battery.get_output_volts();
				if (apu_volts > battery_volts) {
					lbus_volts = apu_volts;
				} else {lbus_volts = battery_volts}
        power_source = "battery";
        var alternator1_volts = alternator1.get_output_volts();
        if (alternator1_volts > lbus_volts) {
            lbus_volts = alternator1_volts;
            power_source = "alternator1";
        }
        lbus_volts *=PWR;
        setprop(Lbus,lbus_volts);
        load += lh_bus(lbus_volts);
    }else{
        var battery1_volts = battery1.get_output_volts();
				if (apu_volts > battery1_volts) {
					rbus_volts = apu_volts;
				} else {rbus_volts = battery1_volts}
        power_source = "battery1";
        var alternator2_volts = alternator2.get_output_volts();
        if (alternator2_volts > rbus_volts) {
            rbus_volts = alternator2_volts;
            power_source = "alternator2";
        }
        rbus_volts *=PWR;
        setprop(Rbus,rbus_volts);
        load += rh_bus(rbus_volts);
    }
    count=1-count;
    if(rbus_volts > 5 and  lbus_volts>5) xtie=1;
    setprop(XTie,xtie);
    if(rbus_volts > 5 or  lbus_volts>5) load += lighting(24);

    ammeter = 0.0;
#    if ( bus_volts > 1.0 )load += 15.0;

#    if ( power_source == "battery" ) {
#        ammeter = -load;
#        } else {
#        ammeter = battery.charge_amps;
#    }

#    if ( power_source == "battery" ) {
#        battery.apply_load( load, dt );
#        } elsif ( bus_volts > battery_volts ) {
#        battery.apply_load( -battery.charge_amps, dt );
#        }

#    ammeter_ave = 0.8 * ammeter_ave + 0.2 * ammeter;

    alternator1.apply_load(load);
    alternator2.apply_load(load);

return load;
}

rh_bus = func(bv) {
    bus_volts = bv;
    load = 0.0;

    for(var i=0; i<size(rbus_input); i+=1) {
        srvc = rbus_input[i].getValue();
				if (srvc ==2) {srvc=1} ## switch avionics ##
       load += rbus_load[i] * srvc;
        rbus_output[i].setValue(bus_volts * srvc);
    }
    return load;
}

lh_bus = func(bv) {
    load = 0.0;

    for(var i=0; i<size(lbus_input); i+=1) {
        srvc = lbus_input[i].getValue();
				if (srvc ==2) {srvc=1} ## switch avionics ##
        load += lbus_load[i] * srvc;
        lbus_output[i].setValue(bv * srvc);
    }

    setprop("systems/electrical/outputs/flaps",bv);
    return load;
}

lighting = func(bv) {
    load = 0.0;

    for(var i=0; i<size(lights_input); i+=1) {
        srvc = lights_input[i].getValue();
        load += lights_load[i] * srvc;
        lights_output[i].setValue(bv * srvc);
    }
		return load;
}

########## Switches ###########
var l_emer = "systems/electrical/left-emer-bus";
var	l_norm = "systems/electrical/left-bus-norm";
var	r_emer = "systems/electrical/right-emer-bus";
var	r_norm = "systems/electrical/right-bus-norm";
var	apu_gen = "controls/electric/APU-generator";
var	ext_pwr = "controls/electric/external-power";
var	l_gen = "engines/engine[0]/amp-v";
var	r_gen = "engines/engine[1]/amp-v";


setlistener("controls/electric/battery-switch[0]",func(n) {
  if (n.getValue()) {
		if (getprop(ext_pwr) or getprop(apu_gen) or getprop(l_gen) >24 or getprop(r_gen) >24) {
			setprop(l_norm,1);
			setprop(l_emer,0);
		} else {
 			setprop(l_norm,0);
			setprop(l_emer,1);
		}
	} else {
			setprop(l_norm,0);
			setprop(l_emer,0);
	}			
},0,0);

setlistener("controls/electric/battery-switch[1]",func(n) {
  if (n.getValue()) {
		if (getprop(ext_pwr) or getprop(apu_gen) or getprop(l_gen) >24 or getprop(r_gen) >24) {
			setprop(r_norm,1);
			setprop(r_emer,0);
		} else {
 			setprop(r_norm,0);
			setprop(r_emer,1);
		}
	} else {
			setprop(r_norm,0);
			setprop(r_emer,0);
	}			
},0,0);

setlistener("controls/electric/avionics-switch",func(n) {
  if (n.getValue() == 2 and getprop(r_norm)) {
		if(!getprop(AvPwr)) {
      setprop(AvPwr,1);
      setprop("instrumentation/cdu/init",0);
    }
	} else {
		if(getprop(AvPwr)) {
      setprop(AvPwr,0);
      setprop("instrumentation/cdu/init",1);
    }
	}
},1,1);

setlistener("controls/lighting/anti-coll",func(n) {
	if (n.getValue()==1) {
		setprop("controls/lighting/beacon",1);
		setprop("controls/lighting/strobe",0);
	} else if (n.getValue()==2) {
		setprop("controls/lighting/beacon",0);
		setprop("controls/lighting/strobe",1);
	} else {
		setprop("controls/lighting/beacon",0);
		setprop("controls/lighting/strobe",0);
	}
},0,0);

 ######## Main ##########
var elec_stl = setlistener("/sim/signals/fdm-initialized", func {
    init_switches();
    settimer(update_electrical,5);
    print("Electrical System ... Ok");
    removelistener(elec_stl);
},0,0);

update_electrical = func {
    scnd = getprop("sim/time/delta-sec");
    update_virtual_bus(scnd);
settimer(update_electrical, 0);
}
