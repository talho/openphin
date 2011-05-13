Ext.namespace('Talho');
Ext.namespace('Talho.Dashboard');

Talho.Dashboard = Ext.extend(Ext.util.Observable, {
  constructor: function(config)
  {
    Ext.apply(this, config);

    Talho.Dashboard.superclass.constructor.call(this, config);

    var portal = new Talho.Dashboard.Portal({
      items: [{
        columnWidth:.33,
        style:'padding:10px 0 10px 10px',
        items:[]
      },{
        columnWidth:.33,
        style:'padding:10px 0 10px 10px',
        items:[]
      },{
        columnWidth:.33,
        style:'padding:10px',
        items:[]
      }]
    });

    var panel = new Ext.Panel({
      title: 'Dashboard',
      layout: 'border',
      items: [portal]
    });


    this.getPanel = function(){
      return panel;
    }
  }
});

Talho.Dashboard.initialize = function(config)
{
  return (new Talho.Dashboard(config)).getPanel();
}
