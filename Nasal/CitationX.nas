engine_on = props.globals.getNode("/sim/sound/engine/on",1);
E_volume = props.globals.getNode("/sim/sound/engine/volume",1);
E_pitch = props.globals.getNode("/sim/sound/engine/pitch",1);
Reverser = props.globals.getNode("/surface-positions/reverser-norm",1);

strobe_switch = props.globals.getNode("controls/switches/strobe", 1);
aircraft.light.new("sim/model/CitationX/lighting/strobe",[0.05, 1.50], strobe_switch);
beacon_switch = props.globals.getNode("controls/switches/beacon", 1);
aircraft.light.new("sim/model/CitationX/lighting/beacon",[1.0, 1.0], beacon_switch);

setlistener("/sim/signals/fdm-initialized", func {
	setup_start(); 
    });

setlistener("/controls/engines/engine/reverser", func {
    rvrs = cmdarg().getValue();
    interpolate(Reverser,rvrs, 1.4);
});	 

setup_start = func{
	engine_on.setBoolValue(1);
	E_volume.setValue(0.3);
	E_pitch.setValue(1);
	Reverser.setValue(0.0);
	setprop("/controls/engines/reverser-position",0.0);
	setprop("/environment/turbulence/use-cloud-turbulence","true");
	setprop("/instrumentation/annunciator/master-caution",0.0);
	print("Aircraft systems initialized");
}

update_sounds = func{
	var view0 = props.globals.getNode("/sim/current-view/view-number",0).getValue();
	var sound_level = 0.7;
	n1_rpm =props.globals.getNode("/engines/engine/n1",0); 
	var test_rpm = n1_rpm.getValue();

	if(test_rpm == nil){test_rpm = 0.0;}
	if(test_rpm < 5 or test_rpm == nil){
		engine_on.setBoolValue(0);
		E_volume.setValue(0);
		E_pitch.setValue(0.0);
	}else{
		engine_on.setBoolValue(1);
		if(view0 == 0){sound_level = 0.25;}
		E_volume.setValue(sound_level);
		E_pitch.setValue((0.5)+(0.01 * test_rpm));
		}
}

gforce = func {
	force = getprop("/accelerations/pilot-g");
	if(force == nil) {force = 1.0;}
	eyepoint = getprop("sim/view/config/y-offset-m") +0.01;
	eyepoint -= (force * 0.01);
	if(getprop("/sim/current-view/view-number") < 1){
		setprop("/sim/current-view/y-offset-m",eyepoint);
		}
	update_sounds();
	settimer(gforce, 0);
}
settimer(gforce, 0);

