Ext.namespace('Talho');
Ext.namespace('Talho.Dashboard');
Ext.namespace('Talho.Dashboard.Portlet');

Talho.Dashboard.Portlet.HTML = Ext.extend(Talho.Dashboard.Portlet, {
  fields: {
    //border: true,
    column: true,
    data: true,
    //headerCssClass: true,
    itemId: true,
    //ownerCt: true,
    xtype: true
  },

  constructor: function(config) {
    if(config.html) {
      if(config.data === undefined) config.data = {};
      if(config.data.html === undefined) config.data.html = config.html;
      delete config.html;
    }

    this.tools.unshift({
      id:'gear',
      qtip: 'Edit',
      handler: function(event, toolEl, panel, tc){
        var htmleditor = new Ext.form.HtmlEditor({
          html: panel.el.child('.x-portlet-html').dom.innerHTML,
          enableSourceEdit: true,
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
    });
    

    Ext.apply(this, config);
    Talho.Dashboard.Portlet.HTML.superclass.constructor.call(this);

    this.initialConfig = config;
  },
  
  initComponent: function(config) {
    Ext.apply(this, config);
    this.tpl = new Ext.XTemplate('<div id="{[Ext.id()]}" class="x-portlet-html">{html}</div>')
    Talho.Dashboard.Portlet.HTML.superclass.initComponent.call(this, config);
  },

  isModified: function() {
    return this.itemId == undefined || this.initialConfig["column"] != this.column || this.initialConfig["data"]["html"] != this.el.child('.x-portlet-html').dom.innerHTML
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
    var config = {};
    config["column"] = this.column;
    config["xtype"] = "dashboardhtmlportlet";
    config["itemId"] = this.itemId;
    config["html"] = this.el.child('.x-portlet-html').dom.innerHTML;
    return config;
  },

  title: 'HTML Portlet'
});

Ext.reg('dashboardhtmlportlet', Talho.Dashboard.Portlet.HTML);
