/*!
 * Ext JS Library 3.3.1
 * Copyright(c) 2006-2010 Sencha Inc.
 * licensing@sencha.com
 * http://www.sencha.com/license
 */
/**
 * @class Ext.ux.GMapPanel
 * @extends Ext.Panel
 * @author Shea Frederick
 */
Ext.ux.GMapPanel = Ext.extend(Ext.Panel, {
    markers: [],
    
    constructor: function(){
      this.addEvents('markerclick');
      
      Ext.ux.GMapPanel.superclass.constructor.apply(this, arguments);
    },
    
    initComponent : function(){
        
        var defConfig = {
            plain: true,
            zoomLevel: 3,
            yaw: 180,
            pitch: 0,
            zoom: 0,
            gmapType: 'map',
            border: false
        };
        
        Ext.applyIf(this,defConfig);
        
        Ext.ux.GMapPanel.superclass.initComponent.call(this);        
        this.geocoder = new google.maps.Geocoder();
    },
    
    afterRender: function(){
      var wh = this.ownerCt.getSize();
      Ext.applyIf(this, wh);
      
      Ext.ux.GMapPanel.superclass.afterRender.call(this);
      var opts = {
        zoom: this.zoomLevel,
        center: new google.maps.LatLng(0,0),
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };
      this.gmap = new google.maps.Map(this.body.dom, opts);

      if(Ext.isObject(this.setCenter)){
        if(Ext.isString(this.setCenter.geoCodeAddr)){
          this.centerMap(this.setCenter.geoCodeAddr);
        }
        else{
          this.centerMap(this.setCenter.lat, this.setCenter.lng);
        }
      }
      
      google.maps.event.addListener(this.gmap, 'mousemove', this.trackMouse.createDelegate(this));
    },
    
    centerMap: function(lat, lng){
      if(Ext.isString(lat)){
        this.geocoder.geocode({address: lat}, function(results, status){
          this.gmap.setCenter(results[0].geometry.location);
        }.createDelegate(this));
      }
      else if(Ext.isObject(lat)){
        this.gmap.setCenter(lat);
      }
      else{
        this.gmap.setCenter(new google.maps.LatLng(lat, lng));
      }
    },
    
    trackMouse: function(mouseEvent){
      this.current_latlng = mouseEvent.latLng;
    },
    
    trackObjectEnter: function(event, over){
      if(this.current_hover != over){
        this.current_hover = over;
      }
    },
    
    trackObjectLeave: function(event, over){
      if(this.current_hover == over){
        this.current_hover = null;
      }
    },
    
    onMarkerClick: function(event, marker){
      this.fireEvent('markerclick', marker);
    },
    
    getCurrentHover: function(){
      return this.current_hover;
    },
    
    getCurrentLatLng: function(){
      return this.current_latlng;
    },
    
    addMarker: function(latLng, title, data){
      var marker = new google.maps.Marker({position: latLng, title: title, map: this.gmap, data: data});
      this.markers.push(marker);
      google.maps.event.addListener(marker, 'mouseover', this.trackObjectEnter.createDelegate(this, [marker], true));
      google.maps.event.addListener(marker, 'mouseout', this.trackObjectLeave.createDelegate(this, [marker], true));
      google.maps.event.addListener(marker, 'click', this.onMarkerClick.createDelegate(this, [marker], true));
      return marker;
    },
    
    showInfoWindow: function(marker, content){
      if(this.open_window){
        this.open_window.close();
      }
      this.open_window = new google.maps.InfoWindow({content: content});
      this.open_window.open(this.gmap, marker);
      google.maps.event.addListener(this.open_window, 'closeclick', function(){
        this.open_window = null;
      }.createDelegate(this));
      return this.open_window;
    }
    /*
    afterRender : function(){
        
        var wh = this.ownerCt.getSize();
        Ext.applyIf(this, wh);
        
        Ext.ux.GMapPanel.superclass.afterRender.call(this);    
        if (this.gmapType === 'map'){
            this.gmap = new google.maps.Map(this.body.dom);
        }
        
        if (this.gmapType === 'panorama'){
            this.gmap = new google.maps.StreetViewPanorama(this.body.dom);
        }
        
        if (typeof this.addControl == 'object' && this.gmapType === 'map') {
            this.gmap.addControl(this.addControl);
        }
        
        if (typeof this.setCenter === 'object') {
            if (typeof this.setCenter.geoCodeAddr === 'string'){
                this.geoCodeLookup(this.setCenter.geoCodeAddr);
            }else{
                if (this.gmapType === 'map'){
                    var point = new google.maps.LatLng(this.setCenter.lat,this.setCenter.lng);
                    this.gmap.setCenter(point, this.zoomLevel);    
                }
                if (typeof this.setCenter.marker === 'object' && typeof point === 'object'){
                    this.addMarker(point,this.setCenter.marker,this.setCenter.marker.clear);
                }
            }
            if (this.gmapType === 'panorama'){
                this.gmap.setPosition(new google.maps.LatLng(this.setCenter.lat,this.setCenter.lng));
                this.gmap.setPov(new google.maps.StreetViewPov({heading: this.yaw, pitch: this.pitch, zoom: this.zoom});
            }
        }

        google.maps.addDomListener(this.gmap, 'load', function(){
            this.onMapReady();
        }.createDelegate(this));

    },
    onMapReady : function(){
        this.addMarkers(this.markers);
        this.addMapControls();
        this.addOptions();  
    },
    onResize : function(w, h){

        if (typeof this.getMap() == 'object') {
            this.gmap.checkResize();
        }
        
        Ext.ux.GMapPanel.superclass.onResize.call(this, w, h);

    },
    setSize : function(width, height, animate){
        
        if (typeof this.getMap() == 'object') {
            this.gmap.checkResize();
        }
        
        Ext.ux.GMapPanel.superclass.setSize.call(this, width, height, animate);
        
    },
    getMap : function(){
        
        return this.gmap;
        
    },
    getCenter : function(){
        
        return this.getMap().getCenter();
        
    },
    getCenterLatLng : function(){
        
        var ll = this.getCenter();
        return {lat: ll.lat(), lng: ll.lng()};
        
    },
    addMarkers : function(markers) {
        
        if (Ext.isArray(markers)){
            for (var i = 0; i < markers.length; i++) {
                var mkr_point = new GLatLng(markers[i].lat,markers[i].lng);
                this.addMarker(mkr_point,markers[i].marker,false,markers[i].setCenter, markers[i].listeners);
            }
        }
        
    },
    addMarker : function(point, marker, clear, center, listeners){
        
        Ext.applyIf(marker,G_DEFAULT_ICON);

        if (clear === true){
            this.getMap().clearOverlays();
        }
        if (center === true) {
            this.getMap().setCenter(point, this.zoomLevel);
        }

        var mark = new GMarker(point,marker);
        if (typeof listeners === 'object'){
            for (evt in listeners) {
                GEvent.bind(mark, evt, this, listeners[evt]);
            }
        }
        this.getMap().addOverlay(mark);

    },
    addMapControls : function(){
        
        if (this.gmapType === 'map') {
            if (Ext.isArray(this.mapControls)) {
                for(i=0;i<this.mapControls.length;i++){
                    this.addMapControl(this.mapControls[i]);
                }
            }else if(typeof this.mapControls === 'string'){
                this.addMapControl(this.mapControls);
            }else if(typeof this.mapControls === 'object'){
                this.getMap().addControl(this.mapControls);
            }
        }
        
    },
    addMapControl : function(mc){
        
        var mcf = window[mc];
        if (typeof mcf === 'function') {
            this.getMap().addControl(new mcf());
        }    
        
    },
    addOptions : function(){
        
        if (Ext.isArray(this.mapConfOpts)) {
            var mc;
            for(i=0;i<this.mapConfOpts.length;i++){
                this.addOption(this.mapConfOpts[i]);
            }
        }else if(typeof this.mapConfOpts === 'string'){
            this.addOption(this.mapConfOpts);
        }        
        
    },
    addOption : function(mc){
        
        var mcf = this.getMap()[mc];
        if (typeof mcf === 'function') {
            this.getMap()[mc]();
        }    
        
    },
    geoCodeLookup : function(addr) {
        
        this.geocoder = new GClientGeocoder();
        this.geocoder.getLocations(addr, this.addAddressToMap.createDelegate(this));
        
    },
    addAddressToMap : function(response) {
        
        if (!response || response.Status.code != 200) {
            Ext.MessageBox.alert('Error', 'Code '+response.Status.code+' Error Returned');
        }else{
            place = response.Placemark[0];
            addressinfo = place.AddressDetails;
            accuracy = addressinfo.Accuracy;
            if (accuracy === 0) {
                Ext.MessageBox.alert('Unable to Locate Address', 'Unable to Locate the Address you provided');
            }else{
                if (accuracy < 7) {
                    Ext.MessageBox.alert('Address Accuracy', 'The address provided has a low accuracy.<br><br>Level '+accuracy+' Accuracy (8 = Exact Match, 1 = Vague Match)');
                }else{
                    point = new GLatLng(place.Point.coordinates[1], place.Point.coordinates[0]);
                    if (typeof this.setCenter.marker === 'object' && typeof point === 'object'){
                        this.addMarker(point,this.setCenter.marker,this.setCenter.marker.clear,true, this.setCenter.listeners);
                    }
                }
            }
        }
        
    }
 */
});

Ext.reg('gmappanel', Ext.ux.GMapPanel); 