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
      remoteSort: true,
      listeners: {
        scope: this,
        'beforeload' : this.applySelectedModels
      }
    });

    this.selectionStore =  new Ext.data.SimpleStore({
      fields: [ 'attribute_name', 'selected_version', 'previous_version', 'next_version', 'current_version' ]
    });

    this.modelStore = new Ext.data.JsonStore({
      url: '/audits/models.json',
      method: 'GET',
      restful: true,
      root: 'models',
      fields: [ 'name', 'model_name'],
      autoLoad: true
    });

    this.modelList = new Ext.list.ListView({
      region: 'center',
      store: this.modelStore,
      multiSelect: true,   simpleSelect: true,  columnSort: false,
      loadingText: 'Fetching list...',  emptyText: 'Error:  Could not retrieve list',
      deferEmptyText: true, hideHeaders: true,
      style: { 'background-color': 'white'},
      columns: [{ dataIndex: 'name', cls: 'upload-audience-list-item'}],
      listeners :{
        scope: this,
        'selectionchange' : function(){ this.resultsStore.load(); }
      }
    });

    this.checkboxShowCreate = new Ext.form.Checkbox({ boxLabel: 'Create', checked: true, listeners:{ scope: this, 'check': function(){ this.checkEventBoxes(); this.resultsStore.load(); } } });
    this.checkboxShowUpdate = new Ext.form.Checkbox({ boxLabel: 'Update', checked: true, listeners:{ scope: this, 'check': function(){ this.checkEventBoxes(); this.resultsStore.load(); } } });
    this.checkboxShowDestroy = new Ext.form.Checkbox({ boxLabel: 'Destroy', checked: true, listeners:{ scope: this, 'check': function(){ this.checkEventBoxes(); this.resultsStore.load(); } } });

    this.actionSelector = new Ext.Panel({
      region: 'south',
      height: 30,
      layout: 'hbox',
      border: false,
      style: {'borderTop': '1px lightgray solid'},
      padding: 5,
      items: [
        this.checkboxShowCreate,
        {xtype: 'spacer', width: '6'},  // CSS applied to checkbox seems to only affect the box, and not the label.  This is a dirty workaround to get the margins right.
        this.checkboxShowUpdate,
        {xtype: 'spacer', width: '6'},
        this.checkboxShowDestroy
      ]
    });

    this.selectorPanel = new Ext.Panel({
      autoScroll: true,
      region: 'west',
      width: 200,
      margins: '5 5 0 5',
      layout: 'border',
      tbar: new Ext.Toolbar({items: [
        {xtype: 'tbtext', name: 'hdr', html: 'Log Filters'}, '->',
        {xtype: 'button', text: 'Reset', scope: this, handler: function(){ this.modelList.clearSelections(); }}
      ]}),
      items: [
        this.modelList,
        this.actionSelector
      ]
    });

    this.resultsPanel = new Ext.grid.GridPanel({
      loadMask: true, region: 'center', margins: '5 5 0 0', 
      store: this.resultsStore,
      colModel: new Ext.grid.ColumnModel({
        columns: [
          { id: 'date', dataIndex: 'created_at', header: 'date', sortable: true, width: 130, renderer:Ext.util.Format.dateRenderer('H:i:s  d M Y')},
          { id: 'model', dataIndex: 'item_type', header: 'Type', sortable: true, width: 100},
          { id: 'id', dataIndex: 'item_id', header: 'ID', sortable: false, width: 30},
          { id: 'descriptor', dataIndex: 'descriptor', header: 'Descriptor', sortable: false, width: 350},
                //TODO: fix to allow sorting by descriptor/item_id.
          { id: 'action', dataIndex: 'event', header: 'Action', sortable: true, width: 50},
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
        'cellclick': function(grid, row){
          var record = grid.getStore().getAt(row); 
          this.getVersion(record.id)
        }
      }
    });

    this.selectedVersionDisplay = new Ext.grid.GridPanel({
      viewConfig: { forceFit: true },
      store: this.selectionStore,
      colModel: new Ext.grid.ColumnModel({
        columns: [
          { id: 'attribute-name', dataIndex: 'attribute_name', header: 'Attribute', sortable: false, width: 180 },
          { id: 'previous-version', dataIndex: 'previous_version', header: 'Previous Version', sortable: false, width: 180 },
          { id: 'selected-version', dataIndex: 'selected_version', header: 'Version', sortable: false, width: 180 },          
          { id: 'next-version', dataIndex: 'next_version', header: 'Next Version', sortable: false, width: 180 },
          { id: 'current-version', dataIndex: 'current_version', header: 'Current Version', sortable: false, width: 180 }
        ]
      })
    });

    this.olderButton = new Ext.Button({
      text: '< Older', scope: this, disabled: true,
      handler: function(){ this.getVersion(this.selectedVersion, 'older'); }
    });
    this.newerButton = new Ext.Button({
      text: 'Newer >', scope: this, disabled: true,
      handler: function(){ this.getVersion(this.selectedVersion, 'newer'); }
    });
    this.versionButton = new Ext.Button({
      text: 'Show Versions', scope: this, disabled: true,
      handler: function(){
        this.showRecordVersions(this.selectedVersion);
      }
    });

    this.selectedVersionPanel = new Ext.Panel({
      region: 'south', height: 200, layout: 'fit', margins: '0 5 5 5',  autoScroll: true,  border: false, split: true,
      tbar: new Ext.Toolbar({items: [
        {xtype: 'tbtext', itemId: 'version_label', html: ''},
        {xtype: 'tbtext', itemId: 'version_count', html: ''},
        '->',
        this.versionButton,
        this.olderButton,
        this.newerButton
      ]}),
      items: [ this.selectedVersionDisplay ],
      listeners: {
        'afterrender' : {
          delay:1, scope: this,
          fn: function(){ this.resultsLoadMask = new Ext.LoadMask( this.selectedVersionPanel.getEl(), {msg:"Fetching version data..."} );}
        }
      }
    });

    this.primary_panel = new Ext.Panel({
      layout: 'border', title: config.title, itemId: config.id, closable: true,
      items: [
        this.resultsPanel,
        this.selectorPanel,
        this.selectedVersionPanel
      ]
    });

    this.getPanel = function(){
      return this.primary_panel;
    };
  },  //end constructor

  applySelectedModels : function(){
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
    if (event.length < 3){
      this.resultsStore.setBaseParam('event[]', event );
    } else {
      this.resultsStore.setBaseParam('event[]', null );
    }
    return true;
  },

  getVersion: function(versionId, step){
    this.resultsLoadMask.show();
        //TODO: work up some sort of caching store system to avoid repeat queries
    var params = { 'id': versionId, 'authenticity_token': FORM_AUTH_TOKEN, 'step': step };
    Ext.Ajax.request({
      url: '/audits/'+ versionId +'.json', method: 'GET', scope: this,
      params: params,
      success: function(response){
        var versionData = Ext.util.JSON.decode(response.responseText);
        this.selectedVersion = versionData.requested_version_id;
        this.updateVersionDisplay(versionData);
        this.selectionStore.loadData(versionData['diff_list']);
      },
      failure: function(){
         this.selectedVersionPanel.getEl().mask("Server error.  Please try again.");
      }
    });
  },

  checkEventBoxes: function(checkbox, checked){
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
    var rowid = this.resultsStore.indexOfId(this.selectedVersion);
    var sel_model = this.resultsPanel.getSelectionModel();
    if (this.resultsStore.indexOfId(sel_model.getSelected().id) !== rowid){  // if the correct row isn't already selected
      if ( rowid !== -1 ){
        sel_model.selectRow(rowid, false);
      } else {
        sel_model.clearSelections();
      }
    }
    this.versionButton.setText("Version " + versionData.version_index + " of " + versionData.version_count );
    this.selectedVersionPanel.getTopToolbar().getComponent('version_label').update('Record '+ this.selectedVersion + ' : ' + versionData.event + ' ' + versionData.model + ' "' + versionData.descriptor +'"');
    var col_model = this.selectedVersionDisplay.getColumnModel();
    if (versionData['oldest']) {
      this.olderButton.disable();
      col_model.setHidden( col_model.findColumnIndex('previous_version') , true )
    } else {
      this.olderButton.enable();
      col_model.setHidden( col_model.findColumnIndex('previous_version') , false )
    }
    if (versionData['newest']) {
      this.newerButton.disable();
      col_model.setHidden( col_model.findColumnIndex('next_version') , true )
    } else {
      this.newerButton.enable();
      col_model.setHidden( col_model.findColumnIndex('next_version') , false )
    }
    if (versionData['deleted']) {
      col_model.setHidden( col_model.findColumnIndex('current_version') , true )
    } else {
      col_model.setHidden( col_model.findColumnIndex('current_version') , false )
    }
    this.versionButton.enable();
    this.resultsLoadMask.hide();
  },

  showRecordVersions: function(version_id){
    this.modelList.clearSelections(true);
    this.resultsStore.load({'params': {'show_versions_for' : version_id } });
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