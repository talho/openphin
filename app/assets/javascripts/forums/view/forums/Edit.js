Ext.ns("Talho.Forums.view.Forums.Edit");

Talho.Forums.view.Forums.Edit = Ext.extend(Ext.FormPanel, {
  layout : 'hbox',
  autoWidth: true,
  height : 450,
  constructor : function() {
    this.addEvents('cancel', 'savecomplete');
    Talho.Forums.view.Forums.Edit.superclass.constructor.apply(this, arguments);
  },
  initComponent : function() {
    this.setTitle(String.format('Manage Moderators: {1}', this.forumName));
    
    this.items = [];
    
    this.items.push(      
      {xtype: 'audiencepanel', title: 'Moderators', header: true, headerAsText: true, itemId: 'moderators', flex: 1, height: 400, margins: '0 0 0 10px'}
    );
    
    
    this.buttons = [
      '->',
      {text: 'Save', scope: this, handler: function(){this.getForm().submit({
        waitMsg: 'Saving...',
        scope: this,
        success: function(){this.fireEvent('savecomplete');},
        failure: function(form, action) {
          if (action.response && action.response.responseText) {
            var errors = {},
              res = Ext.decode(action.response.responseText);
            for (var k in res.errors){
              errors['forums[' + k + ']'] = res.erorrs[k];
            }
            form.markInvalid(errors);
          }
        }
      });}},
      {text: 'Cancel', scope: this, handler: function(){ this.fireEvent('cancel');}}
    ]
    
    Talho.Forums.view.Forums.Edit.superclass.initComponent.apply(this, arguments);
    
    //TODO: get moderator and admin info and fill it in
  },
  reload : function() {
    this.getComponent('grid').getStore().load();
  },
  mask : function() {
    this.getComponent('grid').loadMask.show();
  },
  unmask : function() {
    this.getComponent('grid').loadMask.hide();
  },
  border : false,
  header : false
}); 