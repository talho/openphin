Ext.namespace('Talho.Dashboard.Portlet');

Talho.Dashboard.Portlet = Ext.extend(Ext.ux.Portlet, {
  // Used to restrict which properties can be used when creating a portlet from the json data
  fields: ['title', 'column', 'itemId', 'xtype'],

  constructor: function(config) {
    var approvedConfig = {},
        superclass = this.constructor.superclass;
    while(superclass && superclass.fields){
      this.fields = Ext.unique(this.fields.concat(superclass.fields || []));
      superclass = superclass.constructor.superclass;
    }
    Ext.copyTo(approvedConfig, config, this.fields);
    Talho.Dashboard.Portlet.superclass.constructor.call(this, approvedConfig);
  },

  initComponent: function(config) {
    this.tools = this.tools || [];
    this.tools.push({ id:'gear', qtip: 'Edit', handler: this.showEditWindow, scope: this});
    this.tools.push({ id:'close', handler: function(e, target, panel){ panel.ownerCt.remove(panel, true); } });
    Ext.ux.Portlet.superclass.initComponent.call(this);
    this.on('afterrender', function(){
      this.dd.lock();
    }, this);
  },
  
  showEditWindow: function(){
    
  },
  
  isModified: function() {
    return true;
  },

  revert: function() {
    return false;
  },

  buildConfig: function() {
    var conf = {};
    Ext.copyTo(conf, this, this.fields);
    return conf;
  },

  border: true,
  header: true,
  frame: true,
  collapsible: false,
  cls: 'portlet user-mode',
  
  toggleAdminBorder: function(){
      this.getEl().toggleClass('user-mode').toggleClass('admin-mode');
      if(this.dd.locked){
        this.dd.unlock();
      }
      else{
        this.dd.lock();
      }
  }
});

Ext.reg('dashboardportlet', Talho.Dashboard.Portlet);
