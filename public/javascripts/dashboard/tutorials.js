Ext.ns('TALHO');

Talho.Tutorials = Ext.extend(Ext.util.Observable, {
  constructor: function(config)
  {
    Ext.apply(this, config);
    Talho.Tutorials.superclass.constructor.call(this, config);
    var panel = new Ext.CenteredAjaxPanel({
      url: config.url,
      title: config.title,
      itemId: config.id,
      closable: true,
      hideBorders:true,
      autoScroll:true,
      listeners:{
        scope: this,
        'ajaxloadcomplete': this.panelLoaded
      }
    });
    panel.reset = this.scroll_to_element.bind(this);
    this.getPanel = function(){ return panel; }
  },
  panelLoaded: function(panel){
    panel.getEl().select("a[name='"+this.anchor+"']").first().dom.scrollIntoView(panel.getEl());
  },
  scroll_to_element: function(config){
    var panel = this.getPanel();
    panel.getEl().select("a[name='"+config.anchor+"']").first().dom.scrollIntoView(panel.getEl());
  }
});

Talho.Tutorials.initialize = function(config)
{
  var tutorials = new Talho.Tutorials(config);
  return tutorials.getPanel();
};

Talho.ScriptManager.reg('Talho.Tutorials', Talho.Tutorials, Talho.Tutorials.initialize);