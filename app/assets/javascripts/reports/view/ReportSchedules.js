
Ext.ns('Talho.Reports.view');

Talho.Reports.view.ReportSchedules = Ext.extend(Ext.Panel, {
  title: 'My Reports',
  layout: 'border',
  constructor: function(){
    Talho.Reports.view.ReportSchedules.superclass.constructor.apply(this, arguments);
    this.addEvents('showeditreportschedule', 'shownewreportschedule');
    this.enableBubble('showeditreportschedule');
    this.enableBubble('shownewreportschedule');
  },
  getBubbleTarget: function(){
    if(!this.layoutParent){ // bubble up to the layout class way up above
      this.layoutParent = this.findParentByType('talho-reports-layout');
    }
    return this.layoutParent;
  },
  initComponent: function(){
    this.items = [
      {xtype: 'dataview', itemId: 'dataview', region: 'center', margins: '5', store: new Ext.data.JsonStore({
        restful: true,
        url: '/report_schedules.json',
        root: 'report_schedules',
        idProperty: 'report_type',
        fields: ['report_type'],
        autoDestroy: true,
        autoLoad: true
      }), tpl: new Ext.XTemplate(
        '<tpl for=".">',
          '<div class="report-dataview">',
            '<a href="#">{report_type}</a>',
          '</div>',
        '</tpl>',
        {compiled: true}
      ), itemSelector: 'div.report-dataview', loadingText: 'loading', listeners: {
        scope: this,
        'click': this.dataview_click
      }},
      {xtype: 'button', region: 'south', text: 'Schedule New Report', handler: this.fireEvent.createDelegate(this, ['shownewreportschedule'])}
    ]

    Talho.Reports.view.ReportSchedules.superclass.initComponent.apply(this, arguments);
  },

  dataview_click: function(dv, i, node, e){
    var rec = dv.getStore().getAt(i);
    this.fireEvent('showeditreportschedule', rec.get('report_type'));
  },

  refresh: function(){
    this.getComponent('dataview').getStore().load();
  }
});
