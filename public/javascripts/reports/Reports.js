Ext.ns('Talho');

Talho.Reports = Ext.extend(Ext.util.Observable, {
  constructor: function(config){
    Talho.Reports.superclass.constructor.call(this, config);

    this.recipesStore = new Ext.data.JsonStore({
      url: '/report/recipes.json',
      restful: true,
      root: 'recipes',
      idProperty: 'id',
      fields: ['id','name_humanized'],
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
		    'load': function(store){}
      }
    });

    this.recipeList = new Ext.list.ListView({
      store: this.recipesStore,
      singleSelect: true,
      columnSort: false,
      loadingText: 'Fetching recipe list...',
      emptyText: 'Recipes are only accessible by Administrators',
      deferEmptyText: true,
      hideHeaders: true,
      style: { 'background-color': 'white'},
      columns: [{ dataIndex: 'name_humanized', cls: 'recipe-list-item'}],
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

    this.sidebarPanel = new Ext.Panel({
      layout: 'border',
      border: false,
      items: [
        this.recipeListPanel,
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
          },
          'added': function(){}
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
      title: config.title,
      listeners:{
        scope: this,
        'beforeclose': function(){}
      }
    });

    this.getPanel = function(){ return this.primary_panel; };
  },

  handleError: function(proxy, type, action, options, response, arg){
    this.show_err_message(Ext.decode(response.responseText));
    this.reportResultsContainer.layout.setActiveItem(3); // search_error
  },

  recipeSelected: function(selected_rows){
  	if (selected_rows.length > 0) {
      Ext.Ajax.request({
         url: '/report/recipes/'+this.recipeList.getSelectedRecords()[0].json.id+'.json',
         method: 'GET',
         scope:  this,
         success: function(responseObj){
           var response = Ext.decode(responseObj["responseText"]);
           if (response["error_msg"]) {
             this.recipeDescriptor.update( response["error_msg"] );
           } else {
             this.recipeDescriptor.update( response["recipe"]["description"] );
             this.generateReportButton.setText('Generate Report');
             this.generateReportButton.enable();
           }
         },
         failure: function(responseObj){
           this.ajax_err_cb(responseObj);
           this.recipeDescriptor.update( 'recipe description' );
           this.generateReportButton.disable();
            this.generateReportButton.setText('No Recipe Selected');
         }
      });
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
      title:       'Report: '+record.get('recipe'),
      url:         record.get('report_path'),
      id:          'report_view_for_' + record.get('id'),
      report_id:   record.get('id'),
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
  	   params: { 'recipe_id': this.recipeList.getSelectedRecords()[0].json.id },
       success: function(){this.reportsStore.load();this.generateReportButton.setText('Generate Report');this.generateReportButton.enable();},
  	   failure: function(){this.ajax_err_cb}
  	});  	
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

