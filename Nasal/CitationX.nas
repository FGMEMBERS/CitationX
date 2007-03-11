rainspeed = nil;
rainalpha=0.0;
hpsi = 0.0;
pph1=0.0;
pph2=0.0;
fuel_density=0.0;
n_offset=0;
nm_calc=0.0;


strobe_switch = props.globals.getNode("controls/switches/strobe", 1);
aircraft.light.new("sim/model/CitationX/lighting/strobe",[0.05, 1.50], strobe_switch);
beacon_switch = props.globals.getNode("controls/switches/beacon", 1);
aircraft.light.new("sim/model/CitationX/lighting/beacon",[1.0, 1.0], beacon_switch);


init_controls = func {
setprop("environment/rainspeed",0.0);
setprop("environment/rainalpha",0.0);
setprop("/instrumentation/gps/wp/wp/waypoint-type","airport");
setprop("/instrumentation/gps/wp/wp/ID",getprop("/sim/tower/airport-id"));
setprop("/instrumentation/gps/serviceable","true");
setprop("/engines/engine[0]/fuel-flow-pph",0.0);
setprop("/engines/engine[1]/fuel-flow-pph",0.0);
setprop("/controls/engines/reverser-position",0.0);
setprop("/environment/turbulence/use-cloud-turbulence","true");
setprop("/sim/current-view/field-of-view",60.0);
setprop("/controls/gear/brake-parking",1.0);
setprop("/instrumentation/annunciator/master-caution",0.0);
setprop("/systems/hydraulic/pump-psi[0]",0.0);
setprop("/systems/hydraulic/pump-psi[1]",0.0);
fuel_density=getprop("consumables/fuel/tank[0]/density-ppg");
setprop("/instrumentation/primus1000/nav1pointer",0.0);
setprop("/instrumentation/primus1000/nav2pointer",0.0);
setprop("/instrumentation/primus1000/nav1pointer-heading-offset",0.0);
setprop("/instrumentation/primus1000/nav2pointer-heading-offset",0.0);
setprop("/instrumentation/primus1000/alt-mode",0.0);
setprop("/instrumentation/primus1000/nav-dist-nm",0.0);
print("Aircraft systems initialized");
}
settimer(init_controls, 0);


togglereverser = func {
r1 = "/controls/engines/engine"; 
r2 = "/controls/engines/engine[1]"; 
rv1 = "/engines/engine/reverser-position"; 
rv2 = "/engines/engine[1]/reverser-position"; 

val = getprop(rv1);
if (val == 0 or val == nil) {
interpolate(rv1, 1.0, 1.4);  
interpolate(rv2, 1.0, 1.4);  
setprop(r1,"reverser","true");
setprop(r2,"reverser", "true");
} else {
if (val == 1.0){
interpolate(rv1, 0.0, 1.4);  
interpolate(rv2, 0.0, 1.4);  
setprop(r1,"reverser",0);
setprop(r2,"reverser",0);
  }
 }
}




gforce = func {
    force = getprop("/accelerations/pilot-g");
if(force == nil) {force = 1.0;}
eyepoint = (0.36 - (force * 0.01));

if(getprop("/sim/current-view/view-number") < 1){
setprop("/sim/current-view/y-offset-m",eyepoint);
}

test1 = getprop("velocities/airspeed-kt");
if(test1 == nil){test1=0.0;}
rainspeed = getprop("environment/rainspeed");
if(rainspeed == nil){rainspeed = 0.0;}
rainspeed += (test1*0.0001);
if(rainspeed > 1.000){rainspeed=rainspeed - 1.00;}
setprop("environment/rainspeed",rainspeed);

if(getprop("environment/metar/rain-norm") > 0.0){
rainalpha = getprop("environment/rainalpha");
rainalpha+=0.001;
if(rainalpha > 1.0){rainalpha = 1.0;}
setprop("environment/rainalpha",rainalpha);
}
hpsi = getprop("/engines/engine[0]/n2");
if(hpsi == nil){hpsi =0.0;}
if(hpsi > 30.0){setprop("/systems/hydraulic/pump-psi[0]",3000.0);}
else{setprop("/systems/hydraulic/pump-psi[0]",hpsi * 100);}

hpsi = getprop("/engines/engine[1]/n2");
if(hpsi == nil){hpsi =0.0;}
if(hpsi > 30.0){setprop("/systems/hydraulic/pump-psi[1]",3000.0);}
else{setprop("/systems/hydraulic/pump-psi[1]",hpsi * 100);}
pph1=getprop("/engines/engine[0]/fuel-flow-gph");
if(pph1 == nil){pph1 = 0.0};
pph2=getprop("/engines/engine[1]/fuel-flow-gph");
if(pph2 == nil){pph2 = 0.0};
setprop("engines/engine[0]/fuel-flow-pph",pph1* fuel_density);
setprop("engines/engine[1]/fuel-flow-pph",pph2* fuel_density);

settimer(gforce, 0);
}
settimer(gforce, 0);

