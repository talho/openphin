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
        items:[{
          xtype: 'dashboardhtmlportlet',
          html: '<p> Test 1 </p>',
          layout:'fit',
          column: 0
        },{
          xtype: 'dashboardhtmlportlet',
          html: '<p> Test 2 </p>',
          column: 0
        }]
      },{
        columnWidth:.33,
        style:'padding:10px 0 10px 10px',
        items:[{
          xtype: 'dashboardhtmlportlet',
          html: '<p> <a href="//tech.slashdot.org/story/11/05/12/188221/Engineers-Find-Nuclear-Meltdown-At-Fukushima-Plant"">Engineers Find Nuclear Meltdown At Fukushima Plant</a> </p>',
          column: 1
        },{
          xtype: 'dashboardhtmlportlet',
          html: '<p> <b>Test 4</b> </p>',
          column: 1
        }]
      },{
        columnWidth:.33,
        style:'padding:10px',
        items:[{
          xtype: 'dashboardhtmlportlet',
          html: '<p> Test 5 </p>',
          column: 2
        },{
          xtype: 'dashboardhtmlportlet',
          html: '<p> Test 6 </p>',
          column: 2
        }]
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
