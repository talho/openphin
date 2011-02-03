Ext.ns("Talho");

Talho.BatchUsers = Ext.extend(Talho.ProfileBase, {
  constructor: function(config){
    Ext.apply(this, config);

    this.store = new Ext.data.GroupingStore({
      reader: new Ext.data.JsonReader({
        fields: ['last_name', 'first_name', 'display_name', 'jurisdiction', 'mobile', 'fax', 'phone', 'email'],
        root: 'users_attributes'
      }),
      data: {'users_attributes': []},
      sortInfo: {field: 'last_name', direction: 'ASC'}
    });

    var editor = new Ext.ux.grid.RowEditor({
      saveText: 'OK',
      listeners: {scope: this, 'afterEdit': this.set_savebutton_state, 'cancelEdit': this.cancel_row_modification}
    });

    this.uploadButton = new Ext.ux.form.FileUploadField({
      name: 'users[csvfile]',
      itemId: 'usersuploadfield',
      buttonOnly: true,
      iconCls: 'icon-file-upload',
      buttonText: 'Import Users from CSV',
      listeners: {
        scope: this,
        'fileselected': function(fb, v) {
          this.getPanel().loadMask.show();
          this.uploadForm.submit({
            scope: this,
            success: function(form, action) {
              this.store.loadData(Ext.decode(action.response.responseText), !Ext.getCmp('chk-overwrite').checked);
              this.set_savebutton_state();
              form.reset();
              this.getPanel().loadMask.hide();
            },
            failure: function(form, action) {
              this.getPanel().loadMask.hide();
              data = Ext.decode(action.response.responseText);
              Ext.Msg.alert('Import Error', data['error']);
            }
          });
        }
      }
    });

    this.new_edit_in_progress = false;
    this.grid = new Ext.grid.GridPanel({
      store: this.store,
      margins: '0 5 5 5',
      width: 880,
      height: 400,
      plugins: [editor],
      stripeRows: true,
      view: new Ext.grid.GroupingView({markDirty: false, forceFit: true}),
      tbar: [
        {
        itemId: 'testForm',
        xtype: 'container',
        autoEl: 'form',
        items: [this.uploadButton]
      },{
        xtype: 'checkbox',
        id: 'chk-overwrite',
        boxLabel: 'Overwrite duplicates?',
        checked: true,
        submitValue: false
      },'->',{
        iconCls: 'icon-user-add',
        text: 'Add User',
        scope: this,
        buttonOnly: true,
        handler: function(){
          if(this.store.getCount() == 0 || (this.store.getCount() > 0 && editor.isValid())) {
            editor.stopEditing();
            this.new_edit_in_progress = true;
            this.store.insert(0, new this.store.recordType());
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
        buttonOnly: true,
        handler: function(){
          editor.stopEditing();
          var s = this.grid.getSelectionModel().getSelections();
          this.store.remove(s);
          this.set_savebutton_state();
        }
      }],
      columns: [
        {header: 'Last Name', dataIndex: 'last_name', sortable: true, editor: {xtype:'textfield',id:'n_lastname',allowBlank:false}},
        {header: 'First Name', dataIndex: 'first_name', sortable: true, editor: {xtype:'textfield',id:'n_firstname',allowBlank:false}},
        {header: 'Display Name', dataIndex: 'display_name', sortable: true, editor: {xtype:'textfield',id:'n_displayname',allowBlank:true}},
        {header: 'Jurisdiction', dataIndex: 'jurisdiction', sortable: true, editor: {xtype:'textfield',id:'n_jurisdiction',allowBlank:true}},
        {header: 'Mobile', dataIndex: 'mobile', sortable: true, editor: {xtype:'textfield',id:'n_mobile',allowBlank:true}},
        {header: 'Fax', dataIndex: 'fax', sortable: true, editor: {xtype:'textfield',id:'n_fax',allowBlank:true}},
        {header: 'Phone', dataIndex: 'phone', sortable: true, editor: {xtype:'textfield',id:'n_phone',allowBlank:true}},
        {id: 'email', header: 'Email', dataIndex: 'email', sortable: true, editor: {xtype:'textfield',id:'n_email',allowBlank:false,vtype:'email'}}
      ]
    });

    this.grid.on('afterrender', function(){
      this.uploadForm = new Ext.form.BasicForm(this.grid.getTopToolbar().getComponent('testForm').getEl(),
        {url: 'admin_user_batch/import.html', method: "PUT", baseParams: {'authenticity_token': FORM_AUTH_TOKEN}, fileUpload: true});
      this.uploadForm.add(this.grid.getTopToolbar().getComponent('testForm').getComponent('usersuploadfield'));
    }, this, {delay: 10});

    this.grid.getSelectionModel().on('selectionchange', function(sm){
      this.grid.removeBtn.setDisabled(sm.getCount() < 1);
    });

    var jurisdictions_store = new Ext.data.JsonStore({
      url: 'admin_user_batch/admin_jurisdictions', autoLoad: true, autoSave: false,
      fields: [{name: 'name', mapping: 'jurisdiction.name'}]
    });

    var panel_items = [
      {xtype: 'container', defaults:{width:900}, items:[
        {xtype: 'box', html: '<p id="flash-msg" class="flash">&nbsp;</p>'},
        {xtype: 'container', layout: 'hbox', defaults:{padding:'10'}, items: [
          {xtype: 'container', layout: 'form', labelAlign: 'left', items: [
            {xtype: 'form', name: 'main_form', labelAlign: 'left', url: 'admin_user_batch.json', method: "POST", border: false,
             baseParams: {'authenticity_token': FORM_AUTH_TOKEN}, listeners: {scope: this,
              'beforeaction': function(){ panel.loadMask.show() },
              'actioncomplete': function(f,a){ this.form_submit_success(f,a); this.store.removeAll(); },
              'actionfailed': this.form_submit_failure},
             items: [
            this.grid,
            {xtype: 'spacer', height: '10'},
            {xtype: 'combo', fieldLabel: 'Default Jurisdiction for this batch', name: 'user_batch[jurisdiction]', editable: false, triggerAction: 'all',
                store: jurisdictions_store, mode: 'local', displayField: 'name', labelStyle: 'white-space:nowrap;padding:0 90px 0 0'}
            ]}
          ]}
        ]},
        {xtype: 'spacer', height: '15'},
        {xtype: 'container', layout: 'hbox', layoutConfig:{pack:'end',defaultMargins:'0 0 0 10'},items:[
          {xtype: 'button', text: 'Apply Changes', name: 'save_button', handler: this.save, scope: this, width:'auto'},
          {xtype: 'button', text: 'Cancel and Discard Changes', handler: this.close, scope: this,width:'auto'}

        ]}
      ]}
    ];
    var panel = new Ext.Panel({
      title: this.title,
      border: false,
      layout: 'hbox', layoutConfig: {defaultMargins:'10',pack:'center'},
      cls: 'primary-panel',
      closable: true,
      keys: { key: [Ext.EventObject.ENTER, Ext.EventObject.RETURN], shift: false, fn: this.save, scope: this },
      autoWidth: true,
      autoScroll: true,
      itemId: config.id,
      items: panel_items
    });

    this.getPanel = function(){ return panel; }
    this.getPanel().addListener('render', function(p){
      p.loadMask =  new Ext.LoadMask(p.getEl(), {msg:"Loading...", removeMask: true});
    }, this);
  },
  
  // AJAX load and save methods
  save_data: function(){
    var users = jQuery.map(this.store.getRange(), function(e,i){ return e.data; });
    var options = {};
    options.params = {"user_batch[users]": Ext.encode(users)};
    this.getPanel().find("name", "main_form")[0].getForm().submit(options);
  },

  set_savebutton_state: function(){
    this.new_edit_in_progress = false;
    if(this.store.getCount() == 0)
      this.getPanel().find("name", "save_button")[0].disable();
    else
      this.getPanel().find("name", "save_button")[0].enable();
  },
  cancel_row_modification: function(editor){
    var record = this.grid.getStore().getAt(editor.rowIndex);
    if (this.new_edit_in_progress)
      this.grid.getStore().remove(record);
    this.new_edit_in_progress = false;
    this.set_savebutton_state();
    return false;
  }
});

Talho.BatchUsers.initialize = function(config){
  var o = new Talho.BatchUsers(config);
  return o.getPanel();
};

Talho.ScriptManager.reg('Talho.BatchUsers', Talho.BatchUsers, Talho.BatchUsers.initialize);
