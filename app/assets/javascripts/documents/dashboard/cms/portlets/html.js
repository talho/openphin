Ext.namespace('Talho.Dashboard.Portlet');

Talho.Dashboard.Portlet.HTML = Ext.extend(Talho.Dashboard.Portlet, {
  fields: ['data'],

  constructor: function(config) {
    if(config.html) {
      if(config.data === undefined) config.data = {};
      if(config.data.html === undefined) config.data.html = config.html;
      delete config.html;
    }
    
    Talho.Dashboard.Portlet.HTML.superclass.constructor.apply(this, arguments);
  },
  
  initComponent: function() {
    this.tpl = new Ext.XTemplate('<div id="{[Ext.id()]}" class="x-portlet-html">{html}</div>')
    Talho.Dashboard.Portlet.HTML.superclass.initComponent.apply(this, arguments);
  },
  
  showEditWindow: function(){
    var htmleditor = new Ext.form.HtmlEditor({
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

  isModified: function() {
    return this.itemId == undefined || this.initialConfig["column"] != this.column || this.initialConfig["data"]["html"] != this.el.child('.x-portlet-html').dom.innerHTML || this.initialConfig["title"] != this.title
  },

  revert: function() {
    try {
      this.el.child('.x-portlet-html').update(this.initialConfig["data"]["html"]);
      return true;
    } catch(err) {
      return false;
    }
  },

  buildConfig: function() {
    var config = Talho.Dashboard.Portlet.HTML.superclass.buildConfig.call(this);
    config["html"] = this.el.child('.x-portlet-html').dom.innerHTML;
    return config;
  },

  title: 'HTML Portlet'
});

Ext.reg('dashboardhtmlportlet', Talho.Dashboard.Portlet.HTML);
