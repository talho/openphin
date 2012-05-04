Ext.ns('Talho.Dashboard.Portlet');

Talho.Dashboard.Portlet.PHIN = Ext.extend(Talho.Dashboard.Portlet.HTML, {
  /**
   * This portlet is intended to be the same as the HTML portlet except instead of creating off-site links,
   * it creates links that launch new tabs within PHIN based on a provided tab config.
   */
  initComponent: function() {
    Talho.Dashboard.Portlet.PHIN.superclass.initComponent.apply(this, arguments);
    // Add handler for link clicks to call the opentab event
    this.on('afterrender', function(){
      Ext.each(this.getEl().query('a'), function(a){
        Ext.get(a).on('click', this.link_clicked, this);
      }, this);
    }, this, {delay: 1}); // delay to allow the system to draw the HTML out
  },
  
  link_clicked: function(e, a){
    Application.fireEvent('opentab', Ext.decode(Ext.get(a).getAttribute('tab')));
  },
  
  showEditWindow: function(){
    var htmleditor = new Talho.ux.PhinHtmlEditor({
      linksInNewWindow: true,
      name: 'htmlportlet',
      region: 'center',
      html: this.getEl().child('.x-portlet-html').dom.innerHTML,
      enableSourceEdit: true
    });

    var win = new Ext.Window({
      layout: 'border',
      width: 680,
      height: 510,
      title: 'Edit HTML Portlet',
      cls: 'html-portlet-window',
      constrain: true,
      modal: true,
      items: [{xtype: 'container', region: 'north', itemId: 'otherFields', layout: 'form', style: {padding: '5px'}, height: 35, items: [
        {xtype: 'textfield', fieldLabel: 'Title', itemId: 'titleField', value: this.title, anchor: '100%'}
      ]}, htmleditor],
      buttons: [{
        text: 'OK',
        scope: this,
        handler: function() {
          this.getEl().child('.x-portlet-html').update(htmleditor.getRawValue());
          this.setTitle(win.getComponent('otherFields').getComponent('titleField').getValue());
          win.close();
        }
      },{
        text: 'Cancel',
        handler: function() {
          win.close();
        }
      }]
    });
    
    win.show();
  },
  
  title: 'PHIN Portlet'
});

Ext.reg('dashboardphinportlet', Talho.Dashboard.Portlet.PHIN);