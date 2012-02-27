
Ext.ns('Talho.Admin.Organizations.view');

Talho.Admin.Organizations.view.Index = Ext.extend(Ext.Panel, {
  constructor: function(){
    this.addEvents('showorg', 'neworg', 'editorg', 'delorg');
    Talho.Admin.Organizations.view.Index.superclass.constructor.apply(this, arguments);
  },
  initComponent: function(){
    if(!this.items){
      this.items = [];
    }
    this.items.push({xtype: 'grid', header: false, border: true, store: new Ext.data.JsonStore({
        url: '/admin/organizations.json',
        root: 'organizations',
        restful: true,
        autoLoad: true,
        fields: ['name', 'locality', 'state', 'id']
      }),
      columns: [
        {id: 'name', header: 'Name', dataIndex: 'name'},
        {header: 'Locality', dataIndex: 'locality', width: 150},
        {header: 'State', dataIndex: 'state'},
        {xtype: 'xactioncolumn', items: [
            {icon: '/stylesheets/images/page_edit.png', tooltip: 'Edit Group', iconCls: 'editBtn', handler: function(grid, row){ this.fireEvent('editorg', grid.getStore().getAt(row).get('id'));}, scope: this},
            {xtype: 'spacer', width: 10},
            {icon: '/images/cross-circle.png', tooltip: 'Delete Group', iconCls: 'removeBtn', handler: function(grid, row){ this.fireEvent('delorg', grid.getStore().getAt(row).get('id'));}, scope: this}
          ]
        }
      ],
      loadMask: true,
      height: 400,
      autoExpandColumn: 'name' 
    });
    this.items.push({xtype: 'button', text: 'New', handler: function(){this.fireEvent('neworg', 1);}, scope: this});
    
    Talho.Admin.Organizations.view.Index.superclass.initComponent.apply(this, arguments);
  },
  border: false,
  title: 'Organization List',
  header: false
});
