/**
 * @author Charles DuBose
 */
Ext.ns("Ext.ux.GMap");

Ext.ux.GMap.GMapInfoWindow = Ext.extend(Ext.Panel, {
  /**
   * Create the google.map info window and show it on the marker. attach events to the info window
   */
  constructor: function(config){
    Ext.ux.GMap.GMapInfoWindow.superclass.constructor.apply(this, arguments);
    
    this.content_set = false;
    
    this.map = this.map || this.marker.getMap();
    if(this.map.open_window){
      this.map.open_window.close();
    }
    this.map.open_window = this.info_window = new google.maps.InfoWindow({content: Ext.DomHelper.createDom({tag: 'div'}) });
    this.info_window.open(this.map, this.marker);
    google.maps.event.addListener(this.info_window, 'domready', this.domReady.createDelegate(this));
    google.maps.event.addListener(this.info_window, 'closeclick', function(){ this.map.open_window = null; this.destroy(); }.createDelegate(this));
  },
  
  initComponent: function(){
    this.items = [{xtype: 'box', html: 'hi'}];
    
    Ext.ux.GMap.GMapInfoWindow.superclass.initComponent.apply(this, arguments);
    
    this.render(Ext.DomHelper.createDom({tag: 'div'}));
  },
  
  domReady: function(){
    if(!this.content_set){
      this.content_set = true;
      this.info_window.setContent(this.getEl().dom);
    }
  },
  
  close: function(){
    this.info_window.close();
  }
});
