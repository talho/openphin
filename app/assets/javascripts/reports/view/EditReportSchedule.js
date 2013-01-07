
Ext.ns('Talho.Reports.view');

Talho.Reports.view.EditReportSchedule = Ext.extend(Ext.Panel, {
  title: 'My Reports',
  layout: 'border',
  constructor: function(){
    Talho.Reports.view.EditReportSchedule.superclass.constructor.apply(this, arguments);
    this.addEvents('updatereportschedule');
    this.enableBubble('updatereportschedule');
  },
  getBubbleTarget: function(){
    if(!this.layoutParent){ // bubble up to the layout class way up above
      this.layoutParent = this.findParentByType('talho-reports-layout');
    }
    return this.layoutParent;
  },
  initComponent: function(){
    this.items = [
      {xtype: 'form', itemId: 'form', border: false, padding: 5, unstyled: true, region: 'center', labelAlign: 'top', method: 'GET', url: '/report_schedules/' + this.report_type + '.json', items: [
        {xtype: 'textfield', fieldLabel: 'Report Type', anchor: '100%', value: '', name: 'report_schedule[report_type]', disabled: true},
        {xtype: 'label', text: 'Days to run the report:'},
        {xtype: 'checkboxgroup', itemId: 'checkboxgroup', columns: 1, items: [
          {xtype: 'checkbox', boxLabel: 'Sunday', name: 'report_schedule[days_of_week][0]', inputValue: true, hideLabel: true},
          {xtype: 'checkbox', boxLabel: 'Monday', name: 'report_schedule[days_of_week][1]', inputValue: true, hideLabel: true},
          {xtype: 'checkbox', boxLabel: 'Tuesday', name: 'report_schedule[days_of_week][2]', inputValue: true, hideLabel: true},
          {xtype: 'checkbox', boxLabel: 'Wednesday', name: 'report_schedule[days_of_week][3]', inputValue: true, hideLabel: true},
          {xtype: 'checkbox', boxLabel: 'Thursday', name: 'report_schedule[days_of_week][4]', inputValue: true, hideLabel: true},
          {xtype: 'checkbox', boxLabel: 'Friday', name: 'report_schedule[days_of_week][5]', inputValue: true, hideLabel: true},
          {xtype: 'checkbox', boxLabel: 'Saturday', name: 'report_schedule[days_of_week][6]', inputValue: true, hideLabel: true}
        ], listeners: {
          scope: this,
          'change': this.checkbox_changed
        }}
      ], buttons: [
        {text: 'Done', scope: this, handler: this.destroy}
      ]}
    ];

    Talho.Reports.view.EditReportSchedule.superclass.initComponent.apply(this, arguments);

    this.getComponent('form').load({
      scope: this,
      success: this.formLoad_complete,
      failure: this.formLoad_complete
    });
  },

  checkbox_changed: function(cbg){
    var checked = cbg.getValue(),
        vals = {};

    Ext.each(checked, function(c){
      vals[c.getName()] = c.getValue();
    });

    this.fireEvent('updatereportschedule', this.report_type, vals);
  },

  formLoad_complete: function(form, action){
    var res = Ext.decode(action.response.responseText);
    var rec = {'report_schedule[report_type]': res['report_type'],
               'report_schedule[days_of_week][0]': res['days_of_week'][0],
               'report_schedule[days_of_week][1]': res['days_of_week'][1],
               'report_schedule[days_of_week][2]': res['days_of_week'][2],
               'report_schedule[days_of_week][3]': res['days_of_week'][3],
               'report_schedule[days_of_week][4]': res['days_of_week'][4],
               'report_schedule[days_of_week][5]': res['days_of_week'][5],
               'report_schedule[days_of_week][6]': res['days_of_week'][6]};
    this.getComponent('form').getComponent('checkboxgroup').suspendEvents();
    form.setValues(rec);
    this.getComponent('form').getComponent('checkboxgroup').resumeEvents();
  }
});
