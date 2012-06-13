//= require ext_extensions/AjaxPanel
//= require_self

Ext.ns("Talho");

Talho.AuditLog = Ext.extend(Ext.util.Observable, {
  constructor: function(config){
    Talho.AuditLog.superclass.constructor.call(this, config);

    this.RESULTS_PAGE_SIZE = 30;

    this.resultsStore = new Ext.data.JsonStore({ // Stores the main list of versions
      url: '/audits.json', method: 'GET', restful: true, root: 'versions', totalProperty: 'total_count', autoLoad: true, remoteSort: true,
      fields: [ 'id', 'item_type', 'item_id', 'item_desc', 'event', 'whodunnit', 'created_at' ],
      listeners: { scope: this, 'beforeload' : this.applyModelSelections  }
    });

    this.selectionCache = new Ext.data.SimpleStore({ fields: ['id','data'] }); // Stores previously requested version data, preventing redundant ajax requests.

    this.selectionStore =  new Ext.data.SimpleStore({ fields: ['attribute_name', 'selected_version', 'previous_version', 'next_version', 'current_version'] }); // Holds the currently selected version data

    this.modelStore = new Ext.data.JsonStore({ url: '/audits/models.json', method: 'GET', restful: true, root: 'models', autoLoad: true, fields:['model_name', 'human_name'] });

    this.modelList = new Ext.list.ListView({
      region: 'center', store: this.modelStore, multiSelect: true, simpleSelect:true, columnSort: false, hideHeaders: true, style: { 'background-color': 'white'},
      loadingText: 'Fetching list...',  emptyText: 'Error:  Could not retrieve list', deferEmptyText: true,
      columns: [{ dataIndex: 'human_name', cls: 'model-selector-list-item'}],
      listeners: { scope: this, 'selectionchange' : function(){ this.resultsStore.load(); } }
    });

    this.checkboxShowCreate = new Ext.form.Checkbox({ boxLabel: 'Create', checked: true, listeners:{ scope: this, 'check': function(){ this.checkEventBoxes(); this.resultsStore.load(); } } });
    this.checkboxShowUpdate = new Ext.form.Checkbox({ boxLabel: 'Update', checked: true, listeners:{ scope: this, 'check': function(){ this.checkEventBoxes(); this.resultsStore.load(); } } });
    this.checkboxShowDestroy = new Ext.form.Checkbox({ boxLabel: 'Destroy', checked: true, listeners:{ scope: this, 'check': function(){ this.checkEventBoxes(); this.resultsStore.load(); } } });

    this.actionSelector = new Ext.Panel({
      region: 'south', height: 30, layout: 'hbox', border: false, style: {'borderTop': '1px lightgray solid'}, padding: 5,
      items: [ this.checkboxShowCreate, {xtype: 'spacer', width: '6'}, this.checkboxShowUpdate, {xtype: 'spacer', width: '6'}, this.checkboxShowDestroy ]  // Dirty workaround to get the margins right.
    });

    this.selectorPanel = new Ext.Panel({
      cls: 'panel-version-selector', autoScroll: true, region: 'west', width: 200, margins: '5 5 0 5', layout: 'border',
      tbar: new Ext.Toolbar({items: [
        {xtype: 'tbtext', name: 'hdr', html: 'Log Filters'}, '->',
        {xtype: 'button', text: 'Reset', scope: this, handler: function(){ (this.modelList.getSelectionCount() == 0) ? this.modelList.fireEvent('selectionchange') : this.modelList.clearSelections();  }}
      ]}),
      items: [ this.modelList, this.actionSelector ]
    });

    this.resultsPanel = new Ext.grid.GridPanel({
      cls: 'grid-version-results', loadMask: true, region: 'center',  margins: '5 5 0 0',  store: this.resultsStore,
      colModel: new Ext.grid.ColumnModel({
        columns: [
          { id: 'date', dataIndex: 'created_at', header: 'date', sortable: true, width: 130},
          { id: 'model', dataIndex: 'item_type', header: 'Type', sortable: true, width: 100},
          { id: 'id', dataIndex: 'item_id', header: 'ID', sortable: true, width: 30},
          { id: 'descriptor', dataIndex: 'item_desc', header: 'Descriptor', sortable: true, width: 330},
          { id: 'action', dataIndex: 'event', header: 'Action', sortable: true, width: 50},
          { id: 'whodunnit', dataIndex: 'whodunnit', header: 'Whodunnit', sortable: true, width: 200},
          { id: 'id', dataIndex: 'id', header: 'Event ID', sortable: true, width: 60}
        ]
      }),
      tbar: new Ext.PagingToolbar({ pageSize: this.RESULTS_PAGE_SIZE, store: this.resultsStore, displayInfo: true,  displayMsg: 'Displaying Events {0} - {1} of {2}',  emptyMsg: "No events" }),
      listeners: { scope: this,
        'cellclick': function(grid, row){
          var record = grid.getStore().getAt(row);
          this.getVersion({'id': record.id});
        }
      }
    });

    this.selectedVersionDisplay = new Ext.grid.GridPanel({
      cls: 'grid-version-display', viewConfig: { forceFit: true }, store: this.selectionStore,
      colModel: new Ext.grid.ColumnModel({
        columns: [
          { id: 'attribute-name', dataIndex: 'attribute_name', header: 'Attribute', sortable: true, defaultWidth: 180 },
          { id: 'previous-version', dataIndex: 'previous_version', header: 'Previous Version', sortable: false, width: 180 },
          { id: 'selected-version', dataIndex: 'selected_version', header: 'This Version', sortable: false, width: 180},
          { id: 'next-version', dataIndex: 'next_version', header: 'Next Version', sortable: false, width: 180 },
          { id: 'current-version', dataIndex: 'current_version', header: 'Current Version', sortable: false, width: 180 }
        ]
      })
    });

    this.olderButton = new Ext.Button({ text: '< Older', scope: this, disabled: true });
    this.newerButton = new Ext.Button({ text: 'Newer >', scope: this, disabled: true });
    this.versionButton = new Ext.Button({ text: 'Show Versions', scope: this, disabled: true, handler: function(){ this.showRecordVersions(this.selectedVersionId); } });
    this.versionRefreshButton = new Ext.Button({ text: 'Force Refresh', disabled: true });

    this.selectedVersionPanel = new Ext.Panel({
      cls: 'panel-version-display', region: 'south', height: 250, layout: 'fit', margins: '0 5 5 5',  autoScroll: true,  border: false, split: true,
      tbar: new Ext.Toolbar({ items: [
        {xtype: 'tbtext', itemId: 'version_label', html: ''}, {xtype: 'tbtext', itemId: 'version_count', html: ''}, '->',
        this.versionButton, this.versionRefreshButton, this.olderButton, this.newerButton
      ]}),
      items: [ this.selectedVersionDisplay ],
      listeners: { 'afterrender': { delay:1, scope: this, fn: function(){ this.resultsLoadMask = new Ext.LoadMask( this.selectedVersionPanel.getEl(), {msg:"Fetching version data..."} ); } } }
    });

    this.primary_panel = new Ext.Panel({
      layout: 'border', title: config.title, itemId: config.id, closable: true,
      items: [this.resultsPanel, this.selectorPanel, this.selectedVersionPanel]
    });

    this.getPanel = function(){ return this.primary_panel; };
  },

  //===== end constructor =====//

  applyModelSelections : function(){
    var selected_models = this.modelList.getSelectedRecords();
    if ( selected_models.length > 0 ){
      var models = [];
      for (var i = 0; i < selected_models.length; i++){
        models.push(selected_models[i].data.model_name);
      }
      this.resultsStore.setBaseParam('models[]', models );
    } else {
      this.resultsStore.setBaseParam('models[]', null );
    }
    var event = [];
    if (this.checkboxShowCreate.getValue()){ event.push('create'); }
    if (this.checkboxShowUpdate.getValue()){ event.push('update'); }
    if (this.checkboxShowDestroy.getValue()){ event.push('destroy'); }
    (event.length < 3) ? this.resultsStore.setBaseParam('event[]', event ) : this.resultsStore.setBaseParam('event[]', null );
    return true;
  },

  addToCache: function(v){
    var rec = new this.selectionCache.recordType(v, v.requested_version_id);
    this.selectionCache.add(rec);
  },

  checkCacheAndPrefetch: function(vIds){      // accepts an array of versionIds and caches them if they aren't already.
    for (var i = 0; i < vIds.length; i++){
      if (vIds[i] && !this.selectionCache.getById(vIds[i])){
        this.getVersion({'id': vIds[i], 'cache_only': true});
      }
    }
  },

  handleFetchedVersionData: function(response, cache_only){
    var versionData = Ext.util.JSON.decode(response.responseText);
    if (versionData['success']) {
      this.selectedVersionId = versionData['versions']['requested_version'].requested_version_id;
      for (var v in versionData['versions']){ this.addToCache(versionData['versions'][v]); }
      if (!cache_only){
        this.updateVersionDisplay(versionData['versions']['requested_version']);
        this.checkCacheAndPrefetch([versionData['versions']['requested_version'].newer_id, versionData['versions']['requested_version'].older_id]);
      }
    }
  },

  handleCachedVersionData: function(versionData, cache_only){
      this.selectedVersionId = versionData.requested_version_id;
      if (!cache_only){
        this.updateVersionDisplay(versionData);
        this.checkCacheAndPrefetch([versionData.newer_id, versionData.older_id]);
      }
  },

  getVersion: function(options){   // options:  id (required), force_refresh to ignore cached version, cache_only to fetch and cache but not update display  
    if (!options.cache_only){ this.resultsLoadMask.show(); }
    if (!options.force_refresh){ var cachedVersion = this.selectionCache.getById(options.id); }
    if (cachedVersion === undefined || cachedVersion === 'loading'){
      this.lastVersionRequest = Ext.Ajax.request({
        url: '/audits/'+ options.id +'.json', method: 'GET', scope: this,
        success: function(response){ this.handleFetchedVersionData(response, options.cache_only); },
        failure: function(){ this.selectedVersionPanel.getEl().mask("Server error.  Please try again.");  }
      });
    } else {
      this.handleCachedVersionData(cachedVersion['data'], options.cache_only);
    }
  },

  checkEventBoxes: function(){   // prevents user from selecting zero checkboxes
        // TODO: would a checkboxGroup clean this up?
    var checked_boxes = [];
    if (this.checkboxShowCreate.getValue()){ checked_boxes.push('create'); }
    if (this.checkboxShowUpdate.getValue()){ checked_boxes.push('update'); }
    if (this.checkboxShowDestroy.getValue()){ checked_boxes.push('destroy'); }
    if (checked_boxes.length === 1){
      switch(checked_boxes[0]){
        case 'create': this.checkboxShowCreate.disable(); break;
        case 'update': this.checkboxShowUpdate.disable(); break;
        case 'destroy': this.checkboxShowDestroy.disable(); break;
      }
    } else {
      this.checkboxShowCreate.enable();
      this.checkboxShowUpdate.enable();
      this.checkboxShowDestroy.enable();
    }
  },

  updateVersionDisplay: function(versionData){
    this.selectionStore.loadData(versionData.diff_list);
    var version_rowid = this.resultsStore.indexOfId(this.selectedVersionId);
    var sel_model = this.resultsPanel.getSelectionModel();
    sel_model.clearSelections();
    if ( version_rowid !== -1 ){ sel_model.selectRow(version_rowid, false); }   // if the correct row is visible
    this.versionButton.setText("Event " + versionData.version_index + " of " + versionData.version_count );
    this.selectedVersionPanel.getTopToolbar().getComponent('version_label').update( 'Event ID '+ this.selectedVersionId + ' : ' + versionData.event + ' ' + versionData.model + ' "' + versionData.descriptor +'"');
    var col_model = this.selectedVersionDisplay.getColumnModel();
    if (versionData['older_id']) {
      this.olderButton.purgeListeners();
      this.olderButton.on('click', function(){ this.getVersion({'id': versionData['older_id']})}, this);
      this.olderButton.enable();
      col_model.setHidden( col_model.findColumnIndex('previous_version') , false );
    } else {
      this.olderButton.disable();
      col_model.setHidden( col_model.findColumnIndex('previous_version') , true );
    }
    if (versionData['newer_id']) {
      this.newerButton.purgeListeners();
      this.newerButton.on('click', function(){ this.getVersion({'id': versionData['newer_id']}) }, this);
      this.newerButton.enable();
      col_model.setHidden( col_model.findColumnIndex('next_version') , false );
    } else {
      this.newerButton.disable();
      col_model.setHidden( col_model.findColumnIndex('next_version') , true );
    }
    (versionData['deleted']) ? col_model.setHidden( col_model.findColumnIndex('current_version') , true ) : col_model.setHidden( col_model.findColumnIndex('current_version') , false );
    this.versionRefreshButton.enable();
    this.versionRefreshButton.purgeListeners();
    this.versionRefreshButton.on('click', function(){ this.getVersion({'id': this.selectedVersionId, 'force_refresh': true})}, this);
    col_model.setColumnWidth(col_model.findColumnIndex('attribute_name'), 180);   // ...and I mean it.
    this.versionButton.enable();
    this.resultsLoadMask.hide();
  },

  showRecordVersions: function(version_id){
    this.modelList.clearSelections(true);
    this.resultsStore.load({'params': {'show_versions_for' : version_id } });
  }
});

Talho.AuditLog.initialize = function(config){
    var audit_log_panel = new Talho.AuditLog(config);
    return audit_log_panel.getPanel();
};

Talho.ScriptManager.reg('Talho.AuditLog', Talho.AuditLog, Talho.AuditLog.initialize);