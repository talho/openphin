Ext.namespace('Talho');

Talho.ReportView = Ext.extend(Ext.util.Observable, {
  constructor: function(config) {
    Ext.apply(this, config);
    Talho.ReportView.superclass.constructor.call(this, config);
    
    this.createDocument = function(button) {
      Ext.Ajax.request({
         url: '/report/reports.json',
         method: 'POST',
         scope:  this,
         params: { 'document_format': button.text, 'report_url': this.url },
         success: function(){},
         failure: function(){}
      });   
    };

    this.primary_panel = new Ext.Panel({
      title: this.title,
      itemId: this.id,
      closable: true,
      items: [{autoLoad:{url: this.url}}],
      tbar: new Ext.Toolbar( { items: [ 
        {xtype: 'tbtext', text: 'Please place a copy in MyDocuments as: '},
        {xtype: 'button', text: 'HTML', scope: this, handler: function(button,event){ this.createDocument(button); } },
        {xtype: 'button', text: 'PDF', scope: this, handler: function(button,event){ this.createDocument(button); } }
      ] } )
    });

    this.getPanel = function(){ return this.primary_panel; };
  }
  
});

Talho.ReportView.initialize = function(config){
  var reportPanel = new Talho.ReportView(config);
  return reportPanel.getPanel();
};

Talho.ScriptManager.reg('Talho.ReportView', Talho.ReportView, Talho.ReportView.initialize);


