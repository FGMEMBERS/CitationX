### Canvas RMU1 ###
### C. Le Moigne (clm76) - 2016-2017 ###

var adf_freq = props.globals.getNode("instrumentation/adf/frequencies/selected-khz",1);
var adf_mode = props.globals.getNode("instrumentation/adf/mode",1);
var com_freq = props.globals.getNode("instrumentation/comm/frequencies/selected-mhz",1);
var com_mem = props.globals.getNode("instrumentation/rmu/unit/mem-com",1);
var com_stby = props.globals.getNode("instrumentation/comm/frequencies/standby-mhz",1);
var delete = props.globals.getNode("instrumentation/rmu/unit/delete",1);
var insert = props.globals.getNode("instrumentation/rmu/unit/insert",1);
var mem_dsp = props.globals.getNode("instrumentation/rmu/unit/mem-dsp",1);
var mem_freq = props.globals.getNode("instrumentation/rmu/unit/mem-freq",1);
var nav_freq = props.globals.getNode("instrumentation/nav/frequencies/selected-mhz",1);
var nav_mem = props.globals.getNode("instrumentation/rmu/unit/mem-nav",1);
var nav_stby = props.globals.getNode("instrumentation/nav/frequencies/standby-mhz",1);
var page = props.globals.getNode("instrumentation/rmu/unit/pge",1);
var selected = props.globals.getNode("instrumentation/rmu/unit/selected",1);
var store = props.globals.getNode("instrumentation/rmu/unit/sto",1);
var swap1 = props.globals.getNode("instrumentation/rmu/unit/swp1",1);
var swap2 = props.globals.getNode("instrumentation/rmu/unit/swp2",1);
var test = props.globals.getNode("instrumentation/rmu/unit/test",1);
var trsp_code = props.globals.getNode("instrumentation/transponder/unit/id-code",1);
var trsp_k_mode = props.globals.getNode("instrumentation/transponder/unit/knob-mode",1);
var trsp_mode = props.globals.getNode("instrumentation/transponder/unit/display-mode",1);
var trsp_num = props.globals.getNode("instrumentation/rmu/trsp-num",1);

var path = getprop("/sim/fg-home")~"/aircraft-data/";
var data = nil;
var full = nil;
var mem1 = nil;
var mem_1 = nil;
var memV1 = nil;

	### Create Memories if not exist ###
var memPath = path~"CitationX-RMUmem1.xml";
var xfile = subvec(directory(path),2);
var v = std.Vector.new(xfile);
if (!v.contains("CitationX-RMUmem1.xml")) {
	var data = props.Node.new({
		comMem1 : 0,comMem2 : 0,comMem3 : 0,comMem4 : 0,comMem5 : 0,
		comMem6 : 0,comMem7 : 0,comMem8 : 0,comMem9 : 0,comMem10 : 0,
		comMem11 : 0,comMem12 : 0,
		navMem1 : 0,navMem2 : 0,navMem3 : 0,navMem4 : 0,navMem5 : 0,
		navMem6 : 0,navMem7 : 0,navMem8 : 0,navMem9 : 0,navMem10 : 0,
		navMem11 : 0,navMem12 : 0
	});		
	io.write_properties(memPath,data);
} 

var memVec1 = std.Vector.new();
for (var i=0;i<12;i+=1) {
	memVec1.append(0);
}

	### Load comm memories ###
var com1 = {};
var com_mem1 = ["comMem1","comMem2","comMem3","comMem4",
							"comMem5","comMem6","comMem7","comMem8",
							"comMem9","comMem10","comMem11","comMem12"];
data = io.read_properties(memPath);
foreach(var i;com_mem1) {
	com1[i] = data.getValue(i);
}


	### Load nav memories ###
var nav1 = {};
var navVec1 = std.Vector.new();
var nav_mem1 = ["navMem1","navMem2","navMem3","navMem4",
							"navMem5","navMem6","navMem7","navMem8",
							"navMem9","navMem10","navMem11","navMem12"];
data = io.read_properties(memPath);
foreach(var i;nav_mem1) {
	nav1[i] = data.getValue(i);
}

	### Init Frequencies ###
com_freq.setValue(127.000);
com_stby.setValue(135.200);

	### Font Mapper ###
var font_mapper = func(family,weight) {
	if(family == "'Liberation Mono'" and (weight == "normal" or weight == "bold")) {
		return "osifont.ttf";
	}
};

	### RMU ###
var RMU1 = {
	new: func() {
		var m = {parents:[RMU1]};
		m.canvas = canvas.new({
			"name": "RMU1", 
			"size": [1024, 1024],
			"view": [800, 1024],
			"mipmapping": 1 
		});

		m.canvas.addPlacement({"node": "RMU.screenL"});

	### RMU frame init ###
		m.rmu1 = m.canvas.createGroup();
		canvas.parsesvg(m.rmu1, "Aircraft/CitationX/Models/Instruments/RMU/RMU.svg");
		m.cdr =	m.rmu1.createChild("path")
					.moveTo(98,237)
					.horiz(286)
					.vert(88)
					.horiz(-286)
					.close()
					.setColor(0.95,0.75,0)
					.setStrokeLineWidth(10);			

		m.rmu1.setVisible(1);

	### Memories frame & text init ###
		m.mem1 = m.canvas.createGroup();
		canvas.parsesvg(m.mem1, "Aircraft/CitationX/Models/Instruments/RMU/mem.svg",{'font-mapper':font_mapper});
		m.fra =	m.mem1.createChild("path")
					.moveTo(95,130)
					.horiz(420)
					.vert(90)
					.horiz(-420)
					.close()
					.setColor(0.95,0.75,0)
					.setStrokeLineWidth(10)			
					.setVisible(0);

		m.mem1.setVisible(0);

	### Test init ###
		m.test1 = m.canvas.createGroup();
		canvas.parsesvg(m.test1, "Aircraft/CitationX/Models/Instruments/RMU/test.svg");
		m.test1.setVisible(0);

	### RMU initial display	###
		m.text = {};
		m.text_val = ["comFreq","navFreq","comStby", "navStby",
										"trspCode","trspMode","trspNum","adfFreq","adfMode",
										"memCom","memNav","comNum","navNum","adfNum","mlsNum",
										"full"];
		foreach(var i;m.text_val) {
			m.text[i] = m.rmu1.getElementById(i);
		}

		m.text.comFreq.setText(sprintf("%.3f",com_freq.getValue()));
		m.text.comNum.setText("1");
		m.text.navFreq.setText(sprintf("%.3f",nav_freq.getValue()));
		m.text.navNum.setText("1");
		m.text.adfNum.setText("1");
		m.text.adfFreq.setText(sprintf("%d",adf_freq.getValue()));
		m.text.mlsNum.setText("1");
		m.text.trspNum.setText("1");
		m.text.comStby.setText(sprintf("%07.3f",com1.comMem1));
		com_stby.setValue(com1.comMem1);
		m.text.memCom.setText("MEMORY-1");
		m.text.navStby.setText(sprintf("%07.3f",nav1.navMem1));
		nav_stby.setValue(nav1.navMem1);
		m.text.memNav.setText("MEMORY-1");
		m.text.trspCode.setText(sprintf("%04d",trsp_code.getValue()));
		m.text.trspMode.setText(trsp_mode.getValue());
		m.text.full.hide();

	### Memories treatment	###
		m.freq = {};
		m.freq_val = ["freq1","freq2","freq3","freq4","freq5","freq6"];
		m.vfreq = std.Vector.new();
		foreach(var i;m.freq_val) {
			m.freq[i] = m.mem1.getElementById(i);
			m.vfreq.append(m.mem1.getElementById(i));
		}
		
		### Line number ###
		m.num_val = ["num1","num2","num3","num4","num5","num6"];
		m.vnum = std.Vector.new();
		foreach(var i;m.num_val) {
			m.vnum.append(m.mem1.getElementById(i));
		}

		### Memories Texts ###
		m.tit = m.mem1.getElementById("tittle");
		m.ins = m.mem1.getElementById("ins");
		m.cant = m.mem1.getElementById("cant");
		m.cant.hide();

		### RMU Tests ###
		m.tst = {};
		m.tst_val = ["comTest","comOk","navTest","navOk","adfTest", 								"adfOk","atcTest","atcOk","success"];
		foreach(var i;m.tst_val) {
			m.tst[i] = m.test1.getElementById(i);
		}

		return m;
	},

	### Memories runtime display ###
	update : func{
		me.timer = maketimer(0.1,func() {
			if (selected.getValue()!=1) {me.tit.setText("Com 1")}
			if (selected.getValue()==1) {me.tit.setText("Nav 1")}
			me.more = getprop("instrumentation/rmu/unit/more");
			if (memVec1.vector[6]==0) {
				me.more = 0;
				setprop("instrumentation/rmu/unit/more",0);
			}
			me.mem_redraw();
			if (memVec1.vector[0]!=0){me.mem_select()}
		});
		me.timer.start();
	},

	mem_redraw : func {
		for (var i=0;i<6;i+=1) { ### raz ###
			me.vfreq.vector[i].setText("");
			me.vnum.vector[i].setText("");
		}
		for (var i=0;i<6;i+=1) {
			if (memVec1.vector[i+me.more]== 0) {
				break;
			}
			else {
				me.vfreq.vector[i].setText(sprintf("%.3f",memVec1.vector[i+me.more]));
				me.vnum.vector[i].setText(sprintf("%d",i+1+me.more));
			}
		}
	},

	mem_select : func {
		for (var i=0;i<12;i+=1) {
			if (memVec1.vector[i]== 0) {me.max_sel=i-1;break}
			else {me.max_sel = 11}
		}		
		me.select = mem_dsp.getValue();
		var n=nil;
		if (me.more == 0) {n = 0}
		else {n = 6}
		for (var i=0;i<6;i+=1) {
			if (me.select > me.max_sel-n) {
				mem_dsp.setValue(me.max_sel-n);
			}
			if (me.select == -1) {me.fra.hide()}
			if (me.select == 0) {me.fra.setTranslation(0,0);me.fra.show()}
			if (me.select == 1) {me.fra.setTranslation(0,120);me.fra.show()}
			if (me.select == 2) {me.fra.setTranslation(0,280);me.fra.show()}
			if (me.select == 3) {me.fra.setTranslation(0,400);me.fra.show()}
			if (me.select == 4) {me.fra.setTranslation(0,560);me.fra.show()}
			if (me.select == 5) {me.fra.setTranslation(0,680);me.fra.show()}
		}	
	},

	### Listeners ###
	listen : func {
		setlistener(page,func (n) {
			mem_dsp.setValue(-1);
			if (n.getValue()) {
				me.rmu1.setVisible(0);
				me.mem1.setVisible(1);
				if (selected.getValue()==0){
					foreach(var i;com_mem1) {
						memVec1.append(data.getValue(i));
					}
				}
				if (selected.getValue()==1){
					foreach(var i;nav_mem1) {
						memVec1.append(data.getValue(i));
					}
				}
				me.update();
				refreshMem();
				if (memVec1.vector[0] == 0) {me.fra.hide()}
			} else {
				me.timer.stop();
				setprop("instrumentation/rmu/unit/more",0);
				insert.setValue(0);
				me.rmu1.setVisible(1);
				me.mem1.setVisible(0);
#				if (selected.getValue()!=1){
#					com_stby.setValue(memVec1.vector[0]);
#				}
#				if (selected.getValue()==1){
#					nav_stby.setValue(memVec1.vector[0]);
#				}
			}
		});

		setlistener(selected,func(n) {
			if (n.getValue() == 0) {me.cdr.setTranslation(0,0)}
			if (n.getValue() == 1) {me.cdr.setTranslation(325,0)}
			if (n.getValue() == 2) {me.cdr.setTranslation(0,230)}
			if (n.getValue() == 3) {me.cdr.setTranslation(325,230)}
			if (n.getValue() == 4) {me.cdr.setTranslation(0,335)}
			if (n.getValue() == 5) {me.cdr.setTranslation(325,335)}
		},0,0);	

		setlistener(swap1, func(n) {
			if (n.getValue()) {
				me.text.comFreq.setText(sprintf("%.3f",com_freq.getValue()));
			}
		},0,0);

		setlistener(swap2, func(n) {
			if (n.getValue()) {
				me.text.navFreq.setText(sprintf("%.3f",nav_freq.getValue()));
			}
		},0,0);

		### Comm frequencies ###
		setlistener(com_freq, func(n) {
			me.text.comFreq.setText(sprintf("%.3f",n.getValue()));
		},0,0);

		setlistener(com_stby, func(n) {
			me.text.comStby.setText(sprintf("%.3f",n.getValue()));
			for (var i=0;i<12;i+=1) {
				if (sprintf("%.3f",com1[com_mem1[i]]) == sprintf("%.3f",n.getValue())) {
					me.text.memCom.setText("MEMORY-"~sprintf("%d",i+1));							
					break;
				}	else {
					me.text.memCom.setText("TEMP-"~sprintf("%d",i+1));
					if (com1[com_mem1[i]] == 0) {
						break;
					}					
				}
			}
		},0,0);

		setlistener(com_mem, func(n) {
			var i = n.getValue();
			if (com1[com_mem1[0]] == 0) {
					me.text.comStby.setText(sprintf("%.3f",com_stby.getValue()));
			} else {
				if (com1[com_mem1[i]] != 0) {
					me.text.comStby.setText(sprintf("%07.3f",com1[com_mem1[i]]));
					com_stby.setValue(com1[com_mem1[i]]);
					me.text.memCom.setText("MEMORY-"~sprintf("%d",i+1));
				}	else {
					com_mem.setValue(0);
					me.text.comStby.setText(sprintf("%07.3f",com1[com_mem1[0]]));
					me.text.memCom.setText("MEMORY-"~sprintf("%d",1));
				}
			}
		},0,0);

		### Nav frequencies ###
		setlistener(nav_freq, func(n) {
			me.text.navFreq.setText(sprintf("%.3f",n.getValue()));
		},0,0);

		setlistener(nav_stby, func(n) {
			me.text.navStby.setText(sprintf("%.3f",n.getValue()));
			for (var i=0;i<12;i+=1) {
				if (sprintf("%.3f",nav1[nav_mem1[i]]) == sprintf("%.3f",n.getValue())) {
					me.text.memNav.setText("MEMORY-"~sprintf("%d",i+1));							
					break;
				}	else {
					me.text.memNav.setText("TEMP-"~sprintf("%d",i+1));
					if (nav1[nav_mem1[i]] == 0) {
						break;
					}					
				}
			}
		},0,0);

		setlistener(nav_mem, func(n) {
			var i = n.getValue();
			if (nav1[nav_mem1[0]] == 0) {
					me.text.navStby.setText(sprintf("%.3f",nav_stby.getValue()));
			} else {
				if (nav1[nav_mem1[i]] != 0) {
					me.text.navStby.setText(sprintf("%07.3f",nav1[nav_mem1[i]]));
					nav_stby.setValue(nav1[nav_mem1[i]]);
					me.text.memNav.setText("MEMORY-"~sprintf("%d",i+1));
				}	else {
					nav_mem.setValue(0);
					me.text.navStby.setText(sprintf("%07.3f",nav1[nav_mem1[0]]));
					me.text.memNav.setText("MEMORY-"~sprintf("%d",1));
				}
			}
		},0,0);

	### Storage memories Com & Nav ###
		setlistener(store, func(n) {	
			if (n.getValue()) {
				if (selected.getValue() == 0) {
					if (com1[com_mem1[0]] == 0) {
						com1[com_mem1[0]] = com_stby.getValue();
						var name = data.getChild(com_mem1[0]);
						name.setDoubleValue(sprintf("%07.3f",com1[com_mem1[0]]));
						io.write_properties(memPath,data);
						me.text.memCom.setText("MEMORY-1");
					} else if (com1[com_mem1[0]] != com_stby.getValue()) {
						if (com1[com_mem1[11]] != 0) {
							full = me.text.full;
							me.memFull();
						}
						else {
							for (var i=0;i<12;i+=1) {
								if (com1[com_mem1[i]] == 0) {
									com1[com_mem1[i]] = com_stby.getValue();
									var name = data.getChild(com_mem1[i]);
									name.setDoubleValue(com1[com_mem1[i]]);
									io.write_properties(memPath,data);
									me.text.memCom.setText("MEMORY-"~sprintf("%d",i+1));
									memVec1.vector[i] = com1[com_mem1[i]];
									break;
								}
							}
						}
					}
				}

				if (selected.getValue() == 1) {
					if (nav1[nav_mem1[0]] == 0) {
						nav1[nav_mem1[0]] = nav_stby.getValue();
						var name = data.getChild(nav_mem1[0]);
						name.setDoubleValue(sprintf("%07.3f",nav1[nav_mem1[0]]));
						io.write_properties(memPath,data);
						me.text.memNav.setText("MEMORY-1");
					} else if (nav1[nav_mem1[0]] != nav_stby.getValue()) {
						if (nav1[nav_mem1[11]] != 0) {
							full = me.text.full;
							me.memFull()}
						else {
							for (var i=0;i<12;i+=1) {
								if (nav1[nav_mem1[i]] == 0) {
									nav1[nav_mem1[i]] = nav_stby.getValue();
									var name = data.getChild(nav_mem1[i]);
									name.setDoubleValue(nav1[nav_mem1[i]]);
									io.write_properties(memPath,data);
									me.text.memNav.setText("MEMORY-"~sprintf("%d",i+1));
									memVec1.vector[i] = nav1[nav_mem1[i]];
									break;
								}
							}
						}
					}
				}
			}
		},0,0);

	### Insert memories ###
		setlistener(insert,func(n) {
			if (n.getValue() and mem_dsp.getValue() != -1) {
					me.ins.setColor(1,0.35,1);
					if (memVec1.vector[11] == 0) {
						memVec1.insert(mem_dsp.getValue()+me.more,selected.getValue() == 0 ? 117.975 : 108.000);
					} else {
						full = me.cant;
						me.memFull();
						insert.setValue(0);
						me.ins.setColor(1,1,1);
					}
			} else {
				me.ins.setColor(1,1,1);
					if (selected.getValue() == 0) {
						for (var i=0;i<12;i+=1) {
							com1[com_mem1[i]]=memVec1.vector[i];
							var name = data.getChild(com_mem1[i]);
							name.setDoubleValue(com1[com_mem1[i]]);
							io.write_properties(memPath,data);
						}										
					}
				if (selected.getValue() == 1) {
					for (var i=0;i<12;i+=1) {
						nav1[nav_mem1[i]]=memVec1.vector[i];
						var name = data.getChild(nav_mem1[i]);
						name.setDoubleValue(nav1[nav_mem1[i]]);
						io.write_properties(memPath,data);
					}										
				}
				refreshMem();
			}
		},0,0);

		setlistener(mem_freq, func(n) {	
			if (insert.getValue()==1) {
				memVec1.vector[mem_dsp.getValue()+me.more] = n.getValue();
			}
			
		},0,0);

	### Delete memories ###
		setlistener(delete, func(n) {	
			if (n.getValue()) {
				if (insert.getValue()==0) {
					me.sel = mem_dsp.getValue();
					me.pge = getprop("instrumentation/rmu/unit/more");
					if (me.pge == 6) {me.sel = me.sel+me.pge}
					if (selected.getValue() == 0) {					
						memVec1.remove(com1[com_mem1[me.sel]]);
						memVec1.insert(11,0);
						for (var i=0;i<12;i+=1) {
							com1[com_mem1[i]]=memVec1.vector[i];
							var name = data.getChild(com_mem1[i]);
							name.setDoubleValue(com1[com_mem1[i]]);
							io.write_properties(memPath,data);
						}										
					}
					if (selected.getValue() == 1) {					
						memVec1.remove(nav1[nav_mem1[me.sel]]);
						memVec1.insert(11,0);
						for (var i=0;i<12;i+=1) {
							nav1[nav_mem1[i]]=memVec1.vector[i];
							var name = data.getChild(nav_mem1[i]);
							name.setDoubleValue(nav1[nav_mem1[i]]);
							io.write_properties(memPath,data);
						}										
					}
					refreshMem();
					if (memVec1.vector[0] == 0) {me.fra.hide()}
				}
			}
		},0,0);

	### ADF ###
		setlistener(adf_freq, func(n) {	
			me.text.adfFreq.setText(sprintf("%d",n.getValue()));
		},0,0);

		setlistener(adf_mode, func(n) {	
			me.text.adfMode.setText(n.getValue());
		},0,0);

	### ATC - Transponder ###
		setlistener(trsp_k_mode, func(n) {
			var mode = n.getValue();
			var mode_dsp = "";
			if (mode == 0) {mode_dsp = "STANDBY"}
			if (mode == 1) {mode_dsp = "ATC ON"}
			if (mode == 2) {mode_dsp = "ATC ALT"}
			if (mode == 3) {mode_dsp = "TA ONLY"}
			if (mode == 4) {mode_dsp = "TA/RA"}
			setprop("instrumentation/transponder/unit[0]/display-mode",mode_dsp);
		},0,0);

		setlistener(trsp_code, func(n) {	
			me.text.trspCode.setText(sprintf("%04d",n.getValue()));
			if (trsp_num.getValue() == "1") {
				setprop("instrumentation/transponder/id-code",n.getValue());
				setprop("instrumentation/transponder/transmitted-id",n.getValue());
			}
		},0,0);

		setlistener(trsp_mode, func {	
			trspMode();			
		},0,0);

		setlistener(trsp_num, func {	
			trspMode();
		},0,0);

		var trspMode = func {
			me.text.trspNum.setText(trsp_num.getValue());
			if (trsp_num.getValue() == "2") {				
				me.text.trspMode.setText("STANDBY");
			} else {
				me.text.trspMode.setText(trsp_mode.getValue());
			}			
		};

	### Tests Display ###
		setlistener(test, func {	
			var n = 1;
			var timerTst = maketimer(2,func() {
				tstDsp(n,timerTst);
				n+=1;
				if (n==9) {timerTst.stop()}
			});

			if (test.getValue()){
				me.rmu1.setVisible(0);
				me.mem1.setVisible(0);
				me.test1.setVisible(1);
				foreach(var i;me.tst_val) {
					me.tst[i].hide();
				}
				me.tst[me.tst_val[0]].show();
				var tstDsp = func(n,timerTst) {
					me.tst[me.tst_val[n]].show();
				};
				timerTst.start();

			} else {
				me.test1.setVisible(0);
				me.rmu1.setVisible(1);
				me.mem1.setVisible(0);		
				if (timerTst.isRunning) {timerTst.stop()}
			}
		},0,0);

	}, # end of listen	

	### Memories bank full ###

	memFull : func {
		full.show();
		var fullTimer = maketimer(2,func() {
			full.hide();
			fullTimer.stop();
		});
		fullTimer.start();
	}, # end of memFull

}; # end of RMU1

	### Refresh memories ###
var refreshMem = func {
	var n = 0;
	if (selected.getValue() != 1) {mem1 = com1;mem_1 = com_mem1}
	if (selected.getValue() == 1) {mem1 = nav1;mem_1 = nav_mem1}
	foreach(var i;mem_1) {
		mem1[i] = data.getValue(i);
		memVec1.vector[n] = mem1[mem_1[n]];
		n+=1;
	}
}; # end of Refresh memories

###### Main #####
var rmu1_setl = setlistener("/sim/signals/fdm-initialized", func () {	
	var init = RMU1.new();
	init.listen();
removelistener(rmu1_setl);
},0,0);
