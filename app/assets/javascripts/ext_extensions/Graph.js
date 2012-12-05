//= require ext_extensions/D3Graph
//= require ext_extensions/FlashGraph

Talho.ux.Graph = Ext.extend(Ext.Container, {
  layout: 'fit',
  cls: 'ux-graph-container',

  initComponent: function () {
    if (Talho.Detection.SVG()) {      
      this.items = [new Talho.ux.D3Graph({store: this.store, series: this.series, xField: this.xField, yLabel: this.yLabel, xLabel: this.xLabel, 
                                          yMin: this.yMin, yMax: this.yMax, xDisplayName: this.xDisplayName, showLegend: this.showLegend})];
    }
    else {
      this.items = [new Talho.ux.FlashGraph({store: this.store, height: this.height, series: this.series})];
    }
   
    Talho.ux.Graph.superclass.initComponent.call(this);
  }
});
