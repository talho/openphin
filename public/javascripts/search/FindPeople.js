Ext.ns('Talho');

Talho.FindPeople = Ext.extend(Ext.util.Observable, {
  constructor: function(config){
    Ext.apply(this, config);
    Talho.FindPeople.superclass.constructor.call(this, config);

    this.rolesStore = new Ext.data.JsonStore({
      url: '/roles.json',
      restful: true,
      root: 'roles',
      storeId: 'phinroles',
      fields: ['name', 'id'],
      autoLoad: true
    });

    this.jurisdictionsStore = new Ext.data.JsonStore({
      url: '/jurisdictions.json' + ((this.admin_mode) ? '?admin_mode=1' : ''),
      restful: true,
      root: 'jurisdictions',
      storeId: 'phinjuris',
      fields: ['name', 'id'],
      autoLoad: true
    });

    this.resultsStore = new Ext.data.JsonStore({
      url: 'search/show_advanced.json',
      method: 'POST',
      root: 'results',
      fields: [ 'user_id', 'first_name', 'last_name', 'email', 'role_memberships', 'photo' ],
      autoLoad: false,
      remoteSort: true,
      listeners: {
        scope: this,
        'load': this.handleResults,
        'exception': this.handleError
      }
    });

    this.RESULTS_PAGE_SIZE = 10;

    this.resultsStore.setDefaultSort('last_name', 'asc');    // tell ext what the initial dataset will look like

    this.rolesList = new Ext.list.ListView({
      store: this.rolesStore,
      id: 'with_role_ids',
      multiSelect: true,
      simpleSelect: true,
      columnSort: false,
      loadingText: 'Fetching role list...',
      emptyText: 'Error:  Could not retrieve Roles',
      deferEmptyText: true,
      hideHeaders: true,
      columns: [{ dataIndex: 'name' }]
    });

    this.jurisList = new Ext.list.ListView({
      store: this.jurisdictionsStore,
      id: 'with_jurisdiction_ids',
      multiSelect: true,
      simpleSelect: true,
      columnSort: false,
      loadingText: 'Fetching jurisdiction list...',
      emptyText: 'Error:  Could not retrieve Jurisdictions',
      deferEmptyText: true,
      hideHeaders: true,
      columns: [{ dataIndex: 'name' }]
    });

    this.rolesSelector = new Ext.Panel ({
      layout: 'fit',
      flex: 1,
      width: '100%',
      title: 'Roles: <i>(none selected)</i>',
      items: [this.rolesList],
      style: { 'padding-bottom': '10px', 'padding-top': '5px'}
    });

    this.jurisSelector = new Ext.Panel ({
      layout: 'fit',
      flex: 1,
      width: '100%',
      title: 'Jurisdictions: <i>(none selected)</i>',
      items: [this.jurisList]
    });

    this.searchSidebar = new Ext.FormPanel({
      id: 'advanced_search_panel',
      labelAlign: 'top',
      frame: true,
      region: 'west',
      width: 300,
      fill: true,
      layout: 'vbox',
      title: 'People Search',
      autoScroll: true,
      items: [{
        layout: 'form',
        width: '100%',
        items: [
          { fieldLabel: 'Name', name: 'conditions[name]', xtype: 'textfield', anchor: '95%' },
          { fieldLabel: 'Email Address', name: 'conditions[email]', xtype: 'textfield', anchor: '95%' },
          { layout: 'column', items: [
            { columnWidth: .5, layout: 'form',
              items: [{ fieldLabel: 'Phone', name: 'conditions[phone]', xtype: 'textfield', anchor: '90%' }]
            },
            { columnWidth: .5, layout: 'form',
              items: [{ fieldLabel: 'Job Title', name: 'conditions[title]', xtype: 'textfield', anchor: '90%' }]
          }]
        }]
      },
        this.rolesSelector,
        this.jurisSelector
      ],
      buttonAlign : 'center',
      buttons: [{ text: 'Search', scope: this, handler: this.displaySearchResults }]
    });

    this.nameColTemplate = new Ext.XTemplate(
      '<div style="float: left; height: 60px; width: 60px;"><img src="{photo}"></div>',
      '<div style="float: left; margin-left: 15px;">',
        '<div style="font-weight: bold; font-size: 150%;">{last_name}, {first_name}</div><br />',
        '<div>{email}</div></div>'
    );

    this.rolesColTemplate = new Ext.XTemplate(
      '<tpl for="role_memberships"><p>{.}</p></tpl>'
    );

    this.startScreen = new Ext.Panel ({
      id: 'search_welcome',
      html: '<div style=" padding: 20px;"><span style="font-size: 200%;">TxPHIN Search</span><br >Use the form at left to get started.</div>'
    });

    this.noResultsScreen = new Ext.Panel ({
      id: 'search_no_results',
      html: '<div style=" padding: 20px;"><span style="font-size: 200%;">No Results</span><br >No users match your search request</div>'
    });

    this.serverError = new Ext.Panel ({
      id: 'search_error',
      html: '<div style="padding: 20px;"><span style="font-size: 200%;">Server Error</span><br >There was an error communicating with the server.<br/ >If the problem persists, please contact an administrator.</div>'
    });

    this.searchResults = new Ext.grid.GridPanel({
      id: 'search_results',
      layout: 'hbox',
      store: this.resultsStore,
      colModel: new Ext.grid.ColumnModel({
        columns: [
          { id: 'user', dataIndex: 'last_name', header: 'Search Results', sortable: true, width: 300, xtype: 'templatecolumn', tpl: this.nameColTemplate },
          { id: 'roles', dataIndex: 'role_memberships', header: 'Roles', sortable: false, width: 300, xtype: 'templatecolumn', tpl: this.rolesColTemplate }
        ]
      }),       
      listeners: {
        scope: this,
        'cellclick': function(grid, row, column, e){
          var record = grid.getStore().getAt(row);  // Get the Record
          var name = record.get('first_name') + ' ' + record.get('last_name');
          var url = '/users/' + record.get('user_id') + '/profile';
          if (this.admin_mode) {
            Application.fireEvent('opentab', {title: 'Edit User: ' + name, url: url, id: 'edit_user_for_' + record.get('user_id'), initializer: 'Talho.EditProfile'});
          } else {
            Application.fireEvent('opentab', {title: 'Profile: ' + name, url: url, id: 'user_profile_for_' + record.get('user_id')});
          }
        }
      },
      tbar: new Ext.PagingToolbar({
        pageSize: this.RESULTS_PAGE_SIZE,
        store: this.resultsStore,
        displayInfo: true,
        displayMsg: 'Displaying results {0} - {1} of {2}',
        emptyMsg: "No results"
      })
    });

    this.searchResultsContainer = new Ext.Panel({
      region: 'center',
      layout: 'card',
      activeItem: 'search_welcome',
      id: 'SPONG',
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
      id: "fatty arbuckle",
      items: [
        this.searchSidebar,
        this.searchResultsContainer
      ],
      title: this.title
    });

    this.getPanel = function(){
      return this.primary_panel;
    };

    this.rolesList.on('selectionchange', function(view, nodes){
      var l = nodes.length;
      if (l == 0) { l = 'none'}
      this.rolesSelector.setTitle('Roles: <i>('+l+' selected)</i>');
    }, this );

    this.jurisList.on('selectionchange', function(view, nodes){
      var l = nodes.length;
      if (l == 0) { l = 'none'}
      this.jurisSelector.setTitle('Jurisdictions: <i>('+l+' selected)</i>');
    }, this );
  },

  handleResults: function(store){
    if (store.getCount() < 1){
      this.searchResultsContainer.layout.setActiveItem('search_no_results');
    } else {
      this.searchResultsContainer.layout.setActiveItem('search_results');
    }
  },

  handleError: function(){
    this.searchResultsContainer.layout.setActiveItem('search_error');
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
    var searchData =  this.searchSidebar.getForm().getValues();
    this.applyFilters(searchData);
    for (var derp in searchData ){
      this.searchResults.store.setBaseParam( derp, searchData[derp] );
    }
    this.searchResults.store.setBaseParam('limit', this.RESULTS_PAGE_SIZE);
    this.searchResults.store.load();
  },

  searchError: function() {
    alert("oops");
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
