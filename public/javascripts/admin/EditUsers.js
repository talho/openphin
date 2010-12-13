Ext.ns("Talho");

Talho.EditRolesButton = Ext.extend(Ext.Button, {
  constructor: function(config, ancestor){
    this.ancestor = ancestor;
    Talho.EditRolesButton.superclass.constructor.call(this, config);
  },
  text: 'Edit Roles',
  handler: function(b,e){
    this.ancestor.editor.stopEditing();
    this.ancestor.manage_user_roles(b.record);
  },
  isValid: function(){ return true; },
  getValue: function(){ return 0; },
  setValue: function(v,record){ this.record = record; }
});

Talho.EditUsers = Ext.extend(Talho.ProfileBase, {
  constructor: function(config){
    this.pageSize = 10;
    this.store = new Ext.data.GroupingStore({
      autoLoad: {params: {start: 0, limit: this.pageSize}}, autoSave: false,
      restful: true,
      pruneModifiedRecords: true,
      url: "admin_edit_users/admin_users",
      reader: new Ext.data.JsonReader({
        totalProperty: 'total',
        root: 'rows',
        fields: [
          {name: 'last_name', mapping: 'user.last_name'},
          {name: 'first_name', mapping: 'user.first_name'},
          {name: 'mobile_phone', mapping: 'user.mobile_phone'},
          {name: 'fax', mapping: 'user.fax'},
          {name: 'phone', mapping: 'user.phone'},
          {name: 'email', mapping: 'user.email'},
          {name: 'id', mapping: 'user.id'},
          {name: 'roles', mapping: 'roles'},
          {name: 'state'}
        ]
      }),
      remoteSort: true, sortInfo: {field: 'last_name', direction: 'ASC'}
    });

    this.editor = new Ext.ux.grid.RowEditor({
      saveText: 'Update',
      listeners: {scope: this, 'afterEdit': this.handle_row_modification, 'cancelEdit': this.cancel_row_modification}
    });
    var roles_tpl = new Ext.XTemplate(
      '<ul>',
      '<tpl for="roles">',
        '<li>',
            '<tpl if="state==' + "'pending'" + '"><i></tpl>',
            '{jname}&nbsp;&ndash;&nbsp;{rname}',
            '<tpl if="state==' + "'pending'" + '"></i></tpl>',
        '</li>',
      '</tpl>',
      '</ul>'
    );

    this.new_edit_in_progress = false;
    this.grid = new Ext.grid.GridPanel({
      store: this.store,
      margins: '0 0 0 0',
      width: 880,
      height: 400,
      plugins: [this.editor],
      stripeRows: true,
      title: 'Edit users',
      view: new Ext.grid.GroupingView({markDirty: false, forceFit: true}),
      tbar: new Ext.PagingToolbar({
        store: this.store, displayInfo: true, pageSize: this.pageSize,
        items: [{
          iconCls: 'icon-user-add',
          text: 'Add User',
          scope: this,
          handler: function(){
            if(this.store.getCount() == 0 || (this.store.getCount() > 0 && this.editor.isValid())) {
              this.editor.stopEditing();
              this.new_edit_in_progress = true;
              this.store.insert(0, new this.store.recordType({id: -1, state: "new"}));
              this.grid.getView().refresh();
              this.grid.getSelectionModel().selectRow(0);
              this.editor.startEditing(0);
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
        //{header: 'Id', dataIndex: 'id', sortable: true},
        {header: 'Last Name', dataIndex: 'last_name', sortable: true, editor: {xtype:'textfield',id:'n_lastname',allowBlank:true}},
        {header: 'First Name', dataIndex: 'first_name', sortable: true, editor: {xtype:'textfield',id:'n_firstname',allowBlank:true}},
        {header: 'Mobile', dataIndex: 'mobile_phone', sortable: true, editor: {xtype:'textfield',id:'n_mobile',allowBlank:true}},
        {header: 'Fax', dataIndex: 'fax', sortable: true, editor: {xtype:'textfield',id:'n_fax',allowBlank:true}},
        {header: 'Phone', dataIndex: 'phone', sortable: true, editor: {xtype:'textfield',id:'n_phone',allowBlank:true}},
        {header: 'Email', dataIndex: 'email', sortable: true, editor: {xtype:'textfield',id:'n_email',allowBlank:false,vtype:'email'}, width: 150},
        {xtype: 'templatecolumn', header: 'Roles', dataIndex: 'roles', sortable: false, tpl: roles_tpl, width: 250,
          editor: new Talho.EditRolesButton({}, this)},
        {xtype: 'xactioncolumn', icon: '/stylesheets/images/cross-circle.png', sortable: false, scope: this,
          handler: function(grid, row){ this.editor.stopEditing(); this.manage_user_roles(grid.getStore().getAt(row)); }},
        {xtype: 'xactioncolumn', header: 'X', icon: '/stylesheets/images/cross-circle.png', sortable: false, scope: this,
          handler: function(grid, row){
            var record = grid.getStore().getAt(row);
            record.set("state", "deleted");
            grid.getStore().filterBy(function(e){ return e.get("state")!="deleted"; });
          }
        }
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

  // Row editor callbacks
  handle_row_modification: function(re, changes, record, row_index){
    var state = record.get("state");
    if (state != "new" && state != "deleted") record.set("state", "changed");
  },
  cancel_row_modification: function(editor){
    var record = this.grid.getStore().getAt(editor.rowIndex);
    if (this.new_edit_in_progress)
      this.grid.getStore().remove(record);
    this.new_edit_in_progress = false;
    return false;
  },

  // manage roles popup window
  manage_user_roles: function(record){
    var user_id = record.get("id");
    var user_name = record.get("first_name") + " " + record.get("last_name");
    var load_user_roles_url = "users/" + user_id + "/profile/edit.json";
    var save_url = "users/" + user_id + "/profile.json";
    var roles_control = new Talho.ux.RolesControl(save_url, this);
    roles_control.load_data(record.get("roles"));
    var win = new Ext.Window({
      title: "Manage Roles for '" + user_name + "'",
      layout: 'form',
      autoScroll: true,
      padding: '10',
      width: 440, height: 400,
      items: [roles_control]
    });
    win.addButton({xtype: 'button', text: 'Save', handler: function(){ roles_control.save_data(); win.close(); }, scope: this, width:'auto'});
    win.addButton({xtype: 'button', text: 'Cancel', handler: function(){ win.close(); }, scope: this, width:'auto'});
    //win.addListener('render',
    //  function(p){ this.load_json({url: load_user_roles_url, success: this.load_user_roles_cb, rc: roles_control}); }, this);
    win.show();
  },
  load_user_roles_cb: function(response, options){
    var json = Ext.decode(response.responseText, true);
    options.rc.load_data(json.extra.role_desc);
  }
});

Talho.EditUsers.initialize = function(config){
  var o = new Talho.EditUsers(config);
  return o.getPanel();
};

Talho.ScriptManager.reg('Talho.EditUsers', Talho.EditUsers, Talho.EditUsers.initialize);
