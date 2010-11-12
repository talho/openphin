Ext.ns("Talho");

Talho.InviteUsers = Ext.extend(Talho.InviteUsersBase, {
  constructor: function(config){
    var Invitee = Ext.data.Record.create([{
      name: 'name',
      type: 'string'
    },{
      name: 'email',
      type: 'string'
    }]);

    var store = new Ext.data.GroupingStore({
      fields: ['name','email'],
      reader: new Ext.data.JsonReader({fields: Invitee, root: 'invitees_attributes'}),
      data: {'invitees_attributes': []},
      sortInfo: {field: 'name', direction: 'ASC'}
    });

    var editor = new Ext.ux.grid.RowEditor({
      saveText: 'Update'
    });

    editor.on('afterEdit', function() {
      if(store.getCount() == 0) {
        Ext.getCmp('invitation_submit').disable();
      } else {
        Ext.getCmp('invitation_submit').enable();
      }
    }, this, {delay: 10});

    editor.on('cancelEdit', function() {
      if(store.getCount() == 0) {
        Ext.getCmp('invitation_submit').disable();
      } else {
        Ext.getCmp('invitation_submit').enable();
      }
    }, this, {delay: 10});

    var myMask = new Ext.LoadMask(Ext.getBody(), {msg:"Uploading file.  Please wait..."});

    this.uploadButton = new Ext.ux.form.FileUploadField({
      name: 'invitation[csvfile]',
      itemId: 'myfileuploadfield',
      buttonOnly: true,
      iconCls: 'icon-file-upload',
      buttonText: 'Import Users',
      listeners: {
        scope: this,
        'fileselected': function(fb, v) {
          myMask.show();
          this.uploadForm.submit({
            scope: grid,
            success: function(form, action) {
              this.store.loadData(Ext.decode(action.response.responseText), !Ext.getCmp('chk-overwrite').checked);
              if(this.store.getCount() == 0) {
                Ext.getCmp('invitation_submit').disable();
              } else {
                Ext.getCmp('invitation_submit').enable();
              }
              form.reset();
              myMask.hide();
            },
            failure: function(form, action) {
              myMask.hide();
              data = Ext.decode(action.response.responseText);
              Ext.Msg.alert('Import Error', data['error']);
            }
          });
        }
      }
    });

    var grid = new Ext.grid.GridPanel({
      store: store,
      margins: '0 5 5 5',
      plugins: [editor],
      stripeRows: true,
      title: 'Send Invitation to the specified users',
      view: new Ext.grid.GroupingView({
        markDirty: false,
        forceFit: true
      }),
      tbar: [{
        iconCls: 'icon-user-add',
        text: 'Add User',
        handler: function(){
          var u = new Invitee({
            name: '',
            email: ''
          });
          if(store.getCount() == 0 || (store.getCount() > 0 && editor.isValid())) {
            editor.stopEditing();
            store.insert(0, u);
            grid.getView().refresh();
            grid.getSelectionModel().selectRow(0);
            editor.startEditing(0);
          }
        }
      },{
        ref: '../removeBtn',
        iconCls: 'icon-user-delete',
        text: 'Remove User',
        disabled: true,
        handler: function(){
          editor.stopEditing();
          var s = grid.getSelectionModel().getSelections();
          store.remove(s);
          if(store.getCount() == 0) {
            Ext.getCmp('invitation_submit').disable();
          } else {
            Ext.getCmp('invitation_submit').enable();
          }
        }
      },'->',{
        itemId: 'testForm',
        xtype: 'container',
        autoEl: 'form',
        items: [this.uploadButton]
      },{
        xtype: 'checkbox',
        id: 'chk-overwrite',
        boxLabel: 'Overwrite?',
        checked: true,
        submitValue: false
      }],
      columns: [{
        header: 'Full Name',
        dataIndex: 'name',
        sortable: true,
        editor: {
          xtype: 'textfield',
          allowBlank: false
        }
      },{
        id: 'email',
        header: 'Email',
        dataIndex: 'email',
        sortable: true,
        editor: {
          xtype: 'textfield',
          allowBlank: false,
          vtype: 'email'
        }
      }]
    });

    grid.on('afterrender', function(){
      this.uploadForm = new Ext.form.BasicForm(grid.getTopToolbar().getComponent('testForm').getEl(),{
        url: this.url + '/import.html',
        baseParams: {'authenticity_token': FORM_AUTH_TOKEN},
        fileUpload: true
      });
      this.uploadForm.add(grid.getTopToolbar().getComponent('testForm').getComponent('myfileuploadfield'));
    }, this, {delay: 10});

    grid.getSelectionModel().on('selectionchange', function(sm){
      grid.removeBtn.setDisabled(sm.getCount() < 1);
    });

    var topCardNav = function(incr){
      var l = Ext.getCmp('card-wizard-panel').getLayout();
      var i = l.activeItem.id.split('card-')[1];
      var next = parseInt(i, 10) + incr;
      if(this.getPanel().form.isValid()) {
        l.setActiveItem(next);
        Ext.getCmp('top-card-prev').setDisabled(next==0);
        Ext.getCmp('top-card-next').setDisabled(next==1);
        Ext.getCmp('bottom-card-prev').setDisabled(next==0);
        Ext.getCmp('bottom-card-next').setDisabled(next==1);
      } else {
        this.getPanel().form.items.each(function() {
          this.validate();
        })
      }
    };

    var bottomCardNav = function(incr){
      var l = Ext.getCmp('card-wizard-panel').getLayout();
      var i = l.activeItem.id.split('card-')[1];
      var next = parseInt(i, 10) + incr;
      if(this.getPanel().form.isValid()) {
        l.setActiveItem(next);
        Ext.getCmp('top-card-prev').setDisabled(next==0);
        Ext.getCmp('top-card-next').setDisabled(next==1);
        Ext.getCmp('bottom-card-prev').setDisabled(next==0);
        Ext.getCmp('bottom-card-next').setDisabled(next==1);
      } else {
        this.getPanel().form.items.each(function() {
          this.validate();
        })
      }    };

    var item_list = [{
      id: 'card-wizard-panel',
      layout: 'card',
      defaults: { border: true, height: 470 },
      autoHeight: true,
      autoWidth: true,
      activeItem: 0,
      tbar: [{
        id: 'top-card-prev',
        scale: 'medium',
        enableToggle: true,
        allowDepress: false,
        pressed: true,
        style: { marginLeft: '5px', marginRight: '5px' },
        text: '&laquo; Previous',
        handler: topCardNav.createDelegate(this, [-1]),
        disabled: true
      },'->',{
        id: 'top-card-next',
        scale: 'medium',
        enableToggle: true,
        allowDepress: false,
        pressed: true,
        text: 'Next &raquo;',
        handler: topCardNav.createDelegate(this, [1])
      }],
      bbar: [{
        id: 'bottom-card-prev',
        scale: 'medium',
        enableToggle: true,
        allowDepress: false,
        pressed: true,
        text: '&laquo; Previous',
        handler: bottomCardNav.createDelegate(this, [-1]),
        disabled: true
      },'->',{
        id: 'bottom-card-next',
        scale: 'medium',
        enableToggle: true,
        allowDepress: false,
        pressed: true,
        text: 'Next &raquo;',
        handler: bottomCardNav.createDelegate(this, [1])
      }],
      items: [{
        id: 'card-0',
        xtype: 'container',
        layout: 'form',
        labelAlign: 'top',
        autoHeight: true,
        autoWidth: true,
        items: [
          {xtype: 'textfield', fieldLabel: 'Invitation Name', name: 'invitation[name]', maxLength: '46', width: 550, allowBlank: false},
          {xtype: 'textfield', fieldLabel: 'Email Subject', name: 'invitation[subject]', maxLength: '46', width: 550, allowBlank: false},
          {xtype: 'htmleditor', fieldLabel: 'Email Body', name: 'invitation[body]', allowBlank: false, width: 550, height: 300, enableSourceEdit: false},
          {xtype: 'combo', fieldLabel: 'Default Organization', emptyText: 'Select an Organization...', typeAhead: false, triggerAction: 'all', lazyRender: true,
            name: 'invitation[organization_id]', allowBlank: true, editable: false, mode: 'local', valueField: 'organization_id', displayField: 'name',
            forceSelection: true, store: new Ext.data.ArrayStore({fields: ['organization_id','name'],data: [[1, 'TALHO'], [2, 'DSHS']]})},
        ]
      },{
        id: 'card-1',
        xtype: 'container',
        layout: 'fit',
        items: [grid]
      }]
    }];

    this.form_config = {
      form_width: 700,
      item_list: item_list,
      save_url: config.url + ".json",
      save_method: "POST"
    };

    Talho.InviteUsers.superclass.constructor.call(this, config);

    this.getPanel().getForm().on('beforeaction', function(form, action) {
      action.options.params = {}
      store.each(function(item, index){
        action.options.params['invitation[invitees_attributes][' + index + '][name]'] = item.data['name']
        action.options.params['invitation[invitees_attributes][' + index + '][email]'] = item.data['email']
      });
      return true;
    }, this);
  }
});

Talho.InviteUsers.initialize = function(config){
  var o = new Talho.InviteUsers(config);
  return o.getPanel();
};

Talho.ScriptManager.reg('Talho.InviteUsers', Talho.InviteUsers, Talho.InviteUsers.initialize);
