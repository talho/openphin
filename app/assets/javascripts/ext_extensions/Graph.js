//= require ext_extensions/D3Graph
//= require ext_extensions/FlashGraph

Talho.ux.Graph = Ext.extend(Ext.Container, {
  height: 230,
  boxMinWidth: 320,
  
  constructor: function (config) {
    if (Talho.Detection.SVG) {
      //this.items = [new Talho.ux.FlashGraph(config)];
      this.items = [new Talho.ux.D3Graph(config)];
    }
    else {
      this.items = [new Talho.ux.FlashGraph(config)];
    }

    this.doLayout();
    Talho.ux.Graph.superclass.constructor.apply(this,config);
  }
});
