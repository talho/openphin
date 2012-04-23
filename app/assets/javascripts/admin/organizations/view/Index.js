
Ext.ns('Talho.Admin.Organizations.view');

Talho.Admin.Organizations.view.Index = Ext.extend(Ext.Panel, {
  layout: 'fit',
  height: 400,
  constructor: function(){
    this.addEvents('showorg', 'neworg', 'editorg', 'delorg');
    Talho.Admin.Organizations.view.Index.superclass.constructor.apply(this, arguments);
  },
  initComponent: function(){
    if(!this.items){
      this.items = [];
    }
    this.items.push({xtype: 'grid', itemId: 'grid', cls: 'org-list-grid', header: false, border: true, store: new Ext.data.JsonStore({
        url: '/admin/organizations.json',
        root: 'organizations',
        restful: true,
        autoLoad: false,
        fields: ['name', 'locality', 'state', 'id']
      }),
      columns: [
        {id: 'name', header: 'Name', dataIndex: 'name'},
        {header: 'Locality', dataIndex: 'locality', width: 150},
        {header: 'State', dataIndex: 'state'},
        {xtype: 'xactioncolumn', items: [
            {icon: '/assets/images/page_edit.png', tooltip: 'Edit Group', iconCls: 'editBtn', handler: function(grid, row){ this.fireEvent('editorg', grid.getStore().getAt(row).get('id'));}, scope: this},
            {xtype: 'spacer', width: 10},
            {icon: '/assets/cross-circle.png', tooltip: 'Delete Group', iconCls: 'removeBtn', handler: function(grid, row){ this._del = true; this.fireEvent('delorg', grid.getStore().getAt(row).get('id'));}, scope: this}
          ]
        }
      ],
      loadMask: true,
      autoExpandColumn: 'name',
      listeners: {
        scope: this,
        'rowclick': function(grid, i, e){
          var tar = e.getTarget('.x-action-col-cell');
          if(!tar && !this._del){
            this.fireEvent('showorg', grid.getStore().getAt(i).get('id'));
          }
          // undo the short-circuit
          this._del = false;
        }
      }
    });
    this.buttons = this.buttons || ['->'];
    this.buttons.push({xtype: 'button', text: 'New Organization', handler: function(){this.fireEvent('neworg');}, scope: this});
    
    Talho.Admin.Organizations.view.Index.superclass.initComponent.apply(this, arguments);
  },
  reload: function(){
    this.getComponent('grid').getStore().load();
  },
  mask: function(){
    this.getComponent('grid').loadMask.show();
  },
  unmask: function(){
    this.getComponent('grid').loadMask.hide();
  },
  border: false,
  title: 'Organization List',
  header: false
});
