Ext.ns('Talho.Groups.View')

Talho.Groups.View.CreateEdit = Ext.extend(Ext.Container, {
  layout: 'hbox',
  layoutConfig: {
    pack: 'center'
  },
  autoScroll:true,
  
  initComponent: function() {
    this.addEvents('savecomplete', 'cancel');
    
    var jurisdiction_store = new Ext.data.JsonStore({ restful: true, url: '/jurisdictions/user_alerting', idProperty: 'id', fields: ['name', 'id'], autoLoad: true });

    this.audience_panel = new Ext.ux.AudiencePanel({ anchor: '100%', height: 400, showJurisdictions: true });

    this.create_group_form_panel = new Ext.form.FormPanel({ itemId: 'create_group_form', border:false, method: 'POST', url: '/admin/groups.json', editing: false,
      width: 600, padding: '10 0 0 0', items:[
        { fieldLabel: 'Group Name', itemId: 'group_name', xtype:'textfield', name: 'group[name]' },
        { fieldLabel: 'Scope', itemId: 'group_scope', xtype:'combo', name: 'group[scope]', store:[], 
           forceSelection: true, editable:false, mode: 'local', triggerAction: 'all' },
        { fieldLabel: 'Owner Jurisdiction', itemId: 'group_owner_jurisdiction', xtype: 'combo', hiddenName: 'group[owner_jurisdiction_id]', 
           forceSelection: true, editable:false, store: jurisdiction_store, mode: 'local', valueField: 'id', displayField: 'name', triggerAction: 'all'},
        { items: this.audience_panel, border: false }
      ],
      buttons: [{ xtype: 'button', text: 'Save', scope: this, handler: this.save_click},
        { xtype: 'button', text: 'Cancel', scope: this, handler: function(){this.fireEvent('cancel');} }
      ],
      listeners: {
        scope: this,
        'actioncomplete': this.form_actionComplete,
        'actionfailed': this.form_actionFailed
      }
    });

    this.create_group_form_panel.getForm().on('beforeaction', this.basicForm_beforeAction, this);
    
    this.items = [this.create_group_form_panel];

    this.on('render', this.panel_render, this);
    
    Talho.Groups.View.CreateEdit.superclass.initComponent.apply(this, arguments);
  },
  
  save_click: function() {
    var options = {};

    if(this.create_group_form_panel.editing) {
      options.url = '/admin/groups/' + this.create_group_form_panel.groupId + '.json';
      options.method = 'PUT';
    }

    this.create_group_form_panel.getForm().submit(options);
  },
  
  form_actionComplete: function(form, action) {
    if(action.type == 'submit') {
      this.fireEvent('savecomplete', action.result);
    }
  }, 
  
  form_actionFailed: function(form, action) {
    Ext.Msg.alert('Error', action.response.responseText);
    this.fireEvent('cancel');
  },
  
  basicForm_beforeAction: function(form, action) {
    var audienceIds = this.audience_panel.getSelectedIds();

    action.options.params = {};

    action.options.params['group[jurisdiction_ids][]'] = audienceIds.jurisdiction_ids;
    action.options.params['group[role_ids][]'] = audienceIds.role_ids;
    action.options.params['group[user_ids][]'] = audienceIds.user_ids;

    return true;
  },
  
  panel_render: function(panel) {
    if(this.create_group_form_panel.mask === true)
      var showAfter = true;

    this.create_group_form_panel.mask = new Ext.LoadMask(panel.getEl());
    if(showAfter)
      this.create_group_form_panel.mask.show();
  },
  
  prepareCreate: function(){
    if(this.create_group_form_panel.mask && this.create_group_form_panel.mask.show){
      this.create_group_form_panel.mask.show();
    }
    else {
      this.create_group_form_panel.mask = true;
    }
    Ext.Ajax.request({
      url: '/admin/groups/new.json',
      method: 'GET',
      scope: this,
      success: function(response, options){
        var group_detail = Ext.decode(response.responseText);
        this.create_group_form_panel.getComponent('group_scope').getStore().loadData(group_detail.scopes);
        
        // reset the group form
        this.create_group_form_panel.getForm().reset();
        this.audience_panel.clear();
        var group_lock_version = this.create_group_form_panel.getComponent('group_lock_version');
        if(group_lock_version) {  // Handle adding/removing the group lock version to take care of issue with blank lock version not being able to save on the create new.
            this.create_group_form_panel.remove(group_lock_version);
            this.create_group_form_panel.doLayout();
        }
        
        this.create_group_form_panel.mask.hide();
        this.create_group_form_panel.doLayout();
      }
    });
    this.create_group_form_panel.editing = false;
        
  },
  
  prepareEdit: function(groupId){
    // reset the group form
    this.create_group_form_panel.getForm().reset();
    this.audience_panel.clear();

    // if we passed in a group id, we need to show a mask and load the data for the group of that id into this form
    if(this.create_group_form_panel.mask && this.create_group_form_panel.mask.show){
      this.create_group_form_panel.mask.show();
    }
    else {
      this.create_group_form_panel.mask = true;
    }

    Ext.Ajax.request({
      url: '/admin/groups/' + groupId + '/edit.json',
      method: 'GET',
      success: function(response, options){
        var group_detail = Ext.decode(response.responseText);
        var group = group_detail.group;
        
        this.create_group_form_panel.getComponent('group_scope').getStore().loadData(group_detail.scopes);
        
        // Fill in the field details
        this.create_group_form_panel.groupId = group.id;
        this.create_group_form_panel.getComponent('group_name').setValue(group.name);
        this.create_group_form_panel.getComponent('group_scope').setValue(group.scope);
        if(group.owner_jurisdiction) this.create_group_form_panel.getComponent('group_owner_jurisdiction').setValue(group.owner_jurisdiction.id);
        var group_lock_version = this.create_group_form_panel.getComponent('group_lock_version');
        if(!group_lock_version) // Handle adding/removing the group lock version to take care of issue with blank lock version not being able to save on the create new.
        {
          group_lock_version = this.create_group_form_panel.add({itemId: 'group_lock_version', xtype:'hidden', name: 'group[lock_version]'});
          this.create_group_form_panel.doLayout();
        }
        group_lock_version.setValue(group.lock_version);

        // Pass the audience panel the selected items to initialize selected and initial checked items
        this.audience_panel.load(group.jurisdictions, group.roles, group.users);
        
        this.create_group_form_panel.mask.hide();
        this.create_group_form_panel.doLayout();
      },
      scope: this
    });

    this.create_group_form_panel.editing = true;    
  }
});