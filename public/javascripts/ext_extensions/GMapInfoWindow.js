/**
 * @author Charles DuBose
 */
Ext.ns("Ext.ux.GMap");

Ext.ux.GMap.GMapInfoWindow = Ext.extend(Ext.Container, {
  /**
   * Create the google.map info window and show it on the marker. attach events to the info window.
   */
  initComponent: function(){   
    this.content_set = false;
    
    this.map = this.map || this.marker.getMap();
    
    this.holder = Ext.getBody().appendChild(Ext.DomHelper.createDom({tag: 'div', style: 'display:none;'}));
    
    if(this.autoShow)
      this.show();
    
    
    Ext.ux.GMap.GMapInfoWindow.superclass.initComponent.apply(this, arguments);
    
  },
  
  domReady: function(){
    this.doLayout(); // ensure that we're rendering the component into the space given instead of letting it hang over.
  },
  
  show: function(){
    if(this.map.open_window){
      this.map.open_window.close();
    }
    if(!this.rendered){
      this.render(this.holder);
    }
    
    this.map.open_window = this.info_window = new google.maps.InfoWindow({ content: this.getEl().dom });
    
    google.maps.event.addListener(this.info_window, 'domready', this.domReady.createDelegate(this));
    google.maps.event.addListener(this.info_window, 'closeclick', function(){ this.map.open_window = null; this.destroy(); }.createDelegate(this));
    
    this.info_window.open(this.map, this.marker);
  },
  
  close: function(){
    this.info_window.close();
  }
});
