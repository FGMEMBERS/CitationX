# Copyright 2018 Stuart Buchanan
# This file is part of FlightGear.
#
# FlightGear is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# FlightGear is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with FlightGear.  If not, see <http://www.gnu.org/licenses/>.
#
#     Navigation map functions 
#     Adapted to the Citation X by C. Le Moigne (clm76) on Déc 2018

var nasal_dir = getprop("/sim/aircraft-dir") ~ "/Models/Instruments/MFD/canvas";
io.load_nasal(nasal_dir ~ '/NavMapStyles.nas', "fgMap");
io.include('init.nas');

var hdg = "/orientation/heading-deg";
var rangeNm = "instrumentation/efis/inputs/range-nm";
var Hdg = nil;
var HdgBug = nil;
var HdgVis = nil;
var Range = nil;
var Tcas = nil;
var AltDiff = nil;
var AltRange = nil;
var AltRangePx = nil;
var Vspd = nil;
var GndSpd = nil;

var NavMap = {
  # Lazy-loading - only create the map element when the page becomes visible,
  # and delete afterwards.
  LAZY_LOADING : 1,

  # Layer display configuration:
  # enabled   - whether this layer has been enabled by the user
  # declutter - the maximum declutter level (0-3) that this layer is visible in
  # range     - the maximum range this layer is visible (configured by user)
  # max_range - the maximum range value that a user can configure for this layer.
  # static - whether this layer should be displayed on static maps (as opposed to the moving maps)
  # factory - name of the factory to use for creating the layer
  # priority - layer priority

  layerRanges : {
    DME  : { enabled: 1, declutter: 3, range: 20, max_range: 80, static : 1, factory : canvas.SymbolLayer, priority : 4, vis :1},
    VOR_cit  : { enabled: 1, declutter: 1, range: 80, max_range: 160, static : 1, factory : canvas.SymbolLayer, priority : 4, vis : 1},
    NDB_cit  : { enabled: 1, declutter: 1, range: 40, max_range: 80, static : 1, factory : canvas.SymbolLayer, priority : 4, vis :1},
    FIX  : { enabled: 1, declutter: 1, range: 10, max_range: 30, static : 1, factory : canvas.SymbolLayer, priority : 4, vis :1},
    RTE  : { enabled: 1, declutter: 3, range: 2000, max_range: 2000, static : 1, factory : canvas.SymbolLayer, priority : 2, vis :1},
    WPT_cit  : { enabled: 1, declutter: 3, range: 2000, max_range: 2000, static : 1, factory : canvas.SymbolLayer, priority : 4, vis :1},
    FLT  : { enabled: 1, declutter: 4, range: 2000, max_range: 2000, static : 1, factory : canvas.SymbolLayer, priority : 3, vis :0},
    WXR  : { enabled: 1, declutter: 2, range: 2000, max_range: 2000, static : 1, factory : canvas.SymbolLayer, priority : 4, vis :1},
    APT_cit  : { enabled: 1, declutter: 3, range: 80, max_range: 80, static : 1, factory : canvas.SymbolLayer, priority : 4, vis :1},
    TFC  : { enabled: 1, declutter: 3, range: 160, max_range: 2000, static : 1, factory : canvas.SymbolLayer, priority : 4, vis :1},
    APS  : { enabled: 1, declutter: 3, range: 2000, max_range: 2000, static : 1,  factory : canvas.SymbolLayer, priority : 4, vis :1},
    STAMEN_terrain  : { enabled: 1, declutter: 3, range: 500, max_range: 2000, static : 1, factory : canvas.OverlayLayer, priority : 1, vis :0},
    OpenAIP : { enabled: 1, declutter: 1, range: 80, max_range: 150, static : 1, factory : canvas.OverlayLayer, priority : 1, vis :0},
    STAMEN  : { enabled: 1, declutter: 3, range: 500, max_range: 2000, static : 1, factory : canvas.OverlayLayer, priority : 1, vis :0},
  },

  new : func() {
    var m = {parents : [NavMap],
      _center : [450,475], #old 450,475
      _zindex : 0,
      _zoom : 20,
      _declutter : 0,
      _airways : 0,
      _map : nil,
      _plan : nil,
      _layerRanges : {},
      _static : 0,
      _cdr0 : 0,
      _cdr1 : 0,
      _cdr2 : 0,
      _source : 1,
      _wxr : 0,
    };
		m.canvas = canvas.new({
			"name": "ND", 
			"size": [1024, 1024],
			"view": [900, 1024],
			"mipmapping": 1 
		});
		m.canvas.addPlacement({"node": "Layers.screen"});
  	m.nd = m.canvas.createGroup();
		canvas.parsesvg(m.nd, get_local_path("Images/ND_B.svg"));
    m.layer = {};
    m.layer_val = ["layerMap","layerPlan"];
		foreach(var element;m.layer_val) {
			m.layer[element] = m.nd.getElementById(element);
		}

    m.symbols = {};
		foreach(var element;["hsi","compass","hdgIndex","hdgBug",
				                "arrowL","arrowR","rangeL","rangeLtxt",
									      "rangeR","rangeRtxt","hdgLine","tcas",
										    "tcasLabel","tcasValue","tfcRangeInt","altArc"]) 
			m.symbols[element] = m.nd.getElementById(element);

    m.layer.layerMap.setTranslation(m._center[0], m._center[1]);
    m.Styles = fgMap.NavMapStyles.new();

    foreach (var i; keys(NavMap.layerRanges)) {
      m._layerRanges[i] = NavMap.layerRanges[i];
    }

    if (NavMap.LAZY_LOADING == 1) {
      m.createMapElement();
      m.animateSymbols();
    }
  
    return m;
  },

  createMapElement : func() {
    if (me._map != nil) return;
    me._map = me.layer.layerMap.createChild("map");
    me._map.setScreenRange(277); # old 277
    me._plan = me.layer.layerPlan.createChild("map");
    me._plan.setScreenRange(360); # old 360
    # Initialize the controllers:
#    if (me._static) {
#      me._map.setController("Static position", "main");
#    } else {
      var ctrl_ns = canvas.Map.Controller.get("Aircraft position");
      var source = ctrl_ns.SOURCES["current-pos"];
      if (source == nil) {
        var source = ctrl_ns.SOURCES["current-pos"] = {
          getPosition: func subvec(geo.aircraft_position().latlon(), 0, 2),
          getAltitude: func getprop('/position/altitude-ft'),
          getHeading: func {
            if (me.aircraft_heading) getprop(hdg) or 0
            else 0
          },
          aircraft_heading: 1,
        };
        setlistener("instrumentation/primus2000/dc840/mfd-map", func(n) {
          if (n.getValue()) {
            source.aircraft_heading = 0;
            me.layer.layerPlan.hide();
            me.layer.layerMap.show();
          } else {
            source.aircraft_heading = 1;
            me.layer.layerPlan.show();
            me.layer.layerMap.hide();
          }
        },1,0);  
#      }

      # Make it move with our aircraft:
      me._map.setController("Aircraft position", "current-pos"); # from aircraftpos.controller
      me._plan.setController("Aircraft position", "current-pos");
    }

    if (me._zindex != 0) {
      me._element.setInt("z-index", me._zindex);
    }

    var r = func(name,on_static=1, vis=1,zindex=nil) return caller(0)[0];
    foreach (var layer_name; me.getLayerNames()) {
      var layer = me.getLayer(layer_name);
      if (layer.static == 1) {
        me._map.addLayer(
          factory: layer.factory,
          type_arg: layer_name,
          priority: layer.priority,
          style: me.Styles.getStyle(layer_name),
          options: nil,
          visible: 0);
        me._plan.addLayer(
          factory: layer.factory,
          type_arg: layer_name,
          priority: layer.priority,
          style: me.Styles.getStyle(layer_name),
          options: nil,
          visible: 0);
        me._plan.setTranslation(450,475); # old 450,475
      }
    }

    setlistener(rangeNm, func(n) {
      me.setZoom(n.getValue() or 20);
   },1,0);

    setlistener("instrumentation/primus2000/mfd/cdr0", func(n) {
      me._cdr0 = n.getValue();
      me.updateVisibility();
    },0,0);

    setlistener("instrumentation/primus2000/mfd/cdr1", func(n) {
      me._cdr1 = n.getValue();
      me.updateVisibility();
    },0,0);

    setlistener("instrumentation/primus2000/mfd/cdr2", func(n) {
      me._cdr2 = n.getValue();
      me.updateVisibility();
    },0,0);

    setlistener("autopilot/settings/nav-source", func(n) {
      me._source = left(n.getValue(),3) == 'FMS' ? 0 : 1;
      me.updateVisibility();
    },0,0);

    setlistener("instrumentation/efis/inputs/wxr", func(n) {
      me._wxr = n.getValue();
      me.updateVisibility();
    },0,0);

#    setlistener("environment/weather-scenario", func {
#      me.updateVisibility();
#    },0,0);

  }, # end of createMapElement

  setController : func(type, controller ) {
    if (NavMap.LAZY_LOADING) me.createMapElement();
    me._map.setController(type, controller);
    me._plan.setController(type, controller);
  },

  setZoom : func(zoom) {
    if (NavMap.LAZY_LOADING) me.createMapElement();
    me._zoom = zoom;
    me._map.setRange(me._zoom);
    me._plan.setRange(me._zoom);
    me.updateVisibility();
  },

  updateVisibility : func() {
    if (NavMap.LAZY_LOADING) me.createMapElement();
    # Determine which layers should be visible.
    foreach (var layer_name; me.getLayerNames()) {
      var layer = me.getLayer(layer_name);
      if (me._map.getLayer(layer_name) == nil) continue;

      # Layers are only displayed if:
      # 1) the user has enabled them.
      # 2) The current zoom level is _less than the maximum range for the layer
      #    (i.e. as the range gets larger, we remove layers).  
      if (layer.enabled and me._zoom <= layer.range) {
            me._map.getLayer(layer_name).setVisible(1);
        if (layer.vis){
          me._plan.getLayer(layer_name).setVisible(1);
          me._map.getLayer('FIX').setVisible(me._cdr2);
          me._plan.getLayer('FIX').setVisible(me._cdr2);
          me._map.getLayer('VOR_cit').setVisible(me._cdr0);
          me._plan.getLayer('VOR_cit').setVisible(me._cdr0);
          me._map.getLayer('APT_cit').setVisible(me._cdr1);
          me._plan.getLayer('APT_cit').setVisible(me._cdr1);
          me._plan.getLayer('DME').setVisible(me._zoom > 80 ? 0 : me._cdr0);
          me._map.getLayer('NDB_cit').setVisible(me._zoom > 80 ? 0 : me._source);
          me._plan.getLayer('NDB_cit').setVisible(me._zoom > 80 ? 0 : me._source);
          me._map.getLayer('WXR').setVisible(me._wxr);
          me._plan.getLayer('WXR').setVisible(me._wxr);
        } else me._map.getLayer(layer_name).setVisible(1);
      } else {
        me._map.getLayer(layer_name).setVisible(0);
        me._plan.getLayer(layer_name).setVisible(0);
      }
    }
  },

  getLayerNames : func() {
    return keys(me._layerRanges);
  },

  getLayer : func (name) {
    return me._layerRanges[name];
  },

  setVisible : func(visible) {
    if (visible) {
      if (NavMap.LAZY_LOADING) me.createMapElement();
      me._map.setVisible(visible);
      me._plan.setVisible(visible);
    } else {
      if (me._map != nil) me._map.setVisible(visible);
      if (me._plan != nil) me._plan.setVisible(visible);
      if (NavMap.LAZY_LOADING) me._map = nil;
      if (NavMap.LAZY_LOADING) me._plan = nil;
    }
  },
  
  animateSymbols : func {
    Hdg = getprop(hdg) or 0;
    HdgBug = getprop("/autopilot/internal/heading-bug-error-deg") or 0;
    Range = getprop(rangeNm) or 20;
    Tcas = getprop("instrumentation/primus2000/dc840/tcas");
    Vspd = getprop("/velocities/vertical-speed-fps");
    GndSpd = getprop("/velocities/groundspeed-kt");
    hdgVis = (getprop("autopilot/locks/heading")== "ROLL" |
              getprop("autopilot/locks/heading")== "HDG") ? 1 : 0;

    me.symbols.compass.setRotation(-Hdg*D2R);
    me.symbols.hdgBug.setCenter(450,516);    
    me.symbols.hdgBug.setRotation(HdgBug*D2R);
    me.symbols.hsi.setText(sprintf("%03d",Hdg));
    me.symbols.rangeLtxt.setText(sprintf("%d",Range/2));
    me.symbols.rangeRtxt.setText(sprintf("%d",Range/2));
    me.symbols.arrowL.setVisible(HdgBug < -53);
    me.symbols.arrowR.setVisible(HdgBug > 53);
    me.symbols.hdgLine.setCenter(450,512).setVisible(hdgVis);
    me.symbols.hdgLine.setRotation(HdgBug*D2R);
    me.symbols.tcasValue.setText(Tcas ? "AUTO" : "OFF");
    me.symbols.tfcRangeInt.setVisible(Tcas);

    AltDiff = (getprop("autopilot/settings/target-altitude-ft") or 0)-(getprop("instrumentation/altimeter/indicated-altitude-ft") or 0);
		if (abs(Vspd) > 1 and AltDiff/Vspd > 0) {
			AltRange = AltDiff/Vspd*GndSpd*KT2MPS*M2NM;
			if(AltRange > 1) {
				AltRangePx = (350/Range)*AltRange;
				if (AltRangePx > 700) AltRangePx = 700;
				me.symbols.altArc.setTranslation(0,-AltRangePx);
			}
			me.symbols.altArc.show();
		} else me.symbols.altArc.hide();

   settimer(func me.animateSymbols(),0.05);
  },
};
