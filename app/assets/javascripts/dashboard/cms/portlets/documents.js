Ext.namespace('Talho.Dashboard.Portlet');

Talho.Dashboard.Portlet.Documents = Ext.extend(Talho.Dashboard.Portlet, {
  fields: ['numEntries', 'urls'],
  numDocuments: 5,

  initComponent: function() {
    this.doc_store = new Ext.data.JsonStore({
      url: '/documents/recent_documents.json',
      baseParams: {
        'num_documents': this.numDocuments
      },
      autoLoad: true,
      fields: ['name', 'id', {name: 'owner_name', mapping: 'owner.display_name'}, {name: 'created_at', type: 'date'}, {name: 'folder_name', mapping: 'folder.name'}, {name: 'folder_id', mapping: 'folder.id'}, 'url'],
      restful: true
    });
    
    this.items = [{
      xtype: 'dataview',
      store: this.doc_store,
      tpl: [
        '<tpl for=".">',
        '<div class="dash-doc-node">',
          '{owner_name} uploaded <span class="dash-doc-filename">{name}</span> to <span class="dash-doc-folder-name">{folder_name}</span> on {[fm.date(values.created_at, "n/d/y, g:i A")]}',
        '</div>',
        '</tpl>'
      ],
      loadingText: 'Loading Documents Feed...',
      itemSelector: 'div.dash-doc-node',
      listeners: {
        scope: this,
        click: this.doc_click
      }}
    ]
    
    this.tools = [{ id:'refresh', qtip: 'Refresh', handler: function(){this.doc_store.load({params:{'num_documents': this.numDocuments}});}, scope: this}]
    
    Talho.Dashboard.Portlet.Documents.superclass.initComponent.apply(this, arguments);
  },
  
  
  doc_click: function(dv, i, n, e) {
    var target = Ext.get(e.getTarget()), 
        r = dv.getStore().getAt(i);

    if(target.hasClass('dash-doc-filename')) {
      if(Application.rails_environment === 'cucumber') {
        Ext.Ajax.request({
          url : r.get('url'),
          method : 'GET',
          success : function() {
            alert("Success");
          },
          failure : function() {
            alert("File Download Failed");
          }
        })
      } else {
        window.open(r.get('url'));
      }
    }
    else if(target.hasClass('dash-doc-folder-name')){
      Application.fireEvent('opentab', {id: 'documents', title:'Documents', initializer:'Talho.Documents', selected_folder_id: 'share' + r.get('folder_id')})
    }
  },

  
  showEditWindow: function(){
    var win = new Ext.Window({
      title: 'Edit Documents Portlet',
      layout: 'form',
      items: [
          {xtype: 'textfield', fieldLabel: 'Portlet title', itemId: 'titleField', value: this.title, anchor: '100%'},
          {xtype: 'numberfield', fieldLabel: 'Documents to show', itemId: 'num_docs', anchor: '100%', value: this.numEntries}
      ],
      buttons: [
        {text: 'OK', scope: this, handler: function(){
          this.editWindow_save(win);
        }},
        {text: 'Cancel', scope: this, handler: function(){win.close();}}
      ],
      width: 600,
      height: 300
    });
    win.show();
  },

  editWindow_save: function(win){
    this.numDocuments = win.getComponent('north').getComponent('num_docs').getValue();
    this.title = win.getComponent('north').getComponent('titleField').getValue();
  },
  
  isModified: function() {
    return true;
  },

  revert: function() {
    return true;
  },

  title: 'Recent Documents Portlet'
});

Ext.reg('dashboarddocportlet', Talho.Dashboard.Portlet.Documents);