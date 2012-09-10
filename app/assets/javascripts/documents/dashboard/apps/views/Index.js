
Ext.ns('Talho.Dashboard.Apps.view');

Talho.Dashboard.Apps.view.Index = Ext.extend(Ext.Panel, {
  title: 'Add Apps',
  layout: 'border',
  closable: true,
  constrcutor: function(){
    Talho.Dashboard.Apps.view.Index.superclass.constructor.apply(this, arguments);
    this.addEvents('addapp');
  },
  initComponent: function(){
    this.items = [
      { xtype: 'container', itemId: 'msgCont', cls: 't_boot', autoHeight: true, region: 'north', items: {
          xtype: 'box', itemId: 'msg', html: '<h5>Info:</h5><p>On the left are the apps that you already have access to. On the right are apps that you may add.<br/>Note: for most ' + 
                                             'apps, to gain access to additonal features, you will need to request a non-public role via the edit user menu.</p>', 
          cls: 'alert-message notice', width: 500, style: 'margin: 10px auto'} },
      { xtype: 'container', region: 'center', closable: true, itemId: 'container', layout: 'hbox',
        layoutConfig: { defaultMargins: '5 20 0 0', pack: 'center' },
        items: [
          {xtype: 'grid', width: 400, height: 300, title: 'My Apps', itemId: 'myapps', cls: 'my-apps-grid', loadMask: true, store: new Ext.data.JsonStore({
            fields: ['name', 'id'],
            url: '/apps.json',
            restful: true,
            autoDestroy: true,
            autoLoad: true
          }), columns: [
            {header: 'Name', dataIndex: 'name', id: 'name'}
          ], autoExpandColumn: 'name'},
          {xtype: 'grid', width: 400, height: 337, title: 'New Apps', itemId: 'allapps', cls: 'new-apps-grid', loadMask: true, store: new Ext.data.JsonStore({
            fields: ['name', 'id'],
            url: '/apps/available.json',
            restful: true,
            autoDestroy: true,
            autoLoad: true
          }), columns: [
            {header: 'Name', dataIndex: 'name', id: 'name'}
          ], autoExpandColumn: 'name', buttons: [
            {text: 'Refresh', scope: this, handler: this.refreshGrids},
            {text: 'Add Selected App', disabled: true, scope: this, handler: function(){ this.fireEvent('addapp', this.getComponent('container').getComponent('allapps').getSelectionModel().getSelected() ); } }
          ], sm: new Ext.grid.RowSelectionModel({singleSelect: true, listeners: {
            scope: this,
            'rowselect': this._row_select,
            'rowdeselect': this._row_deselect
          }})}
      ]}
    ]; 
    
    Talho.Dashboard.Apps.view.Index.superclass.initComponent.apply(this, arguments);
  },
  
  refreshGrids: function(){
    var cont = this.getComponent('container');
    cont.getComponent('myapps').getStore().load();
    cont.getComponent('allapps').getStore().load();
  },
  
  _row_select: function(){
    this.getComponent('container').getComponent('allapps').buttons[1].enable();
  },
  
  _row_deselect: function(){
    this.getComponent('container').getComponent('allapps').buttons[1].disable();
  },
  
  setMessage: function(msg){
    if(!this.message){
      this.message = this.getComponent('msgCont').getComponent('msg');
    }
    
    this.message.update(msg);
    this.doLayout();
    
    return this.message; 
  },
  
  setMessageClass: function(cls){
    if(this.message){
      this.message.removeClass('notice').removeClass('success').removeClass('error').addClass(cls);
    }
  },
  
  showSuccess: function(app){
    var msg = this.setMessage('<h5>Success!</h5><p>You have successfully added the app ' + app.get('name') + '.<br/>Note: most apps require additional roles ' +
                              'to enable their features. You can request those roles under your account menu.</p>');                           
    this.setMessageClass('success');                            
  },
  
  showFailure: function(){    
    var msg = this.setMessage('<h5>Error:</h5><p>There was an issue adding that app. Please try again.</p>');                       
    this.setMessageClass('error'); 
  }
});