
Ext.ns('Talho.Reports.view');

Talho.Reports.view.NewReportSchedule = Ext.extend(Ext.Panel, {
  title: 'My Reports',
  layout: 'border',
  constructor: function(){
    Talho.Reports.view.NewReportSchedule.superclass.constructor.apply(this, arguments);
    this.addEvents('createreportschedule');
    this.enableBubble('createreportschedule');
  },
  getBubbleTarget: function(){
    if(!this.layoutParent){ // bubble up to the layout class way up above
      this.layoutParent = this.findParentByType('talho-reports-layout');
    }
    return this.layoutParent;
  },
  initComponent: function(){
    this.items = [
      {xtype: 'form', itemId: 'form', border: false, padding: 5, unstyled: true, region: 'center', labelAlign: 'top', items: [
        {xtype: 'combo', itemId: 'report-combo', fieldLabel: 'Report Type', anchor: '100%', name: 'report_schedule[report_type]', store: new Ext.data.JsonStore({
          restful: true,
          autoLoad: true,
          fields: ['name', 'type'],
          root: 'reports',
          url: '/reports/new.json',
          autoDestroy: true
        }), displayField: 'name', valueField: 'type', editable: false, triggerAction: 'all', mode: 'local'},
        {xtype: 'label', text: 'Days to run the report:'},
        {xtype: 'checkbox', boxLabel: 'Sunday', name: 'report_schedule[days_of_week][0]', inputValue: true, hideLabel: true},
        {xtype: 'checkbox', boxLabel: 'Monday', name: 'report_schedule[days_of_week][1]', inputValue: true, hideLabel: true},
        {xtype: 'checkbox', boxLabel: 'Tuesday', name: 'report_schedule[days_of_week][2]', inputValue: true, hideLabel: true},
        {xtype: 'checkbox', boxLabel: 'Wednesday', name: 'report_schedule[days_of_week][3]', inputValue: true, hideLabel: true},
        {xtype: 'checkbox', boxLabel: 'Thursday', name: 'report_schedule[days_of_week][4]', inputValue: true, hideLabel: true},
        {xtype: 'checkbox', boxLabel: 'Friday', name: 'report_schedule[days_of_week][5]', inputValue: true, hideLabel: true},
        {xtype: 'checkbox', boxLabel: 'Saturday', name: 'report_schedule[days_of_week][6]', inputValue: true, hideLabel: true}
      ], buttons: [
        {text: 'Save Schedule', scope: this, handler: this.save_clicked}
      ]}
    ];

    Talho.Reports.view.NewReportSchedule.superclass.initComponent.apply(this, arguments);
  },

  save_clicked: function(){
    var form = this.getComponent('form').getForm();
    this.fireEvent('createreportschedule', form.getValues());
  }
});
