#Radio Management Unit 
# ie: var RMU1 = RMU.new(unit,com unit.nav unit);
var RMU = {
    new : func(unit,com,nav){
        m = { parents : [RMU]};
        m.comnum=com;
        m.navnum=nav;
        m.com_sel=[];
        m.com_sby=[];
        m.nav_sel=[];
        m.nav_sby=[];
        m.RMU=props.globals.initNode("instrumentation/rmu/unit["~unit~"]");
        m.com_num=m.RMU.initNode("com-num",com,"INT");
        m.nav_num=m.RMU.initNode("nav-num",nav,"INT");
        m.adf_num=m.RMU.initNode("adf-num",0,"INT");
        m.selected=m.RMU.initNode("selected",com,"INT");
        m.selected_x=m.RMU.initNode("selected-xoffset",0,"DOUBLE");
        m.selected_y=m.RMU.initNode("selected-yoffset",0,"DOUBLE");
        m.com_freq=m.RMU.initNode("com-freq",999.99,"DOUBLE");
        m.com_stby=m.RMU.initNode("com-stby",999.99,"DOUBLE");
        m.nav_freq=m.RMU.initNode("nav-freq",999.99,"DOUBLE");
        m.nav_stby=m.RMU.initNode("nav-stby",999.99,"DOUBLE");
        m.adf_freq=m.RMU.initNode("adf-freq",379.0,"DOUBLE");
        m.atc_freq=m.RMU.initNode("atc-freq",1200,"DOUBLE");

        append(m.com_sel,props.globals.getNode("instrumentation/comm[0]/frequencies/selected-mhz"));
        append(m.com_sel,props.globals.getNode("instrumentation/comm[1]/frequencies/selected-mhz"));
        append(m.com_sby,props.globals.getNode("instrumentation/comm[0]/frequencies/standby-mhz"));
        append(m.com_sby,props.globals.getNode("instrumentation/comm[1]/frequencies/standby-mhz"));
        append(m.nav_sel,props.globals.getNode("instrumentation/nav[0]/frequencies/selected-mhz"));
        append(m.nav_sel,props.globals.getNode("instrumentation/nav[1]/frequencies/selected-mhz"));
        append(m.nav_sby,props.globals.getNode("instrumentation/nav[0]/frequencies/standby-mhz"));
        append(m.nav_sby,props.globals.getNode("instrumentation/nav[1]/frequencies/standby-mhz"));

    return m;
    },
#### init ####

    init_rmu :func(){
        me.com_freq.setValue(me.com_sel[me.comnum].getValue());
        me.com_stby.setValue(me.com_sby[me.comnum].getValue());
        me.nav_freq.setValue(me.nav_sel[me.navnum].getValue());
        me.nav_stby.setValue(me.nav_sby[me.navnum].getValue());
},
#### selector ####
    button : func(act){
        if(act=="com-swp"){
            var frq = me.com_freq.getValue();
            me.com_freq.setValue(me.com_stby.getValue());
            me.com_stby.setValue(frq);
        }elsif(act=="nav-swp"){
            var nfrq = me.nav_freq.getValue();
            me.nav_freq.setValue(me.nav_stby.getValue());
            me.nav_stby.setValue(nfrq);
        }elsif(act=="slct-com"){
            me.selected.setValue("com");
            me.selected_x.setValue(0);
            me.selected_y.setValue(0);
        }elsif(act=="slct-nav"){
            me.selected.setValue("nav");
            me.selected_x.setValue(1);
            me.selected_y.setValue(0);
        }elsif(act=="slct-atc"){
            me.selected.setValue("atc");
            me.selected_x.setValue(0);
            me.selected_y.setValue(1);
        }elsif(act=="slct-adf"){
            me.selected.setValue("adf");
            me.selected_x.setValue(1);
            me.selected_y.setValue(1);
        }
    },
#### copy frequencies to radios ####
    update : func(){
        me.com_sel[me.comnum].setValue(me.com_freq.getValue());
        me.com_sby[me.comnum].setValue(me.com_stby.getValue());
        me.nav_sel[me.navnum].setValue(me.nav_freq.getValue());
        me.nav_sby[me.navnum].setValue(me.nav_stby.getValue());
        setprop("instrumentation/adf/frequencies/selected-khz",me.adf_freq.getValue());
        setprop("instrumentation/kt-70/outputs/id-code",me.atc_freq.getValue());
    },
#### tune frequencies ####
    tune : func(amt,btn){
        var slc = me.selected.getValue();
        var val = 0;
        var frq =0;
        if(slc=="com"){
            frq=me.com_stby.getValue();
            if(btn ==0){
                val=0.025 * amt;
            }else{
                val=1.000 * amt;
            }
            frq +=val;
            if(frq>136.000)frq-=18.000;
            if(frq<118.000)frq+=18.000;
            me.com_stby.setValue(frq);
        }elsif(slc=="nav"){
            frq=me.nav_stby.getValue();
            if(btn ==0){
                val=0.050 * amt;
            }else{
                val=1.000 * amt;
            }
            frq +=val;
            if(frq>118.000)frq-=10.000;
            if(frq<108.000)frq+=10.000;
            me.nav_stby.setValue(frq);
            }elsif(slc=="atc"){
            frq=me.atc_freq.getValue();
            if(btn ==0){
                val=1 * amt;
            }else{
                val=100 * amt;
            }
            frq +=val;
            if(frq>5555.0)frq-=5555.0;
            if(frq<0.0)frq+=5555.0;
            me.atc_freq.setValue(frq);
        }elsif(slc=="adf"){
            frq=me.adf_freq.getValue();
            if(btn ==0){
                val=1.0 * amt;
            }else{
                val=100.0 * amt;
            }
            frq +=val;
            if(frq>1800.0)frq-=1610.0;
            if(frq<190.0)frq+=1610.0;
            me.adf_freq.setValue(frq);
        }
    me.update();
    },

};

##############################
##############################

var RMU1 = RMU.new(0,0,0);
var RMU2 = RMU.new(1,1,1);

setlistener("/sim/signals/fdm-initialized", func {
RMU1.init_rmu();
RMU2.init_rmu();
});

setlistener("/sim/signals/reinit", func {
RMU1.init_rmu();
RMU2.init_rmu();
});
