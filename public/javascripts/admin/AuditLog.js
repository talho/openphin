Ext.ns("Talho");

Talho.AuditLog = Ext.extend(Ext.util.Observable, {
  constructor: function(config){
    Talho.AuditLog.superclass.constructor.call(this, config);

    this.RESULTS_PAGE_SIZE = 15;

    this.resultsStore = new Ext.data.JsonStore({
      url: '/audits.json',
      method: 'POST',
      root: 'versions',
      totalProperty: 'total_count',
      fields: [ 'id', 'item_type','item_id', 'descriptor', 'event', 'whodunnit', 'object', { name: 'created_at', type: 'date'} ],
      autoLoad: true,
      remoteSort: true
    });

    this.modelSelector = new Ext.Container({
      //TODO: this should do a thing.
      region: 'west', width: 100,
      items: [
       // {html: 'All', style: {'font-size': '150%', 'font-weight': 'bold'}, height: 30},
        {html: 'Users', style: {'font-size': '150%', 'font-weight': 'bold'}, height: 30}
       //{html: 'Alerts', style: {'font-size': '150%', 'font-weight': 'bold'}, height: 30}
      ]
      //TODO: add constraints - show only creates, updates, or deletes. (checkboxes)
    });

    this.resultsPanel = new Ext.grid.GridPanel({
      loadMask: true, region: 'center', store: this.resultsStore,
      colModel: new Ext.grid.ColumnModel({
        columns: [
          { id: 'date', dataIndex: 'created_at', header: 'date', sortable: true, width: 150, renderer:Ext.util.Format.dateRenderer('H:i:s  d M Y')},
          { id: 'model', dataIndex: 'item_type', header: 'Model', sortable: true, width: 100},
          { id: 'descriptor', dataIndex: 'descriptor', header: 'Record', sortable: true, width: 300},
                //TODO: fix to allow sorting by descriptor.  See also:  show history for specific record.
          { id: 'action', dataIndex: 'event', header: 'Action', sortable: true, width: 100},
          { id: 'whodunnit', dataIndex: 'whodunnit', header: 'Whodunnit', sortable: true, width: 300}
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

    this.selectedVersionPanel = new Ext.Panel({
      autoScroll: true,
      tbar: new Ext.Toolbar({items: [
        {xtype: 'tbtext', itemId: 'version_label', html: ''},
        {xtype: 'tbtext', itemId: 'version_count', html: ''},
        {xtype: 'button', text: 'Show Versions', scope: this, handler: function(){ this.showRecordVersions(); } } ,
        '->',
        {xtype: 'button', itemId:'olderButton', text: '< Older', scope: this, handler: function(){ this.getVersion(this.selectedVersion, 'older'); } },
        {xtype: 'button', itemId:'newerButton', text: 'Newer >', scope: this, handler: function(){ this.getVersion(this.selectedVersion, 'newer'); } }
      ]}),
      border: false, flex: 1,
      items: [ this.selectedVersionDisplay ]
    });

    this.versionTabs = new Ext.TabPanel({
      activeTab: 0,  border: false,
      deferredRender: false,
      // TODO: this is broken in current EXT, hidden tabs don't get updated until they've been shown once
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
      url: '/audits.json', method: 'POST', scope: this,
      params: params,
      success: function(response){
        this.resultsLoadMask.hide();
        var versionData = Ext.util.JSON.decode(response.responseText);
        this.selectedVersion = versionId;
        this.updateVersionDisplay(versionData);
      },
      failure: function(){ this.resultsLoadMask.hide(); }
    });
  },

  updateVersionDisplay: function(versionData){
    this.selectedVersionPanel.getTopToolbar().getComponent('version_count').update(versionData.version_count + " versions total");
    this.selectedVersionPanel.getTopToolbar().getComponent('version_label').update('Record: "' + versionData.descriptor +'"');
    if (versionData.requested_version[0] !== 'none'){
      this.selectedVersionDisplay.update( this.versionTemplate.apply(versionData.requested_version) );
    } else {
      this.selectedVersionDisplay.update(this.versionTemplate.apply([["Initial create/update",""]]));
    }
    if (versionData.previous_version[0] !== 'none'){
      this.previousDisplay.update( this.versionTemplate.apply(versionData.previous_version) );
    } else {
      this.selectedVersionPanel.getComponent('olderButton').disable();
      this.previousDisplay.update(this.versionTemplate.apply([['No older version','']]));
    }
    if (versionData.current_version[0] !== 'none'){ 
      this.currentDisplay.update( this.versionTemplate.apply(versionData.current_version) );
    } else {
      this.currentDisplay.update(this.versionTemplate.apply([['Record deleted','']]));
    }
    if {
            this.selectedVersionPanel.getComponent('newerButton').disable();
    }
  },

  versionTemplate: new Ext.XTemplate(
          //TODO: add header with Record info.  (total versions count, button to show only this record's versions, step though with <prev and next>
    '<table cellspacing="10">'+
    '<tpl for="."><tr><td>{[values[0]]}</td><td>{[values[1]]}</td></tr></tpl>'+
    '</table>'
  )
});

/**
 * Initializer for the AuditLog object. Returns a panel
 */
Talho.AuditLog.initialize = function(config){
    var audit_log_panel = new Talho.AuditLog(config);
    return audit_log_panel.getPanel();
};

Talho.ScriptManager.reg('Talho.AuditLog', Talho.AuditLog, Talho.AuditLog.initialize);


