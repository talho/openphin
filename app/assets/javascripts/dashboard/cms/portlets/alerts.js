Ext.namespace('Talho.Dashboard.Portlet');

Talho.Dashboard.Portlet.Alerts = Ext.extend(Talho.Dashboard.Portlet, {
  fields: ['numEntries', 'urls'],
  numAlerts: 5,

  initComponent: function() {
    this.alert_store = new Ext.data.JsonStore({
      url: '/alerts/recent_alerts.json',
      baseParams: {
        'num_alerts': this.numAlerts
      },
      autoLoad: true,
      fields: ['title', 'id', 'message', {name: 'created_at', type: 'date'}],
      restful: true
    });
    
    this.items = [{
      xtype: 'dataview',
      store: this.alert_store,
      tpl: [
        '<tpl for=".">',
        '<div class="dash-alert-node">',
          '<div class="dash-alert-title">{title} ({[fm.date(values.created_at, "n/d/y, g:i A")]})</div>',
          '<div class="dash-alert-message">{[values.message.summarizeHtml(250) + (values.message.length > 250 ? "..." : "")]}</div>',
        '</div>',
        '</tpl>'
      ],
      loadingText: 'Loading Alerts Feed...',
      itemSelector: 'div.dash-alert-node',
      listeners: {
        scope: this,
        click: this.alert_click
      }}
    ]
    
    this.tools = [{ id:'refresh', qtip: 'Refresh', handler: function(){this.alert_store.load({params:{'num_alerts': this.numAlerts}});}, scope: this}]
    
    Talho.Dashboard.Portlet.Alerts.superclass.initComponent.apply(this, arguments);
  },
  
  
  alert_click: function(dv, i, n, e) {
    var r = dv.getStore().getAt(i);
    if(this.tip && this.tip.isVisible()){
      this.tip.destroy();
    }
    
    this.tip = new Ext.Tip({
      defaultAlign: 'tl-bl?',
      tpl: [
        '<div class="t_boot">',
          '<div class="dash-rss-entry">',
            '<div class="dash-rss-body">{[values.message || ""]}</div>',
          '</div>',
        '</div>'
      ],
      data: {
        message: r.get('message')
      },
      title: r.get('title'),
      cls: "t_boot",
      maxWidth: 500,
      constrainPosition: true,
      closable: true,
      renderTo: dv.ownerCt.ownerCt.getEl()
    });
    this.tip.showBy(n);
  },

  
  showEditWindow: function(){
    var win = new Ext.Window({
      title: 'Edit Alerts Portlet',
      layout: 'form',
      items: [
          {xtype: 'textfield', fieldLabel: 'Portlet title', itemId: 'titleField', value: this.title, anchor: '100%'},
          {xtype: 'numberfield', fieldLabel: 'Alerts to show', itemId: 'num_alerts', anchor: '100%', value: this.numAlerts}
      ],
      buttons: [
        {text: 'OK', scope: this, handler: function(){
          this.editWindow_save(win);
        }},
        {text: 'Cancel', scope: this, handler: function(){win.close();}}
      ],
      width: 600,
      height: 300
    });
    win.show();
  },

  editWindow_save: function(win){
    this.numAlerts = win.getComponent('north').getComponent('num_alerts').getValue();
    this.title = win.getComponent('north').getComponent('titleField').getValue();
  },
  
  isModified: function() {
    return true;
  },

  revert: function() {
    return true;
  },

  title: 'Recent Alerts Portlet'
});

Ext.reg('dashboardalertportlet', Talho.Dashboard.Portlet.Alerts);