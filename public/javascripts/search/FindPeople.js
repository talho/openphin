Ext.ns('Talho');

Talho.FindPeople = Ext.extend(Ext.util.Observable, {
  constructor: function(config){
    Talho.FindPeople.superclass.constructor.call(this, config);

    this.rolesStore = new Ext.data.JsonStore({
      url: '/roles.json',
      restful: true,
      root: 'roles',
      fields: ['name', 'id'],
      autoLoad: true
    });

    this.jurisdictionsStore = new Ext.data.JsonStore({
      url: '/jurisdictions.json' + ((this.admin_mode) ? '?admin_mode=1' : ''),
      restful: true,
      root: 'jurisdictions',
      fields: ['name', 'id'],
      autoLoad: true
    });

    this.RESULTS_PAGE_SIZE = 10;
    this.resultsStore = new Ext.data.JsonStore({
      url: 'search/show_advanced.json' + ((this.admin_mode) ? '?admin_mode=1' : ''),
      method: 'POST',
      root: 'results',
      fields: [ 'user_id', 'display_name','first_name', 'last_name', 'email', 'role_memberships', 'role_requests', 'photo' ],
      autoLoad: false,
      remoteSort: true,
      baseParams: {'limit': this.RESULTS_PAGE_SIZE, 'authenticity_token': FORM_AUTH_TOKEN},
      listeners: {
        scope: this,
        'load': this.handleResults,
        'exception': this.handleError
      }
    });

    this.resultsStore.setDefaultSort('last_name', 'asc');    // tell ext what the initial dataset will look like

    this.rolesList = new Ext.list.ListView({
      store: this.rolesStore,
      multiSelect: true,
      simpleSelect: true,
      columnSort: false,
      loadingText: 'Fetching role list...',
      emptyText: 'Error:  Could not retrieve Roles',
      deferEmptyText: true,
      hideHeaders: true,
      style: { 'background-color': 'white'},
      columns: [{dataIndex: 'name', cls: 'rol-list-item' }]
    });

    this.jurisList = new Ext.list.ListView({
      store: this.jurisdictionsStore,
      multiSelect: true,
      simpleSelect: true,
      columnSort: false,
      loadingText: 'Fetching jurisdiction list...',
      emptyText: 'Error:  Could not retrieve Jurisdictions',
      deferEmptyText: true,
      hideHeaders: true,
      style: { 'background-color': 'white'},
      columns: [{ dataIndex: 'name', cls: 'jur-list-item'}]
    });

    this.rolesSelector = new Ext.Panel ({
      id: 'roles-select',
      layout: 'fit',
      flex: 1,
      width: '100%',
      border: false,
      tbar: new Ext.Toolbar({items: [
        {xtype: 'tbtext', name: 'hdr', html: 'Roles: <i>(none selected)</i>'}, '->',
        {xtype: 'button', text: 'Clear All', scope: this, handler: function(){ this.rolesList.clearSelections(); }}
      ]}),
      items: [this.rolesList],
      style: { 'padding-bottom': '10px', 'padding-top': '5px'}
    });

    this.jurisSelector = new Ext.Panel ({
      id: 'jurisdictions-select',
      layout: 'fit',
      flex: 1,
      width: '100%',
      tbar: new Ext.Toolbar({items: [
        {xtype: 'tbtext', name: 'hdr', html: 'Jurisdictions: <i>(none selected)</i>'}, '->',
        {xtype: 'button', text: 'Clear All', scope: this, handler: function(){ this.jurisList.clearSelections(); }}
      ]}),
      items: [this.jurisList]
    });

    this.searchSidebar = new Ext.FormPanel({
      id: 'people-search',
      labelAlign: 'top',
      frame: true,
      region: 'west',
      width: 300,
      fill: true,
      margins: '5 5 5 5',
      layout: 'vbox',
      title: 'People Search',
      autoScroll: true,
      items: [{
        layout: 'form',
        width: '100%',
        items: [
          { fieldLabel: 'Name', name: 'conditions[name]', xtype: 'textfield', anchor: '95%', id: 'search-name' },
          { fieldLabel: 'Email Address', name: 'conditions[email]', xtype: 'textfield', anchor: '95%', id: 'search-email' },
          { layout: 'column', items: [
            { columnWidth: .5, layout: 'form',
              items: [{ fieldLabel: 'Phone', name: 'conditions[phone]', xtype: 'textfield', anchor: '90%', id: 'search-phone' }]
            },
            { columnWidth: .5, layout: 'form',
              items: [{ fieldLabel: 'Job Title', name: 'conditions[title]', xtype: 'textfield', anchor: '90%', id: 'search-title' }]
          }]
        }]
      },
        this.rolesSelector,
        this.jurisSelector
      ],
      buttonAlign : 'center',
      buttons: [
        {text: 'Reset', scope: this, handler: this.resetSearchSidebar},
        { text: 'Search', scope: this, handler: this.displaySearchResults }
      ],
        keys: [{key: Ext.EventObject.RETURN, shift: false, fn: this.displaySearchResults, scope: this}]
    });

     this.nameColTemplate = new Ext.XTemplate(
      '<div style="float: left; height: 60px; width: 60px;"><img src="{photo}"></div>',
      '<div style="float: left; margin-left: 15px; width: 205px;">',
        '<span style="white-space:normal; font-weight: bold; font-size: 150%;">{display_name}</span><br/ >',
        '<tpl if="(first_name +\' \' + last_name) != display_name">({first_name} {last_name})<br /></tpl>',
      '{email}</div>'
    );

    this.rolesColTemplate = new Ext.XTemplate(
      '<tpl for="role_memberships"><p>{.}</p></tpl>',
      '<tpl if="role_requests.length &gt; 0"><br>Pending:<br></tpl>',
      '<tpl for="role_requests"><p><i>{.}</i></p></tpl>'
    );

    this.startScreen = new Ext.Panel ({
      html: '<div style=" padding: 20px;"><span style="font-size: 200%;">TxPHIN Search</span><br >Use the form at left to get started.</div>'
    });

    this.noResultsScreen = new Ext.Panel ({
      html: '<div style=" padding: 20px;"><span style="font-size: 200%;">No Results</span><br >No users match your search request</div>'
    });

    this.serverError = new Ext.Panel ({
      html: '<div style="padding: 20px;"><span style="font-size: 200%;">Server Error</span><br >There was an error communicating with the server.<br/ >If the problem persists, please contact an administrator.</div>'
    });

    var admin_mode_buttons = [
      {xtype: 'tbspacer', width: 25},
      {text: 'Add User', scope: this, handler: function(){
        Application.fireEvent('opentab', {title: 'Add User', id: 'add_new_user', initializer: 'Talho.AddUser'});
      }},
      {text: 'Edit User', name: 'edit_btn', disabled: true, scope: this, handler: function(){
        var selected_records = this.searchResults.getSelectionModel().getSelections();
        Ext.each(selected_records, function(e,i){ this.openEditUserTab(e) }, this);
      }},
      {text: 'Delete User', name: 'delete_btn', disabled: true, scope: this, handler: function(){
        var selected_records = this.searchResults.getSelectionModel().getSelections();
        if (selected_records.length == 0) return;
        Ext.Msg.confirm("Confirm User Deletion", "Are you sure you wish to delete " + selected_records.length + " users?",
          function(id){
            if (id != "yes") return;
            var delete_params = new Object;
            Ext.each(selected_records, function(record,i){ delete_params["users[user_ids][]"] = record.get('user_id'); });
            var json_auth = Ext.apply({'authenticity_token': FORM_AUTH_TOKEN}, delete_params);
            Ext.Ajax.request({ url: "/users_delete.json", method: "POST", params: json_auth,
              success: this.ajax_success_cb, failure: this.ajax_err_cb, scope: this });
          }, this);
      }}
    ];
    this.searchResults = new Ext.grid.GridPanel({
      cls: 'people-results',
      layout: 'hbox',
      store: this.resultsStore,
      colModel: new Ext.grid.ColumnModel({
        columns: [
          { id: 'user', dataIndex: 'last_name', header: 'Search Results', sortable: true, width: 300, xtype: 'templatecolumn', tpl: this.nameColTemplate },
          { id: 'roles', dataIndex: 'role_memberships', header: 'Roles', sortable: false, width: 350, xtype: 'templatecolumn', tpl: this.rolesColTemplate }
        ]
      }),       
      selModel: new Ext.grid.RowSelectionModel({
        listeners: {scope:this, 'selectionchange': this.set_edit_delete_state}
      }),
      listeners: {
        scope: this,
        'cellclick': function(grid, row, column, e){
          if (this.admin_mode) return true;
          var record = grid.getStore().getAt(row);  // Get the Record
          this.openUserProfileTab(record);
        },
        'celldblclick': function(grid, row, column, e){
          if (!this.admin_mode) return true;
          var record = grid.getStore().getAt(row);  // Get the Record
          this.openEditUserTab(record);
        }
      },
      tbar: new Ext.PagingToolbar({
        pageSize: this.RESULTS_PAGE_SIZE,
        store: this.resultsStore,
        displayInfo: true,
        displayMsg: 'Displaying results {0} - {1} of {2}',
        emptyMsg: "No results",
        items: (this.admin_mode) ? admin_mode_buttons : []
      })
    });

    this.searchResultsContainer = new Ext.Panel({
      region: 'center',
      layout: 'card',
      activeItem: 0,
      frame: false,
      border: true,
      bodyBorder: false,
      margins: '5 5 5 0',
      padding: '0',
      items: [
        this.startScreen,
        this.searchResults,
        this.noResultsScreen,
        this.serverError
      ]
    });

    this.primary_panel = new Ext.Panel({
      layout:'border',
      itemId: config.id,
      closable: true,
      items: [
        this.searchSidebar,
        this.searchResultsContainer
      ],
      title: config.title
    });

    this.getPanel = function(){
      return this.primary_panel;
    };

    this.rolesList.on('selectionchange', function(view, nodes){
      var l = nodes.length;
      if (l == 0) { l = 'none'}
      var hdrText = 'Roles: <i>('+l+' selected)</i>';
      this.rolesSelector.getTopToolbar().find('name', 'hdr')[0].setText(hdrText);
    }, this );

    this.jurisList.on('selectionchange', function(view, nodes){
      var l = nodes.length;
      if (l == 0) { l = 'none'}
      var hdrText = 'Jurisdictions: <i>('+l+' selected)</i>';
      this.jurisSelector.getTopToolbar().find('name', 'hdr')[0].setText(hdrText);
    }, this );
    if (this.admin_mode)
      this.primary_panel.on('afterrender', function(){ this.searchResults.store.load(); }, this);
  },

  resetSearchSidebar: function(btn,evt){
    this.searchSidebar.getForm().reset();
    this.rolesList.clearSelections();
    this.jurisList.clearSelections();
  },

  handleResults: function(store){
    if (store.getCount() < 1){
      this.searchResultsContainer.layout.setActiveItem(2); // no_results
    } else {
      this.searchResultsContainer.layout.setActiveItem(1); // show_results
    }
  },

  handleError: function(proxy, type, action, options, response, arg){
    this.show_err_message(Ext.decode(response.responseText));
    this.searchResultsContainer.layout.setActiveItem(3); // search_error
  },

  applyFilters: function(params){     //add selected role and juri IDs, because they are not part of the form
    var roleIds = [];
    var jurisIds = [];
    var selectedRoles = this.rolesList.getSelectedRecords();
    var selectedJurisdictions = this.jurisList.getSelectedRecords();

    for (var r = 0; r < this.rolesList.getSelectionCount(); r++ ){
      roleIds[r] = selectedRoles[r].json.id;
    }
    for (var j = 0; j < this.jurisList.getSelectionCount(); j++ ){
      jurisIds[j] = selectedJurisdictions[j].json.id;
    }
    params['with[jurisdiction_ids][]'] = jurisIds;
    params['with[role_ids][]'] = roleIds;
    return true;
  },

  displaySearchResults: function(form, action) {
    var searchData = this.searchSidebar.getForm().getValues();
    this.applyFilters(searchData);
    for (var derp in searchData ){
      this.searchResults.store.setBaseParam( derp, searchData[derp] );
    }
    this.searchResults.store.load();
  },

  openUserProfileTab: function(record){
    var user_id = record.get('user_id');
    Application.fireEvent('opentab',
      {title: 'Profile: ' + record.get('display_name'), user_id: user_id, id: 'user_profile_for_' + user_id, initializer: 'Talho.ShowProfile'});
  },

  openEditUserTab: function(record){
    var user_id = record.get('user_id');
    var name = record.get('first_name') + ' ' + record.get('last_name');
    var url = '/users/' + user_id + '/profile';
    Application.fireEvent('opentab',
      {title: 'Edit User: ' + name, url: url, user_id: user_id, id: 'edit_user_for_' + user_id, initializer: 'Talho.EditProfile'});
  },

  set_edit_delete_state: function(selModel){
    var selected_records = selModel.getSelections();
    var tbar = this.searchResults.getTopToolbar();
    tbar.find("name", "edit_btn")[0].setDisabled(selected_records.length == 0);
    tbar.find("name", "delete_btn")[0].setDisabled(selected_records.length == 0);
  },

  ajax_success_cb: function(response, opts) {
    var json = Ext.decode(response.responseText);
    if (json.delete_result) {
      var selected_records = this.searchResults.getSelectionModel().getSelections();
      this.resultsStore.remove(selected_records);
    } else {
      this.show_err_message(json);
    }
  },
  ajax_err_cb: function(response, opts) {
    var msg = '<b>Status: ' + response.status + ' => ' + response.statusText + '</b><br><br>' +
      '<div style="height:400px;overflow:scroll;">' + response.responseText + '<\div>';
    Ext.Msg.show({title: 'Error', msg: msg, minWidth: 900, maxWidth: 900, buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR});
  },
  show_err_message: function(json) {
    var w = 300;
    var msg = '<b>Server Error:</b> ' + json.error + '<br>';
    if (json.exception != null) {
      w = 900;
      msg += '<b>Exception:</b> ' + json.exception + '<br><br>';
      msg += '<div style="height:400px;overflow:scroll;">';
      for (var i = 0; i < json.backtrace.length; i++)
        msg += '&nbsp;&nbsp;' + json.backtrace[i] + '<br>';
      msg += '<\div>';
    }
    Ext.Msg.show({title: 'Error', msg: msg, minWidth: w, maxWidth: w, buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR});
  }
});

/**
 * Initializer for the FindPeople object. Returns a panel
 */
Talho.FindPeople.initialize = function(config){
    var find_people_panel = new Talho.FindPeople(config);
    return find_people_panel.getPanel();
};

Talho.ScriptManager.reg('Talho.FindPeople', Talho.FindPeople, Talho.FindPeople.initialize);
