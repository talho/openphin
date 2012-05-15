Ext.ns("Talho.Forums.view.Forums.Edit");

Talho.Forums.view.Forums.Edit = Ext.extend(Ext.FormPanel, {
  layout : 'hbox',
  autoWidth: true,
  height : 450,
  constructor : function(config) {
    this.addEvents('cancel', 'savecomplete');
    config.url = String.format('/forums/{0}.json', config.forumId);
    config.method = 'PUT';
    config.waitMsgTarget = true;
    
    Talho.Forums.view.Forums.Edit.superclass.constructor.apply(this, arguments);
  },
  initComponent : function() {
    this.setTitle(String.format('Manage Moderators'));
    
    this.items = [];
    
    this.items.push(      
      {xtype: 'audiencepanel', title: 'Moderators', itemId: 'audience_panel', flex: 1, height: 400, margins: '0 0 0 10px'}
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
      })}},
      {text: 'Cancel', scope: this, handler: function(){ this.fireEvent('cancel');}}
    ]
    
    Talho.Forums.view.Forums.Edit.superclass.initComponent.apply(this, arguments);
    
    this.on('afterrender', function(){
      var f = this.getForm();
      f.load({
        url: String.format('/forums/{0}/edit.json', this.forumId),
        method: 'GET',
        success: function(form, action) {          
          var data = action.result.data;
          if (data.moderator_audience)
          {
            var audiencePanel = this.getComponent('audience_panel');
            audiencePanel.load(data.moderator_audience.jurisdictions || [], data.moderator_audience.roles || [], data.moderator_audience.users || []);
            audiencePanel.audienceId = data.moderator_audience.id;
          }
        },
        scope: this
      });
    }, this, {delay:1});
  },
  
  beforeSubmit: function(form, action){
    if(action.type == 'submit'){
      var audiencePanel = this.getComponent('audience_panel'); 
      var audienceIds = audiencePanel.getSelectedIds();
  
      action.options.params = {
        'forum[moderator_audience_attributes][jurisdiction_ids][]': audienceIds.jurisdiction_ids,
        'forum[moderator_audience_attributes][role_ids][]': audienceIds.role_ids,
        'forum[moderator_audience_attributes][user_ids][]': audienceIds.user_ids,
        'forum[moderator_audience_attributes][id]': audiencePanel.audienceId
      }
    }
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