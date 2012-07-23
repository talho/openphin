//TODO require files

Talho.ux.Graph = Ext.extend(Ext.Container, {
  //TODO do defaults
  
  initComponent: function (config) {
    if (Talho.Detection.SVG) {
      this.items = [new Talho.ux.D3Graph(config)];
    }
    else {
      this.items = [new Talho.ux.FlashGraph(config)];
    }
  }
});
