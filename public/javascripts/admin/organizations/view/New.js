
Ext.ns('Talho.Admin.Organizations.view');

Talho.Admin.Organizations.view.New = Ext.extend(Ext.Panel, {
  initComponent: function(){
    this.setTitle(this.org_id ? 'Edit Organization' : 'New Organization');
    
    Talho.Admin.Organizations.view.New.superclass.initComponent.apply(this, arguments);
  },
  html: 'New Org',
  border: false,
  header: false
});
