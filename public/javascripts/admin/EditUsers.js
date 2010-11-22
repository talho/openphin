Ext.ns("Talho");

Talho.EditUsers = Ext.extend(Talho.ProfileBase, {
  constructor: function(config){
    this.store = new Ext.data.GroupingStore({
      autoLoad: false, autoSave: false,
      reader: new Ext.data.JsonReader({
        fields: [
          {name: 'last_name', mapping: 'user.last_name'},
          {name: 'first_name', mapping: 'user.first_name'},
          {name: 'display_name', mapping: 'user.display_name'},
          {name: 'mobile_phone', mapping: 'user.mobile_phone'},
          {name: 'fax', mapping: 'user.fax'},
          {name: 'phone', mapping: 'user.phone'},
          {name: 'email', mapping: 'user.email'},
          {name: 'state'}
        ]
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
          jQuery.each(this.grid.getSelectionModel().getSelections(), function(i,e){ e.set("state", "deleted"); });
          this.store.filterBy(function(e){ return e.get("state")!="deleted"; });
          this.set_savebutton_state();
        }
      }],
      columns: [
        {header: 'Last Name', dataIndex: 'last_name', sortable: true, editor: {xtype:'textfield',id:'n_lastname',allowBlank:true}},
        {header: 'First Name', dataIndex: 'first_name', sortable: true, editor: {xtype:'textfield',id:'n_firstname',allowBlank:true}},
        {header: 'Display Name', dataIndex: 'display_name', sortable: true, editor: {xtype:'textfield',id:'n_displayname',allowBlank:true}},
        {header: 'Mobile', dataIndex: 'mobile_phone', sortable: true, editor: {xtype:'textfield',id:'n_mobile',allowBlank:true}},
        {header: 'Fax', dataIndex: 'fax', sortable: true, editor: {xtype:'textfield',id:'n_fax',allowBlank:true}},
        {header: 'Phone', dataIndex: 'phone', sortable: true, editor: {xtype:'textfield',id:'n_phone',allowBlank:true}},
        {header: 'Email', dataIndex: 'email', sortable: true, editor: {xtype:'textfield',id:'n_email',allowBlank:false,vtype:'email'}},
        {xtype: 'xactioncolumn', icon: '/stylesheets/images/cross-circle.png', scope: this, handler: function(grid, row){
          var record = grid.getStore().getAt(row);
          record.set("state", "deleted");
          grid.getStore().filterBy(function(e){ return e.get("state")!="deleted"; });
        }}
      ]
    });

    this.grid.getSelectionModel().on('selectionchange', function(sm){
      this.grid.removeBtn.setDisabled(sm.getCount() < 1);
    });

    this.form_config = {
      load_url: "admin_edit_users/admin_users",
      form_width: 900,
      item_list: [ this.grid ]
    };

    Talho.EditUsers.superclass.constructor.call(this, config);
  },

  // AJAX load and save methods
  load_data: function(json){ this.store.loadData(json); },
  save_data: function(){
    this.store.clearFilter();
    var users = jQuery.map(this.store.getRange(), function(e,i){ return e.data; });
    this.store.filterBy(function(e){ return e.get("state")!="deleted"; });
    this.save_json("admin_edit_users/update.json", {"batch[users]": Ext.encode(users)});
  },
  is_dirty: function(){ return this.store.getModifiedRecords().length > 0; },

  handle_row_modification: function(re, changes, record, row_index){
    record.set("state", "changed");
    this.set_savebutton_state();
  },
  set_savebutton_state: function(){
    var b = this.getPanel().find("name", "save_button")[0];
    if (b == null) return;
    (this.store.getCount() == 0) ?  b.disable() : b.enable();
  }
});

Talho.EditUsers.initialize = function(config){
  var o = new Talho.EditUsers(config);
  return o.getPanel();
};

Talho.ScriptManager.reg('Talho.EditUsers', Talho.EditUsers, Talho.EditUsers.initialize);
