
Ext.ns('Talho.Reports.view');

Talho.Reports.view.Index = Ext.extend(Ext.Panel, {
  title: 'My Reports',
  layout: 'border',
  constructor: function(){
    Talho.Reports.view.Index.superclass.constructor.apply(this, arguments);
    this.addEvents('newreport', 'deletereport');
    this.enableBubble('newreport');
    this.enableBubble('deletereport');
  },
  getBubbleTarget: function(){
    if(!this.layoutParent){ // bubble up to the layout class way up above
      this.layoutParent = this.findParentByType('talho-reports-layout');
    }
    return this.layoutParent;
  },
  initComponent: function(){
    this.items = [
      {xtype: 'dataview', itemId: 'dataview', region: 'center', store: new Ext.data.JsonStore({
        restful: true,
        url: '/reports.json',
        root: 'reports',
        fields: ['id', 'name', 'date'],
        autoDestroy: true,
        autoLoad: true
      }), tpl: new Ext.XTemplate(
        '<tpl for=".">',
          '<div class="report-dataview">',
            '<span>{name} - {date}</span>',
            '<span style="float:right;">',
              '<a href="/reports/{id}.html" target="_blank">html</a> ',
              '<!--<a href="/reports/{id}.pdf" target="_blank">pdf</a>-->',
              '<span class="spanBtn removeBtn">&nbsp;</span>',
            '</span>',
          '</div>',
        '</tpl>'
      ), itemSelector: 'div.report-dataview', loadingText: 'loading', listeners: {
        scope: this,
        'click': this.dataview_click
      }},
      {xtype: 'button', text: 'Run New Report', region: 'south', scope: this, handler: function(){this.fireEvent('newreport');}}
    ]
    
    Talho.Reports.view.Index.superclass.initComponent.apply(this, arguments);
  },
  
  dataview_click: function(dv, i, node, e){
    if(e.getTarget('.removeBtn')){
      this.fireEvent('deletereport', dv.getStore().getAt(i));
    }
  },
  
  refresh: function(){
    this.getComponent('dataview').getStore().load();
  }
});
