//= require ext_extensions/D3Graph
//= require ext_extensions/FlashGraph

Talho.ux.Graph = Ext.extend(Ext.Container, {
  height: 190,
  boxMinWidth: 320,
  cls: 'ux-graph-container',
  
  initComponent: function () {
    if (Talho.Detection.SVG) {
      // this.items = [new Talho.ux.FlashGraph({store: this.store})];
      this.items = [new Talho.ux.D3Graph({store: this.store})];
    }
    else {
      this.items = [new Talho.ux.FlashGraph({store: this.store})];
    }
   
    Talho.ux.Graph.superclass.initComponent.apply(this, arguments);
  }
});
