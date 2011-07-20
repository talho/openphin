Ext.ns('Talho');

Talho.Reports = Ext.extend(Ext.util.Observable, {
  constructor: function(config){
    Talho.Reports.superclass.constructor.call(this, config);

    this.recipesStore = new Ext.data.JsonStore({
      url: '/report/recipes.json',
      restful: true,
      root: 'recipes',
      fields: ['id','type','type_humanized','description'],
      autoLoad: true
    });

    this.RESULTS_PAGE_SIZE = 10;
    this.reportsStore = new Ext.data.JsonStore({
      url: '/report/reports.json',
      restful: true,
      root: 'reports',
      fields: [ 'id','recipe','report_path','dataset_updated_at','rendering_updated_at','rendering_file_size','incomplete' ],
      autoLoad: true,
      remoteSort: true,
      baseParams: {'limit': this.RESULTS_PAGE_SIZE, 'authenticity_token': FORM_AUTH_TOKEN},
      listeners: {
        scope: this,
        'exception': function(){this.handleError;},
		'load': function(store){this.reportsStoreRefresher(store);}
      }
    });

    this.recipeList = new Ext.list.ListView({
      store: this.recipesStore,
      singleSelect: true,
      columnSort: false,
      loadingText: 'Fetching recipe list...',
      emptyText: 'Error:  Could not retrieve Recipes',
      deferEmptyText: true,
      hideHeaders: true,
      style: { 'background-color': 'white'},
      columns: [{ dataIndex: 'type_humanized', cls: 'recipe-list-item'}],
      listeners: {
      	scope:this,
      	'selectionchange': function(d,r){
      	 	this.recipeSelected(r); 
      	}}
    });

    this.recipeListPanel = new Ext.Panel({
      cls: 'report-recipe-select',
      region: 'center',
      autoScroll: true,
	    tbar: new Ext.Toolbar({items: [
        {xtype: 'tbtext', name: 'hdr', html: 'Recipes'}, '->',
        {xtype: 'button', text: 'Clear', scope: this, handler: function(){ this.recipeList.clearSelections(); }}
      ]}),
      items: [ this.recipeList ]
	});

    this.recipeDescriptor = new Ext.Panel ({
      region: 'south',
      margins: '5 0 0 0',
      padding: 5,
      autoScroll: true,
      height: 100,
      title: 'Description',
      //cls: 'find-reports-recipe-descriptor',
      html: 'recipe description'
    });

    this.numSlider = new Ext.Slider({
      width: 200,
      value: 50,
      increment: 10,
      minValue: 0,
      maxValue: 100
    });
    this.sidebarPanel = new Ext.Panel({
      layout: 'border',
      border: false,
      items: [
        this.recipeListPanel,
        this.numSlider,
        this.recipeDescriptor
      ]
    });

    this.generateReportButton = new Ext.Button({
        text: 'No Recipe Selected', scope: this,
        handler: function(){
          this.updateReportResults()},
        disabled: true
    });

    this.recipeSidebar = new Ext.Panel({
      region: 'west',
      width: 300,
      border: false,
      fill: true,
      margins: '5 5 5 5',
	  layout: 'fit',
	  items:[this.sidebarPanel],
      buttonAlign : 'center',
      buttons: [this.generateReportButton ]
    });

    this.reportResults = new Ext.grid.GridPanel({
      cls: 'report-results',
      store: this.reportsStore,
      colModel: new Ext.grid.ColumnModel({
        defaults: {sortable: true},
        columns: [
          { id: 'report-id', dataIndex: 'id', header: 'Report ID' },
          { id: 'report-recipe', dataIndex: 'recipe', header: 'Recipe' },
          { id: 'generated-at', dataIndex: 'dataset_updated_at', header: 'Generated at' },
          { id: 'rendered-at', dataIndex: 'rendering_updated_at', header: 'Rendered at' },
          { id: 'render-size', dataIndex: 'rendering_file_size', header: 'Render size' }
         ]
      }),
		viewConfig: {
          forceFit: true,
          getRowClass: function(record, index) {
            if (record.get('incomplete')) { return 'report-incomplete'; }
          }
        },
	    listeners:{
        scope: this,
        'rowclick': function(grid, rowIndex){
          var record = grid.getStore().getAt(rowIndex);
          this.openViewTab(record);
        }
	    }
    });

    this.reportResultsContainer = new Ext.Panel({
      region: 'center',
      frame: false,
      layout: 'fit',
      border: true,
      bodyBorder: false,
      margins: '5 5 5 0',
      padding: '0',
      items: [
        this.reportResults
      ],
      tbar: new Ext.PagingToolbar({
        pageSize: this.RESULTS_PAGE_SIZE,
        store: this.reportsStore,
        displayInfo: true,
        displayMsg: 'Displaying results {0} - {1} of {2}',
        emptyMsg: "No results"
      })
    });

    this.primary_panel = new Ext.Panel({
      layout:'border',
      itemId: config.id,
      closable: true,
      items: [
        this.recipeSidebar,
        this.reportResultsContainer
      ],
      title: config.title
    });

    this.getPanel = function(){ return this.primary_panel; };
  },

  REPORT_REFRESH_INTERVAL: 10000,
  REPORT_REFRESH_MAXIMUM: 30,

  reportsStoreRefresher: function(store){
	if (this.report_refresher) {
	  clearInterval(this.report_refresher);
    } else {
	  this.report_refresh_count = 0;
    }
	if (store.query('incomplete',"true") && this.report_refresh_count < this.REPORT_REFRESH_MAXIMUM ){
      //make a copy of 'this' to pass into the interval timer
	  var inst = this;
	  this.report_refresher = setInterval(function(){ inst.reportsStore.load(); },this.REPORT_REFRESH_INTERVAL);
	  this.report_refresh_count += 1;
	} else {
	  this.report_refresh_count = 0;
    }
  },


  handleError: function(proxy, type, action, options, response, arg){
    this.show_err_message(Ext.decode(response.responseText));
    this.reportResultsContainer.layout.setActiveItem(3); // search_error
  },

  recipeSelected: function(selected_rows){
  	if (selected_rows.length > 0) {
	  this.recipeDescriptor.update( this.recipeList.getRecord(selected_rows[0]).data.description );
      this.generateReportButton.setText('Generate Report');
      this.generateReportButton.enable();
  	} else {
	    this.recipeDescriptor.update( 'recipe description' );
  	  this.generateReportButton.disable();
      this.generateReportButton.setText('No Recipe Selected');
  	}
  },

  ajax_err_cb: function(response, opts) {
    var msg = '<b>Status: ' + response.status + ' => ' + response.statusText + '</b><br><br>' +
      '<div style="height:400px;overflow:scroll;">' + response.responseText + '<\div>';
    Ext.Msg.show({title: 'Error', msg: msg, minWidth: 900, maxWidth: 900, buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR});
  },
  
  openViewTab: function(record){
    Application.fireEvent('opentab', {
      title: 'Report: '+record.get('recipe')+'-'+record.get('id'), 
      url: record.get('report_path'), 
      id: 'report_view_for_' + record.get('id'), 
      initializer: 'Talho.ReportView' 
     });
  },

  updateReportResults: function(form, action) {
    this.generateReportButton.setText('Report being scheduled');
    this.generateReportButton.disable();
  	Ext.Ajax.request({
  	   url: '/report/reports.json',
  	   method: 'POST',
  	   scope:  this,
  	   params: { 'recipe_type': this.recipeList.getSelectedRecords()[0].json.type },
       success: function(){this.reportsStore.load();this.generateReportButton.setText('Generate Report');this.generateReportButton.enable();},
  	   failure: function(){this.ajax_err_cb}
  	});  	
//	this.reportResults.getView().refresh();
//	var selection = this.reportResults.getView().getRowSelectionModel().getSelections()[0];
//	this.reportResults.getView().getRowSelectionModel().selectRecords(selection);
  }

});

/**
 * Initializer for the Reports object. Returns a panel
 */
Talho.Reports.initialize = function(config){
    var reports_panel = new Talho.Reports(config);
    return reports_panel.getPanel();
};

Talho.ScriptManager.reg('Talho.Reports', Talho.Reports, Talho.Reports.initialize);

