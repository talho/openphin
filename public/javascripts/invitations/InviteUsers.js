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
      reader: new Ext.data.JsonReader({fields: Invitee, root: 'root'}),
      data: {root: []},
      sortInfo: {field: 'name', direction: 'ASC'}
    });

    var editor = new Ext.ux.grid.RowEditor({
      saveText: 'Update'
    });

    this.uploadButton = new Ext.ux.form.FileUploadField({
      name: 'invitation[csvfile]',
      itemId: 'myfileuploadfield',
      buttonOnly: true,
      iconCls: 'icon-file-upload',
      buttonText: 'Import Users',
      listeners: {
        scope: this,
        'fileselected': function(fb, v) {
          this.uploadForm.submit({
            scope: grid,
            success: function(form, action) {
              this.store.loadData(Ext.decode(action.response.responseText), false);
              form.reset();
            },
            failure: function(form, action) {
              data = Ext.decode(action.response.responseText)
              Ext.Msg.alert('Import Error', data['error'] + "<br/><br/>" + data['exception']);
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
        }
      },'->',{
        itemId: 'testForm',
        xtype: 'container',
        autoEl: 'form',
        items: [this.uploadButton]
      },{
        xtype: 'checkbox',
        boxLabel: 'Overwrite?',
        checked: true
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
        url: '/admin_invitations/import.html',
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
      l.setActiveItem(next);
      Ext.getCmp('top-card-prev').setDisabled(next==0);
      Ext.getCmp('top-card-next').setDisabled(next==1);
      Ext.getCmp('bottom-card-prev').setDisabled(next==0);
      Ext.getCmp('bottom-card-next').setDisabled(next==1);
    };

    var bottomCardNav = function(incr){
      var l = Ext.getCmp('card-wizard-panel').getLayout();
      var i = l.activeItem.id.split('card-')[1];
      var next = parseInt(i, 10) + incr;
      l.setActiveItem(next);
      Ext.getCmp('top-card-prev').setDisabled(next==0);
      Ext.getCmp('top-card-next').setDisabled(next==1);
      Ext.getCmp('bottom-card-prev').setDisabled(next==0);
      Ext.getCmp('bottom-card-next').setDisabled(next==1);
    };

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
            name: 'invitation[organization_id]', allowBlank: true, mode: 'local', valueField: 'organization_id', displayField: 'name', forceSelection: true,
            store: new Ext.data.ArrayStore({fields: ['organization_id','name'],data: [[1, 'TALHO'], [2, 'DSHS']]})}
        ]
      },{
        id: 'card-1',
        xtype: 'container',
        layout: 'fit',
        items: [grid]
      }]
    }];
    this.form_config = {
      //load_url: config.url + "/new.json",
      form_width: 700,
      item_list: item_list,
      save_url: config.url + ".json",
      save_method: "PUT"
    };

    Talho.InviteUsers.superclass.constructor.call(this, config);
  }
});

Talho.InviteUsers.initialize = function(config){
  var o = new Talho.InviteUsers(config);
  return o.getPanel();
};

Talho.ScriptManager.reg('Talho.InviteUsers', Talho.InviteUsers, Talho.InviteUsers.initialize);
