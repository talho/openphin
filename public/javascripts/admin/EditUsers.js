Ext.ns("Talho");

Talho.EditUsers = Ext.extend(Talho.ProfileBase, {
  constructor: function(config){
    this.store = new Ext.data.GroupingStore({
      autoLoad: false, autoSave: false,
      reader: new Ext.data.JsonReader({
        fields: ['last_name', 'first_name', 'display_name', 'mobile', 'fax', 'phone', 'email',]
      }),
      sortInfo: {field: 'last_name', direction: 'ASC'}
    });

    var editor = new Ext.ux.grid.RowEditor({
      saveText: 'Update',
      listeners: {scope: this, 'afterEdit': this.handle_row_modification, 'cancelEdit': this.set_savebutton_state}
    });

    this.grid = new Ext.grid.GridPanel({
      store: this.store,
      margins: '0 5 5 5',
      width: 880,
      height: 400,
      plugins: [editor],
      stripeRows: true,
      title: 'Edit users',
      view: new Ext.grid.GroupingView({markDirty: false, forceFit: true}),
      tbar: [{
        iconCls: 'icon-user-add',
        text: 'Add User',
        scope: this,
        handler: function(){
          if(this.store.getCount() == 0 || (this.store.getCount() > 0 && editor.isValid())) {
            editor.stopEditing();
            this.store.insert(0, new this.store.recordType({state: "new"}));
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
          jQuery.each(this.grid.getSelectionModel().getSelections(), function(i,e){ e.data.state = "deleted"; });
          this.store.filterBy(function(e){ return e.data.state!="deleted"; });
          this.set_savebutton_state();
        }
      }],
      columns: [
        {header: 'Last Name', dataIndex: 'last_name', sortable: true, editor: {xtype:'textfield',id:'n_lastname',allowBlank:true}},
        {header: 'First Name', dataIndex: 'first_name', sortable: true, editor: {xtype:'textfield',id:'n_firstname',allowBlank:true}},
        {header: 'Display Name', dataIndex: 'display_name', sortable: true, editor: {xtype:'textfield',id:'n_displayname',allowBlank:true}},
        {header: 'Mobile', dataIndex: 'mobile', sortable: true, editor: {xtype:'textfield',id:'n_mobile',allowBlank:true}},
        {header: 'Fax', dataIndex: 'fax', sortable: true, editor: {xtype:'textfield',id:'n_fax',allowBlank:true}},
        {header: 'Phone', dataIndex: 'phone', sortable: true, editor: {xtype:'textfield',id:'n_phone',allowBlank:true}},
        {header: 'Email', dataIndex: 'email', sortable: true, editor: {xtype:'textfield',id:'n_email',allowBlank:false,vtype:'email'}},
        {xtype: 'xactioncolumn', icon: '/stylesheets/images/cross-circle.png', scope: this, handler: function(grid, row){
          var record = grid.getStore().getAt(row);
          var id = record.get('id');
          record.data.state = "deleted";
          grid.getStore().filterBy(function(e){ return e.data.state!="deleted"; });
        }}
      ]
    });

    this.grid.getSelectionModel().on('selectionchange', function(sm){
      this.grid.removeBtn.setDisabled(sm.getCount() < 1);
    });

    this.form_config = {
      load_url: "admin_edit_users/admin_users",
      form_width: 900,
      item_list: [ this.grid ],
      save_url: "admin_edit_users/update.json",
      save_method: "PUT"
    };

    Talho.EditUsers.superclass.constructor.call(this, config);
  },

  // AJAX load and save methods
  load_data: function(json){
    var store = this.store;
    var users = jQuery.map(json, function(e,i){ return new store.recordType(e.user); });
    store.removeAll();
    store.add(users);
  },
  save_data: function(){
    this.store.clearFilter();
    var users = jQuery.map(this.store.getRange(), function(e,i){ return e.data; });
    this.store.filterBy(function(e){ return e.data.state!="deleted"; });
    //var json = Ext.encode(users);
    //this.save_json(this.form_config.save_url, {"batch[users]": json});
    var options = {};
    options.params = {};
    options.params["batch[users]"] = Ext.encode(users);
    this.getPanel().getForm().submit(options);
  },

  handle_row_modification: function(re, changes, record, row_index){
    record.data.state = "changed";
    this.set_savebutton_state();
  },
  set_savebutton_state: function(){
    if(this.store.getCount() == 0)
      this.getPanel().find("name", "save_button")[0].disable();
    else
      this.getPanel().find("name", "save_button")[0].enable();
  }
});

Talho.EditUsers.initialize = function(config){
  var o = new Talho.EditUsers(config);
  return o.getPanel();
};

Talho.ScriptManager.reg('Talho.EditUsers', Talho.EditUsers, Talho.EditUsers.initialize);
