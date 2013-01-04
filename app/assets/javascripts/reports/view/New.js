
Ext.ns("Talho.Reports.view");

Talho.Reports.view.New = Ext.extend(Ext.Panel, {
  layout: 'fit',
  constructor: function(){
    Talho.Reports.view.New.superclass.constructor.apply(this, arguments);
    this.addEvents('runreport');
    this.enableBubble('runreport');
  },
  getBubbleTarget: function(){
    if(!this.layoutParent){ // bubble up to the layout class way up above
      this.layoutParent = this.findParentByType('talho-reports-layout');
    }
    return this.layoutParent;
  },
  initComponent: function(){
    this.items = [
      {xtype: 'panel', padding: 5, border: false, layout: 'form', itemId: 'holder-panel', labelAlign: 'top', items: [
        {xtype: 'combo', itemId: 'report-combo', fieldLabel: 'Select Report Type', anchor: '100%', store: new Ext.data.JsonStore({
          restful: true,
          autoLoad: true,
          fields: ['name', 'type'],
          root: 'reports',
          url: '/reports/new.json',
          autoDestroy: true
        }), displayField: 'name', valueField: 'type', editable: false, triggerAction: 'all', mode: 'local'}
      ], buttons: [
        {text: 'Run Report', handler: function(){ this.fireEvent('runreport', this.getComponent('holder-panel').getComponent('report-combo').getValue());}, scope: this}
      ]}
    ]

    Talho.Reports.view.New.superclass.initComponent.apply(this, arguments);
  }
});
