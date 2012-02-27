
Ext.ns("Talho.Admin.Organizations.view");

Talho.Admin.Organizations.view.Layout = Ext.extend(Ext.Panel, {
  layout: 'border',
  closable: true,
  initComponent: function(){
    var items = this.items;
    var card_panel = new Ext.Container({itemId: 'container', layout: 'card', width: 940, style: 'margin: auto;', activeItem: 0, items: items});
    this.items = [{xtype: 'bootstrapbreadcrumb', region: 'north', panel: card_panel},
      {xtype: 'panel', border: false, itemId: 'centering', region: 'center', items: [
        card_panel
      ]}
    ];
    
    Talho.Admin.Organizations.view.Layout.superclass.initComponent.apply(this, arguments);
    
    this.innerContainer = this.getComponent('centering').getComponent('container');
    this.add = function(){
      this.innerContainer.add.apply(this.innerContainer, arguments);
    }
  },
  
  autoScroll: true
});
