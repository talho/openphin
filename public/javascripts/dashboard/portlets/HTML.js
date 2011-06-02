Ext.namespace('Talho');
Ext.namespace('Talho.Dashboard');
Ext.namespace('Talho.Dashboard.Portlet');

Talho.Dashboard.Portlet.HTML = Ext.extend(Talho.Dashboard.Portlet, {
  fields: {
    border: true,
    column: true,
    data: true,
    headerCssClass: true,
    ownerCt: true,
    xtype: true
  },

  constructor: function(config) {
    if(config.html) {
      if(config.data === undefined) config.data = {};
      if(config.data.html === undefined) config.data.html = config.html;
      delete config.html;
    }

    Ext.apply(this, config);
    Talho.Dashboard.Portlet.HTML.superclass.constructor.call(this, config);
  },
  
  initComponent: function(config) {
    Ext.apply(this, config);
    this.tpl = new Ext.XTemplate('<div id="{[Ext.id()]}" class="x-portlet-html">{html}</div>')
    Talho.Dashboard.Portlet.HTML.superclass.initComponent.call(this, config);
  },

  title: 'HTML Portlet',
  tools: [{
    id:'gear',
    qtip: 'Edit',
    handler: function(event, toolEl, panel, tc){
      var htmleditor = new Ext.form.HtmlEditor({
        html: panel.el.child('.x-portlet-html').dom.innerHTML,
        enableSourceEdit: false,
        width: 680,
        height: 510
      });

      var window = new Ext.Window({
        layout: 'fit',
        title: 'Edit HTML Porlet',
        constrain: true,
        style: {
          opacity: 100
        },
        headerCfg: {
          style: {
            valign: 'middle',
            padding: 3,
            opacity: 100
          }
        },
        items: [htmleditor],
        buttons: ['->',{
          text: 'OK',
          handler: function() {
            panel.el.child('.x-portlet-html').update(htmleditor.getRawValue());
            window.close();
          }
        },{
          text: 'Cancel',
          handler: function() {
            window.close();
          }
        }],
        tools: [{
          id:'help'
        }]
      });
      window.show();
    }
  },{
    id:'close',
    handler: function(e, target, panel){
      panel.ownerCt.remove(panel, true);
    }
  }]
});

Ext.reg('dashboardhtmlportlet', Talho.Dashboard.Portlet.HTML);