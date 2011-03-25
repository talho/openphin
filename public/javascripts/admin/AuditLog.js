Ext.ns("Talho");

Talho.AuditLog = Ext.extend(Ext.util.Observable, {
  constructor: function(config){
    Talho.AuditLog.superclass.constructor.call(this, config);

    this.RESULTS_PAGE_SIZE = 15;

    this.resultsStore = new Ext.data.JsonStore({
      url: '/audits.json',
      method: 'GET',
      restful: true,
      root: 'versions',
      totalProperty: 'total_count',
      fields: [ 'id', 'item_type', 'item_id', 'descriptor', 'event', 'whodunnit', { name: 'created_at', type: 'date'} ],
      autoLoad: true,
      remoteSort: true
    });


    this.modelList = new Ext.list.ListView({
      store: this.modelStore,
      multiSelect: true,
      simpleSelect: true,
      columnSort: false,
      loadingText: 'Fetching Log lists...',
      emptyText: 'Error:  Could not retrieve log lists',
      deferEmptyText: true,
      hideHeaders: true,
      style: { 'background-color': 'white'},
      columns: [{ dataIndex: 'name', cls: 'jur-list-item'}]
    });

    this.modelSelector = new Ext.Panel({
//TODO: this should do a thing.
//TODO: fetch this list from the server
      region: 'west', width: 200, title: 'hello',
      items: [
        {html: 'All', style: {'font-size': '150%', 'font-weight': 'bold'}, height: 30},
        {html: 'Alerts', style: {'font-size': '150%', 'font-weight': 'bold'}, height: 30},
        {html: 'Alert Attempts', style: {'font-size': '150%', 'font-weight': 'bold'}, height: 30},
        {html: 'Devices', style: {'font-size': '150%', 'font-weight': 'bold'}, height: 30},
        {html: 'Documents', style: {'font-size': '150%', 'font-weight': 'bold'}, height: 30},
        {html: 'Folders', style: {'font-size': '150%', 'font-weight': 'bold'}, height: 30},
        {html: 'Forums', style: {'font-size': '150%', 'font-weight': 'bold'}, height: 30},
        {html: 'Forum Topics', style: {'font-size': '150%', 'font-weight': 'bold'}, height: 30},
        {html: 'Folders', style: {'font-size': '150%', 'font-weight': 'bold'}, height: 30},
        {html: 'Groups', style: {'font-size': '150%', 'font-weight': 'bold'}, height: 30},
        {html: 'Invitations', style: {'font-size': '150%', 'font-weight': 'bold'}, height: 30},
        {html: 'Jurisdictions', style: {'font-size': '150%', 'font-weight': 'bold'}, height: 30},
        {html: 'Organizations', style: {'font-size': '150%', 'font-weight': 'bold'}, height: 30},
        {html: 'Organization Reqs', style: {'font-size': '150%', 'font-weight': 'bold'}, height: 30},
        {html: 'Roles', style: {'font-size': '150%', 'font-weight': 'bold'}, height: 30},
        {html: 'Role Requests', style: {'font-size': '150%', 'font-weight': 'bold'}, height: 30},
        {html: 'Role Memberships', style: {'font-size': '150%', 'font-weight': 'bold'}, height: 30},
        {html: 'Users', style: {'font-size': '150%', 'font-weight': 'bold'}, height: 30}
      ]
//TODO: add constraints - show only creates, updates, or deletes. (checkboxes)
    });

    this.resultsPanel = new Ext.grid.GridPanel({
      loadMask: true, region: 'center', store: this.resultsStore,
      colModel: new Ext.grid.ColumnModel({
        columns: [
          { id: 'date', dataIndex: 'created_at', header: 'date', sortable: true, width: 150, renderer:Ext.util.Format.dateRenderer('H:i:s  d M Y')},
          { id: 'model', dataIndex: 'item_type', header: 'Type', sortable: true, width: 100},
          { id: 'id', dataIndex: 'item_id', header: 'ID', sortable: false, width: 30},
          { id: 'descriptor', dataIndex: 'descriptor', header: 'Descriptor', sortable: false, width: 350},
//TODO: fix to allow sorting by descriptor/item_id.  See also:  show history for specific record.
          { id: 'action', dataIndex: 'event', header: 'Action', sortable: true, width: 100},
          { id: 'whodunnit', dataIndex: 'whodunnit', header: 'Whodunnit', sortable: true, width: 200},
          { id: 'id', dataIndex: 'id', header: 'Ver', sortable: true, width: 30}
        ]
      }),
      tbar: new Ext.PagingToolbar({
        pageSize: this.RESULTS_PAGE_SIZE,
        store: this.resultsStore,
        displayInfo: true,
        displayMsg: 'Displaying events {0} - {1} of {2}',
        emptyMsg: "No events"
      }),
      listeners: {
        scope: this,
        'cellclick': function(grid, row, column, e){
          this.resultsLoadMask.show();
          var record = grid.getStore().getAt(row);  // Get the Record
          this.getVersion(record.id)
        }
      }
    });

    this.selectedVersionDisplay = new Ext.Container({ html: '' });
    this.previousDisplay = new Ext.Container({ html: '' });
    this.currentDisplay = new Ext.Container({ html: '' });
    this.olderButton = new Ext.Button({
      text: '< Older',
      scope: this,
      handler: function(){
        this.getVersion(this.selectedVersion, 'older');
      }
    });
    this.newerButton = new Ext.Button({
      text: 'Newer >',
      scope: this,
      handler: function(){
        this.getVersion(this.selectedVersion, 'newer'); 
      }
    });

    this.selectedVersionPanel = new Ext.Panel({
      autoScroll: true,
      tbar: new Ext.Toolbar({items: [
        {xtype: 'tbtext', itemId: 'version_label', html: ''},
        {xtype: 'tbtext', itemId: 'version_count', html: ''},
        {xtype: 'button', text: 'Show Versions', scope: this, handler: function(){ this.showRecordVersions(); } } ,
        '->',
        this.olderButton,
        this.newerButton
      ]}),
      border: false, flex: 1,
      items: [ this.selectedVersionDisplay ]
    });

    this.versionTabs = new Ext.TabPanel({
      activeTab: 0,  border: false,
      deferredRender: false,
// TODO: this is tricky, hidden tabs don't get updated until they've been shown once
      flex: 1,
      items: [
        {title: 'Previous Version',autoScroll: true, items: [this.previousDisplay]},
        {title: 'Current Version', autoScroll: true, items: [this.currentDisplay]}
      ]
    });

    this.recordView = new Ext.Panel({
      layout: 'hbox',
      region: 'south',
      height: 200,
      border: false,
      autoScroll: true,
      split: true,
      layoutConfig: { align : 'stretch' },
      items: [
        this.selectedVersionPanel,
        this.versionTabs
      ],
      listeners: {
        'afterrender' : {
          delay:1,
          scope: this,
          fn: function(){ this.resultsLoadMask = new Ext.LoadMask( this.recordView.getEl(), {msg:"Fetching version data..."} );}
        }
      }
    });

    this.primary_panel = new Ext.Panel({
      layout: 'border', title: config.title, itemId: config.id, closable: true,
      items: [
        this.resultsPanel,
        this.modelSelector,
        this.recordView
      ]
    });

    this.getPanel = function(){
      return this.primary_panel;
    };
  },  //end constructor

  getVersion: function(versionId, step){
    this.resultsLoadMask.show();
    var params = { 'id': versionId, 'authenticity_token': FORM_AUTH_TOKEN, 'step': step };
    Ext.Ajax.request({
//TODO: pull this from some sort of caching store system (JsonReader)
      url: '/audits/'+ versionId +'.json', method: 'GET', scope: this,
      params: params,
      success: function(response){
        this.resultsLoadMask.hide();
        var versionData = Ext.util.JSON.decode(response.responseText);
        this.selectedVersion = versionData.requested_version_id;
        this.updateVersionDisplay(versionData);
      },
      failure: function(){ this.resultsLoadMask.hide(); }
    });
  },

  updateVersionDisplay: function(versionData){
    this.selectedVersionPanel.getTopToolbar().getComponent('version_count').update(versionData.version_count + " versions total");
    this.selectedVersionPanel.getTopToolbar().getComponent('version_label').update('Record '+ this.selectedVersion +': "' + versionData.descriptor +'"');

    if (versionData.requested_version[0] !== 'none'){
      this.selectedVersionDisplay.update( this.versionTemplate.apply(versionData.requested_version) );
    } else {
      this.selectedVersionDisplay.update(this.versionTemplate.apply([["Initial create/update",""]]));
    }

    if (versionData.previous_version[0] !== 'none'){
      this.olderButton.enable();
      this.previousDisplay.update( this.versionTemplate.apply(versionData.previous_version) );
    } else {
      this.olderButton.disable();
      this.previousDisplay.update(this.versionTemplate.apply([['No older version available','']]));
    }
    
    if (versionData.current_version[0] !== 'none'){
      this.currentDisplay.update( this.versionTemplate.apply(versionData.current_version) );
    } else {
      this.currentDisplay.update(this.versionTemplate.apply([['This record no longer exists','']]));
    }
  },

  versionTemplate: new Ext.XTemplate(
    '<table cellspacing="10">'+
    '<tpl for="."><tr><td>{[values[0]]}</td><td>{[values[1]]}</td></tr></tpl>'+
    '</table>'
  )
});

Talho.AuditLog.initialize = function(config){
    var audit_log_panel = new Talho.AuditLog(config);
    return audit_log_panel.getPanel();
};

Talho.ScriptManager.reg('Talho.AuditLog', Talho.AuditLog, Talho.AuditLog.initialize);


