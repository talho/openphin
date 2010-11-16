Ext.ns("Talho");

Talho.BatchUsers = Ext.extend(Talho.ProfileBase, {
  constructor: function(config){
    var User = Ext.data.Record.create([
      {name: 'lastname', type: 'string'},
      {name: 'firstname', type: 'string'},
      {name: 'displayname', type: 'string'},
      {name: 'jurisdiction', type: 'string'},
      {name: 'mobile', type: 'string'},
      {name: 'fax', type: 'string'},
      {name: 'phone', type: 'string'},
      {name: 'email', type: 'string'}
    ]);

    this.store = new Ext.data.GroupingStore({
      fields: ['lastname','firstname','displayname','jurisdiction','mobile','fax','phone','email'],
      reader: new Ext.data.JsonReader({fields: User, root: 'users_attributes'}),
      data: {'users_attributes': []},
      sortInfo: {field: 'lastname', direction: 'ASC'}
    });

    var editor = new Ext.ux.grid.RowEditor({
      saveText: 'Update'
    });
    editor.on('afterEdit', this.set_savebutton_state, this, {delay: 10});
    editor.on('cancelEdit', this.set_savebutton_state, this, {delay: 10});

    this.uploadButton = new Ext.ux.form.FileUploadField({
      name: 'users[csvfile]',
      itemId: 'usersuploadfield',
      buttonOnly: true,
      iconCls: 'icon-file-upload',
      buttonText: 'Import Users',
      listeners: {
        scope: this,
        'fileselected': function(fb, v) {
          this.grid.myMask.show();
          this.uploadForm.submit({
            scope: this,
            success: function(form, action) {
              this.store.loadData(Ext.decode(action.response.responseText), !Ext.getCmp('chk-overwrite').checked);
              this.set_savebutton_state();
              form.reset();
              this.grid.myMask.hide();
            },
            failure: function(form, action) {
              this.grid.myMask.hide();
              data = Ext.decode(action.response.responseText);
              Ext.Msg.alert('Import Error', data['error']);
            }
          });
        }
      }
    });

    this.grid = new Ext.grid.GridPanel({
      store: this.store,
      margins: '0 5 5 5',
      width: 880,
      height: 400,
      plugins: [editor],
      stripeRows: true,
      title: 'Create the specified users',
      view: new Ext.grid.GroupingView({markDirty: false, forceFit: true}),
      tbar: [{
        iconCls: 'icon-user-add',
        text: 'Add User',
        scope: this,
        handler: function(){
          var u = new User({lastname: '', firstname: '', displayname: '', jurisdiction: '', mobile: '', fax: '', phone: '', email: ''});
          if(this.store.getCount() == 0 || (this.store.getCount() > 0 && editor.isValid())) {
            editor.stopEditing();
            this.store.insert(0, u);
            this.grid.getView().refresh();
            this.grid.getSelectionModel().selectRow(0);
            editor.startEditing(0);
          }
        }
      },{
        ref: '../removeBtn',
        iconCls: 'icon-user-delete',
        text: 'Remove User',
        disabled: true,
        scope: this,
        handler: function(){
          editor.stopEditing();
          var s = this.grid.getSelectionModel().getSelections();
          this.store.remove(s);
          this.set_savebutton_state();
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
      columns: [
        {header: 'Last Name', dataIndex: 'lastname', sortable: true, editor: {xtype:'textfield',id:'n_lastname',allowBlank:false}},
        {header: 'First Name', dataIndex: 'firstname', sortable: true, editor: {xtype:'textfield',id:'n_firstname',allowBlank:false}},
        {header: 'Display Name', dataIndex: 'displayname', sortable: true, editor: {xtype:'textfield',id:'n_displayname',allowBlank:true}},
        {header: 'Jurisdiction', dataIndex: 'jurisdiction', sortable: true, editor: {xtype:'textfield',id:'n_jurisdiction',allowBlank:false}},
        {header: 'Mobile', dataIndex: 'mobile', sortable: true, editor: {xtype:'textfield',id:'n_mobile',allowBlank:true}},
        {header: 'Fax', dataIndex: 'fax', sortable: true, editor: {xtype:'textfield',id:'n_fax',allowBlank:true}},
        {header: 'Phone', dataIndex: 'phone', sortable: true, editor: {xtype:'textfield',id:'n_phone',allowBlank:true}},
        {id: 'email', header: 'Email', dataIndex: 'email', sortable: true, editor: {xtype:'textfield',id:'n_email',allowBlank:false, vtype: 'email'}}
      ],
      set_gridmask: function(panel){
        this.myMask = new Ext.LoadMask(panel.getEl(), {msg:"Loading...", removeMask: true});
      }
    });

    this.grid.on('afterrender', function(){
      this.uploadForm = new Ext.form.BasicForm(this.grid.getTopToolbar().getComponent('testForm').getEl(),
        {url: 'admin_user_batch/import.html', method: "PUT", baseParams: {'authenticity_token': FORM_AUTH_TOKEN}, fileUpload: true});
      this.uploadForm.add(this.grid.getTopToolbar().getComponent('testForm').getComponent('usersuploadfield'));
    }, this, {delay: 10});

    this.grid.getSelectionModel().on('selectionchange', function(sm){
      this.grid.removeBtn.setDisabled(sm.getCount() < 1);
    });

    this.form_config = {
      form_width: 900,
      item_list: [ this.grid ],
      save_url: config.url + ".json",
      save_method: "POST"
    };

    Talho.BatchUsers.superclass.constructor.call(this, config);

    this.getPanel().on('render', this.grid.set_gridmask, this.grid, {delay: 1});

    this.getPanel().getForm().on('beforeaction', function(form, action){
      action.options.params = {}
      this.store.each(function(item, index){
        action.options.params['invitation[users_attributes][' + index + '][name]'] = item.data['name']
        action.options.params['invitation[users_attributes][' + index + '][email]'] = item.data['email']
      });
      return true;
    }, this);
  },

  set_savebutton_state: function(){
    if(this.store.getCount() == 0)
      this.getPanel().find("name", "save_button")[0].disable();
    else
      this.getPanel().find("name", "save_button")[0].enable();
  }
});

Talho.BatchUsers.initialize = function(config){
  var o = new Talho.BatchUsers(config);
  return o.getPanel();
};

Talho.ScriptManager.reg('Talho.BatchUsers', Talho.BatchUsers, Talho.BatchUsers.initialize);
