Ext.ns("Talho");

Talho.EditUsers = Ext.extend(Talho.ProfileBase, {
  constructor: function(config){
    this.store = new Ext.data.GroupingStore({
      autoLoad: {params: {start: 0, limit: 10}}, autoSave: false,
      restful: true,
      pruneModifiedRecords: true,
      url: "admin_edit_users/admin_users",
      reader: new Ext.data.JsonReader({
        totalProperty: 'total',
        root: 'rows',
        fields: [
          {name: 'last_name', mapping: 'user.last_name'},
          {name: 'first_name', mapping: 'user.first_name'},
          {name: 'display_name', mapping: 'user.display_name'},
          {name: 'mobile_phone', mapping: 'user.mobile_phone'},
          {name: 'fax', mapping: 'user.fax'},
          {name: 'phone', mapping: 'user.phone'},
          {name: 'email', mapping: 'user.email'},
          {name: 'id', mapping: 'user.id'},
          {name: 'state'}
        ]
      }),
      remoteSort: true, sortInfo: {field: 'last_name', direction: 'ASC'}
    });

    var editor = new Ext.ux.grid.RowEditor({
      saveText: 'Update',
      listeners: {scope: this, 'afterEdit': this.handle_row_modification}
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
      tbar: new Ext.PagingToolbar({
        store: this.store, displayInfo: true, pageSize: 10,
        items: [{
          iconCls: 'icon-user-add',
          text: 'Add User',
          scope: this,
          handler: function(){
            if(this.store.getCount() == 0 || (this.store.getCount() > 0 && editor.isValid())) {
              editor.stopEditing();
              this.store.insert(0, new this.store.recordType({id: -1, state: "new"}));
              this.grid.getView().refresh();
              this.grid.getSelectionModel().selectRow(0);
              editor.startEditing(0);
            }
          }
        },{
          ref: '../../../removeBtn',
          iconCls: 'icon-user-delete',
          text: 'Remove User',
          scope: this,
          handler: function(){
            jQuery.each(this.grid.getSelectionModel().getSelections(), function(i,e){ e.set("state", "deleted"); });
            this.store.filterBy(function(e){ return e.get("state")!="deleted"; });
          }
        }
      ]}),
      columns: [
        {header: 'Id', dataIndex: 'id', sortable: true},
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

    this.form_config = {
      //load_url: "admin_edit_users/admin_users",
      form_width: 900,
      item_list: [ this.grid ]
    };

    Talho.EditUsers.superclass.constructor.call(this, config);
  },

  // AJAX load and save methods
  //load_data: function(json){ this.store.loadData(json); },
  save_data: function(){
    this.store.clearFilter();
    var users = jQuery.map(this.store.getRange(), function(e,i){ return e.data; });
    this.store.filterBy(function(e){ return e.get("state")!="deleted"; });
    this.save_json("admin_edit_users/update.json", {"batch[users]": Ext.encode(users)});
  },
  is_dirty: function(){ return this.store.getModifiedRecords().length > 0; },

  handle_row_modification: function(re, changes, record, row_index){
    var state = record.get("state");
    if (state != "new" && state != "deleted") record.set("state", "changed");
  }
});

Talho.EditUsers.initialize = function(config){
  var o = new Talho.EditUsers(config);
  return o.getPanel();
};

Talho.ScriptManager.reg('Talho.EditUsers', Talho.EditUsers, Talho.EditUsers.initialize);
