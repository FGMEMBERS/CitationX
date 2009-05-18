### tire rotation per minute by circumference ####
#var tire=TireSpeed.new(# of gear,diam[0],diam[1],diam[2], ...);

var TireSpeed = {
    new : func(number){
        m = { parents : [TireSpeed] };
            m.num=number;
            m.circumference=[];
            m.tire=[];
            m.rpm=[];
            for(var i=0; i<m.num; i+=1) {
                var diam =arg[i];
                var circ=diam * math.pi;
                append(m.circumference,circ);
                append(m.tire,props.globals.initNode("gear/gear["~i~"]/tire-rpm",0,"DOUBLE"));
                append(m.rpm,0);
            }
        m.count = 0;
        return m;
    },
    #### calculate and write rpm ###########
    get_rotation: func (fdm1){
        var speed=0;
        if(fdm1=="yasim"){
            speed =getprop("gear/gear["~me.count~"]/rollspeed-ms") or 0;
            speed=speed*60;
            }elsif(fdm1=="jsb"){
                speed =getprop("fdm/jsbsim/gear/unit["~me.count~"]/wheel-speed-fps") or 0;
                speed=speed*18.288;
            }
        var wow = getprop("gear/gear["~me.count~"]/wow");
        if(wow){
            me.rpm[me.count] = speed / me.circumference[me.count];
        }else{
            if(me.rpm[me.count] > 0) me.rpm[me.count]=me.rpm[me.count]*0.95;
        }
        me.tire[me.count].setValue(me.rpm[me.count]);
        me.count+=1;
        if(me.count>=me.num)me.count=0;
    },
};


#Jet Engine Helper class 
# ie: var Eng = JetEngine.new(engine number);

var JetEngine = {
    new : func(eng_num){
        m = { parents : [JetEngine]};
        m.ITTlimit=8.9;
        m.fdensity = getprop("consumables/fuel/tank/density-ppg") or 6.72;
        m.eng = props.globals.getNode("engines/engine["~eng_num~"]",1);
        m.running = m.eng.initNode("running",0,"BOOL");
        m.itt=m.eng.getNode("itt-norm");
        m.itt_c=m.eng.initNode("itt-celcius",0,"DOUBLE");
        m.n1 = m.eng.getNode("n1",1);
        m.n2 = m.eng.getNode("n2",1);
        m.fan = m.eng.initNode("fan",0,"DOUBLE");
        m.cycle_up = 0;
        m.engine_off=1;
        m.turbine = m.eng.initNode("turbine",0,"DOUBLE");
        m.throttle_lever = props.globals.initNode("controls/engines/engine["~eng_num~"]/throttle-lever",0,"DOUBLE");
        m.throttle = props.globals.initNode("controls/engines/engine["~eng_num~"]/throttle",0,"DOUBLE");
        m.ignition = props.globals.initNode("controls/engines/engine["~eng_num~"]/ignition",0,"DOUBLE");
        m.cutoff = props.globals.initNode("controls/engines/engine["~eng_num~"]/cutoff",1,"BOOL");
        m.fuel_out = props.globals.initNode("engines/engine["~eng_num~"]/out-of-fuel",0,"BOOL");
        m.starter = props.globals.initNode("controls/engines/engine["~eng_num~"]/starter",0,"BOOL");
        m.fuel_pph=m.eng.initNode("fuel-flow_pph",0,"DOUBLE");
        m.fuel_gph=m.eng.initNode("fuel-flow-gph");
        m.hpump=props.globals.initNode("systems/hydraulics/pump-psi["~eng_num~"]",0,"DOUBLE");

        m.Lfuel = setlistener(m.fuel_out, func m.shutdown(m.fuel_out.getValue()),0,0);
        m.CutOff = setlistener(m.cutoff, func (ct){m.engine_off=ct.getValue()},1,0);
        return m;
    },
#### update ####
    update : func{
        var thr = me.throttle.getValue();
        if(!me.engine_off){
            me.fan.setValue(me.n1.getValue());
            me.turbine.setValue(me.n2.getValue());
            if(getprop("controls/engines/grnd_idle"))thr *=0.92;
            me.throttle_lever.setValue(thr);
        }else{
            me.throttle_lever.setValue(0);
            if(me.starter.getBoolValue()){
                if(me.cycle_up == 0)me.cycle_up=1;
            }
            if(me.cycle_up>0){
                me.spool_up(15);
            }else{
                var tmprpm = me.fan.getValue();
                if(tmprpm > 0.0){
                    tmprpm -= getprop("sim/time/delta-sec") * 2;
                    me.fan.setValue(tmprpm);
                    me.turbine.setValue(tmprpm);
                }
            }
        }
        if(thr<0.01){
            if(getprop("gear/gear[0]/wow")){
                if(getprop("controls/gear/brake-parking") == 1)me.cutoff.setValue(1);
            }
        }
        me.fuel_pph.setValue(me.fuel_gph.getValue()*me.fdensity);
        var hpsi =me.fan.getValue();
        if(hpsi>60)hpsi = 60;
        me.hpump.setValue(hpsi);
        me.itt_c.setValue(me.fan.getValue() * me.ITTlimit);
    },

    spool_up : func(scnds){
        if(me.engine_off){
        var n1=me.n1.getValue() ;
        var n1factor = n1/scnds;
        var n2=me.n2.getValue() ;
        var n2factor = n2/scnds;
        var tmprpm = me.fan.getValue();
            tmprpm += getprop("sim/time/delta-sec") * n1factor;
            var tmprpm2 = me.turbine.getValue();
            tmprpm2 += getprop("sim/time/delta-sec") * n2factor;
            me.fan.setValue(tmprpm);
            me.turbine.setValue(tmprpm2);
            if(tmprpm >= me.n1.getValue()){
                var ign=1-me.ignition.getValue();
                me.cutoff.setBoolValue(ign);
                me.cycle_up=0;
            }
        }
    },

    shutdown : func(b){
        if(b!=0){
            me.cutoff.setBoolValue(1);
        }
    }

};

var FDM="";
var SndIn = props.globals.initNode("/sim/sound/cabin-volume",0.5);
var Grd_Idle=props.globals.initNode("controls/engines/grnd-idle",1,"BOOL");
var Annun = props.globals.getNode("instrumentation/annunciators",1);
var MstrWarn =Annun.getNode("master-warning",1);
var MstrCaution = Annun.getNode("master-caution",1);
var PWR2 =0;
aircraft.livery.init("Aircraft/CitationX/Models/Liveries");

aircraft.light.new("instrumentation/annunciators", [0.5, 0.5], MstrCaution);
var cabin_door = aircraft.door.new("/controls/cabin-door", 2);
var FHmeter = aircraft.timer.new("/instrumentation/clock/flight-meter-sec", 10,1);
var LHeng= JetEngine.new(0);
var RHeng= JetEngine.new(1);
var tire=TireSpeed.new(3,0.430,0.615,0.615);

#######################################

setlistener("/sim/signals/fdm-initialized", func {
    fdm_init();
    settimer(update_systems,2);
});

setlistener("/sim/signals/reinit", func {
    fdm_init();
},0,0);

setlistener("/sim/crashed", func(cr){
    if(cr.getBoolValue()){
    }
},1,0);

var fdm_init = func(){
    SndIn.setValue(0.5);
    MstrWarn.setBoolValue(0);
    MstrCaution.setBoolValue(0);
    FDM=getprop("/sim/flight-model");
    setprop("/sim/model/start-idling",0);
    setprop("controls/engines/N1-limit",90.0);
}

setlistener("/gear/gear[1]/wow", func(ww){
    if(ww.getBoolValue()){
        FHmeter.stop();
        Grd_Idle.setBoolValue(1);
    }else{
        FHmeter.start();
        Grd_Idle.setBoolValue(0);
    }
},0,0);

controls.gearDown = func(v) {
    if (v < 0) {
        if(!getprop("gear/gear[1]/wow"))setprop("/controls/gear/gear-down", 0);
    } elsif (v > 0) {
      setprop("/controls/gear/gear-down", 1);
    }
}

setlistener("/sim/current-view/internal", func(vw){
    if(vw.getValue()){
    SndIn.setDoubleValue(0.5);
    }else{
    SndIn.setDoubleValue(1.0);
    }
},1,0);

setlistener("/controls/gear/antiskid", func(as){
    var test=as.getBoolValue();
    if(!test){
    MstrCaution.setBoolValue(1 * PWR2);
    Annun.getNode("antiskid").setBoolValue(1 * PWR2);
    }else{
    Annun.getNode("antiskid").setBoolValue(0);
    }
},0,0);

setlistener("/sim/freeze/fuel", func(ffr){
    var test=ffr.getBoolValue();
    if(test){
    MstrCaution.setBoolValue(1 * PWR2);
    Annun.getNode("fuel-gauge").setBoolValue(1 * PWR2);
    }else{
    Annun.getNode("fuel-gauge").setBoolValue(0);
    }
},0,0);


var FHupdate = func(tenths){
        var fmeter = getprop("/instrumentation/clock/flight-meter-sec");
        var fhour = fmeter/3600;
        setprop("instrumentation/clock/flight-meter-hour",fhour);
        var fmin = fhour - int(fhour);
        if(tenths !=0){
            fmin *=100;
        }else{
            fmin *=60;
        }
        setprop("instrumentation/clock/flight-meter-min",int(fmin));
    }

var stall_horn = func{
    var alert=0;
    var kias=getprop("velocities/airspeed-kt");
    if(kias>150){setprop("sim/sound/stall-horn",alert);return;};
    var wow1=getprop("gear/gear[1]/wow");
    var wow2=getprop("gear/gear[2]/wow");
    if(!wow1 or !wow2){
        var grdn=getprop("controls/gear/gear-down");
        var flap=getprop("controls/flight/flaps");
        if(kias<100){
            alert=1;
        }elsif(kias<120){
            if(!grdn )alert=1;
        }else{
            if(flap==0)alert=1;
        }
    }
    setprop("sim/sound/stall-horn",alert);
}

########## MAIN ##############

var update_systems = func{
    LHeng.update();
    RHeng.update();
    FHupdate(0);
    tire.get_rotation("yasim");
    stall_horn();

#annunciators_loop();
setprop("sim/multiplay/generic/float[2]",getprop("position/gear-agl-m"));
settimer(update_systems,0);
}
