Ext.ns('Talho.Dashboard.CMS.Views');

Talho.Dashboard.CMS.Views.NewDashboardWindow = Ext.extend(Ext.Window, {
  width: 300,
  height: 100,
  layout: 'form',
  title: 'Create New Dashboard',
  modal: true,
  initComponent: function(){
    this.items = [
      {xtype: 'textfield', itemId: 'name', fieldLabel: 'Dashboard Name', anchor: '100%', allowBlank: false }
    ];
    
    this.buttons = [
      {text: 'Create', scope: this, handler: function(){
        var name = this.getComponent('name');
        if(name.validate()){
          this.fireEvent('new', name.getValue());
          this.close();
        } 
      } },
      {text: 'Cancel', scope: this, handler: function(){this.close();}}
    ]
    
    Talho.Dashboard.CMS.Views.NewDashboardWindow.superclass.initComponent.call(this);
  }
});
