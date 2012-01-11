Ext.namespace('Talho');

Talho.ReportView = Ext.extend(Ext.util.Observable, {
  constructor: function(config) {
    Ext.apply(this, config);

    this.sidebarPanel = new Ext.FormPanel({
      layout: 'form',
      border: false,
      padding: 10,
      listeners: {scope: this, 'render': function(panel){this.addFilters(panel);}}
    });

    this.generateReportButton = new Ext.Button({
        text: 'Generate Filtered Report', scope: this,
        handler: function(){
          this.updateReportView()},
        disabled: true
    });

    this.filterSidebar = new Ext.Panel({
      region: 'west',
      width: 300,
      border: false,
      fill: true,
      margins: '5 5 5 5',
	  layout: 'fit',
	  items: [this.sidebarPanel],
      buttonAlign : 'center',
      buttons: [this.generateReportButton ]
    });

	this.reportViewContainer = new Ext.Panel({
	  region: 'center',
      frame: false,
      layout: 'fit',
      border: true,
      bodyBorder: false,
      margins: '5 5 5 0',
      padding: '0',
      items: {
        autoLoad:{
          url: this.url,
          scope: this,
          callback: function(ele,success,response,options){
            if (!success && response.status != 0) {this.show_err_message(response, this.primary_panel)}
          }
      }},
      tbar: new Ext.Toolbar( { items: [
        {xtype: 'button', text: 'Copy', iconCls: 'reportFile', scope: this, handler: function(){ this.copy_report(); } }
      ] } )
	});

    this.primary_panel = new Ext.Panel({
      layout:'border',
      itemId: this.id,
      closable: true,
      title: this.title,
      items: [this.filterSidebar, this.reportViewContainer]
    });

    this.getPanel = function(){ return this.primary_panel; };

    this.addFilters = function(panel){
      Ext.Ajax.request({
        // GET /report/reports/:id/filters(.:format)
        url: this.url +'/filters.json', method: 'GET', scope: panel,
        success: function(response){
          this.removeAll();
          var filtersObj = Ext.decode(response.responseText);
          var filters = [];
          for (var i = 0; i < filtersObj.filters.length; i++) {
            var filter = filtersObj.filters[i];
            switch (filter.type) {
              case "Boolean": filters.push( new Ext.form.Checkbox(filter) ); break;
              case "Time","Fixnum": filters.push( new Ext.ux.SliderWithTip(filter) ); break;
              case "String": filters.push( new Ext.form.ComboBox(filter) ); break;
            }
          }
          if ( filters.length > 0 ) {
            this.add(filters);
            this.ownerCt.buttons[0].enable();
            this.doLayout();
          }
        },
        failure: function(){ this.mask("Server error.  Please try again.");  }
      });
    };

  },

  copy_report: function(){
    var win = new Ext.Window({
      title: "Copy To Documents",
      padding: '10',
      width: 450,
      modal: true,
      items: [
        {xtype: 'form',
        itemId: 'format-form',
        items: [
            {xtype: 'radio', boxLabel: 'HTML Copy', name: 'document_format', inputValue: 'HTML', checked: true, hideLabel: true},
            {xtype: 'radio', boxLabel: 'PDF Copy', name: 'document_format', inputValue: 'PDF', hideLabel: true},
            {xtype: 'radio', boxLabel: 'CSV Copy', name: 'document_format', inputValue: 'CSV', hideLabel: true}
        ]},
        {xtype: 'displayfield', itemId: 'document-display', value: ''}
      ],
      buttons: [
        {text: 'Copy', itemId: 'ok-to-copy', scope: this, width:'auto',
          handler: function(){
            var form = win.getComponent('format-form').getForm();
            var document_format = form.getValues()['document_format'];
            form.submit({
              url: '/report/reports.json',
              method: 'POST',
              scope: this,
              waitMsg: 'Copy is being scheduled...',
              params: { 'document_format': document_format, 'report_url': this.url },
              success: function(form,responseObj){
                var footer = win.getFooterToolbar();
                footer.getComponent('ok-to-copy').hide();
                footer.getComponent('cancel').setText('OK');
                var response = Ext.decode(responseObj.response.responseText);
                win.getComponent('document-display').setValue(this.report_msg(response.report.file['name']));
              },
              failure: function(form,responseObj){}
            });
          }
        },
        {text: 'Cancel', itemId: 'cancel', scope: this, width:'auto', handler: function(){ win.close(); } }
      ]
    });
    win.show();
  },

  report_msg: function(report_name, opts) {
    return '<br>Copying of <b>' + report_name + '</b><br><br>' +
      '<div style="height:40px;">' + 'has been scheduled. Please check your Reports document folder for this file.' + '<\div>';
  },

  show_err_message: function(response, panel_to_destroy) {
    var msg = '<b>Status: ' + response.status + ' => ' + response.statusText + '</b><br><br>' +
      '<div style="height:200px;overflow:scroll;">' + (Ext.decode(response.responseText)).error +
            '. Consider regenerating the report.' + '<\div>';
    Ext.Msg.show({title: 'Error', msg: msg, minWidth: 600, maxWidth: 600, buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR});
    if (panel_to_destroy) {panel_to_destroy.destroy();}
  },

  updateReportView: function() {
    var params1 = [];
    var params = this.sidebarPanel.getForm().getFieldValues();
    for(var i in params){
      var param = {};
      if (params[i].length > 0) {
        param[i] = params[i];
        params1[params1.length] = param;
      }
    }
    params = this.sidebarPanel.findByType("reportsliderwithtip");
    for (var j = 0, max = params.length; j < max; j += 1) {
      param = {};
      var min_max = params[j].getValues();
      param[params[j]["name"]] = {"minValue": min_max[0],"maxValue": min_max[1]};
      params1.push(param);
    }
    Ext.Ajax.request({
      // POST /report/reports/:id/reduce(.:format)
      url: this.url + '/reduce.json',
      method: 'POST',
      params: {filters: Ext.encode(params1)},
      scope: this,
      success: function(responseObj){
        var filtered_at = Ext.decode(responseObj["responseText"])["filtered_at"];
        this.reportViewContainer.getUpdater().update({url: this.url, method: 'GET', params: {filtered_at: filtered_at}});
      },
      failure: function(response){
        this.mask("Server error.  Please try again."); }
    })
  }
});

Ext.ux.SliderWithTip = Ext.extend(Ext.slider.MultiSlider, {
   initComponent: function(){
     this.autoHeight = true;
     this.plugins = new Ext.slider.Tip();
     this.listeners = {
       'change': function(slider){updateSliderLabel(slider);},
       'afterrender': function(slider){updateSliderLabel(slider);}
     };
     Ext.ux.SliderWithTip.superclass.initComponent.apply(this, arguments);
   }
});
Ext.reg('reportsliderwithtip', Ext.ux.SliderWithTip);

var updateSliderLabel = function(slider){
  var baseLabel = slider.label.dom.innerHTML.split(":");
  var sliderVals = slider.getValues();
  slider.label.update(baseLabel[0] + ': <br>(' + sliderVals[0] + ' - ' + sliderVals[1] + ')');
};

Talho.ReportView.initialize = function(config){
  var reportPanel = new Talho.ReportView(config);
  return reportPanel.getPanel();
};

Talho.ScriptManager.reg('Talho.ReportView', Talho.ReportView, Talho.ReportView.initialize);

