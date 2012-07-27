//= require ext_extensions/D3Graph
//= require ext_extensions/FlashGraph

Talho.ux.Graph = Ext.extend(Ext.Container, {
  //TODO do defaults
  
  constructor: function (config) {
    if (Talho.Detection.SVG) {
      this.items = [new Talho.ux.D3Graph(config)];
    }
    else {
      this.items = [new Talho.ux.FlashGraph(config)];
    }
  }
});
