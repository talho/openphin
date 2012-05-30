Ext.ns("Talho.Forums.view.Topics");

Talho.Forums.view.Topics.Edit = Ext.extend(Ext.form.FormPanel, {
  labelAlign: 'top',  
  height : 400,
  constructor : function(config) {
    this.addEvents('cancel, savecomplete');
    config.url = String.format('/forums/{0}/topics/{1}.json', config.forumId, config.topicId);
    config.method = 'PUT'
    config.waitMsgTarget = true;
    
    Talho.Forums.view.Topics.Edit.superclass.constructor.apply(this, arguments);    
  },
  initComponent : function() {
    this.setTitle('Move Topic');
    
    this.items = [];
    
    this.items.push(      
      {xtype: 'combo', name: 'forumMover', id: 'newForum', mode: 'local', forceSelection: true,
      fieldLabel: String.format('Move topic "{0}" from "{1}" to ', this.topicName, this.forumName),
      triggerAction: 'query',
      store: new Ext.data.JsonStore({
        url: '/forums.json',
        restful: true,
        autoLoad: true,
        root: 'forums',
        fields: ['name', 'id']
      }),
      displayField: 'name', valueField: 'id'
      }
    );
    
    this.listeners = {
      scope: this,
      'beforeaction': this.beforeSubmit
    }
    
    this.buttons = [
      '->',
      {text: 'Save', scope: this, handler: function(){this.getForm().submit({
        waitMsg: 'Saving...',
        scope: this,
        success: function(){this.fireEvent('savecomplete');},
        failure: function(form, action) {
          alert('Move Failed');
        }
      });}},
      {text: 'Cancel', scope: this, handler: function(){ this.fireEvent('cancel');}}
    ];
    
    Talho.Forums.view.Topics.Edit.superclass.initComponent.apply(this, arguments);
  },
  beforeSubmit: function(form, action){
    if(action.type == 'submit'){
      var newForumId = Ext.getCmp('newForum').getValue();          
  
      action.options.params = {
        'topic[dest_forum_id]': newForumId
      }
    }
  },
  border : false,  
  header : false
}); 