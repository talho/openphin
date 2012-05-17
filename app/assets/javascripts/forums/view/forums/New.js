Ext.ns("Talho.Forums.view.Forums");

Talho.Forums.view.Forums.New = Ext.extend(Ext.form.FormPanel, {
  layout: 'hbox',
  height: 450,
  layoutConfig: {
    align: 'stretchmax'
  },
  constructor: function(config){
    this.addEvents('cancel','savecomplete');
    config.editMode = Ext.isNumber(config.forumId);
    config.url = String.format('/forums{0}.json', config.editMode ? '/' + config.forumId : '');
    config.method = config.editMode ? 'PUT' : 'POST';
    config.waitMsgTarget = true;
    
    Talho.Forums.view.Forums.New.superclass.constructor.apply(this, arguments);
  },
  initComponent: function(){
    this.setTitle(this.editMode ? 'Edit Forum' : 'New Forum');
    this.items = [
      {xtype: 'container', itemId: 'container', width: 350, layout: 'form', defaults: {anchor: '100%'}, items: [
        {xtype: 'textfield', fieldLabel: 'Forum Name', name:'forum[name]', allowBlank: false},
        {xtype: 'checkbox', itemId: 'hidden_checkbox', boxLabel: 'Hidden'}
      ]},
      {xtype: 'audiencepanel', itemId: 'audience_panel', flex: 1, height: 400, margins: '0 0 0 10px', showGroups: true}
    ];
    
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
          if (action.response && action.response.responseText) {
            var errors = {},
              res = Ext.decode(action.response.responseText);
            for (var k in res.errors){
              errors['forum[' + k + ']'] = res.erorrs[k];
            }
            form.markInvalid(errors);
          }
        }
      });}},
      {text: 'Cancel', scope: this, handler: function(){ this.fireEvent('cancel');}}
    ];
    
    Talho.Forums.view.Forums.New.superclass.initComponent.apply(this, arguments);
    
    this.on('afterrender', function(){
      var f = this.getForm();
      f.load({
        url: String.format('/forums/{0}.json', this.editMode ? this.forumId + '/edit': 'new'),
        method: 'GET',
        success: function(form, action) {          
          var data = action.result.data;
          for (var k in data) {
            data['forum[' + k + ']'] = data[k];          
          }
          this.getForm().setValues(data);
          if (data.hide)
          {
            this.getComponent('container').getComponent('hidden_checkbox').setValue(true);            
          }
          if (data.audience)
          {
            var audiencePanel = this.getComponent('audience_panel');
            audiencePanel.load(data.audience.jurisdictions || [], data.audience.roles || [], data.audience.users || []);
            audiencePanel.audienceId = data.audience.id;
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
      var parentId = this.parentId;
      var hidden = (this.getComponent('container').getComponent('hidden_checkbox').getValue() ? "1" : "0");
  
      action.options.params = {
        'forum[parent_id]': parentId,
        'forum[hide]': hidden,       
        'forum[audience_attributes][jurisdiction_ids][]': audienceIds.jurisdiction_ids,
        'forum[audience_attributes][role_ids][]': audienceIds.role_ids,
        'forum[audience_attributes][user_ids][]': audienceIds.user_ids,
        'forum[audience_attributes][id]': audiencePanel.audienceId
      }
    }
  },
  border: false,
  header: false
});
