Ext.ns("Talho.Forums.view");

Talho.Forums.view.Layout = Ext.extend(Ext.Panel, {
  layout: 'border',
  closable: true,
  id: 'ForumPanel',
  initComponent: function(){
    var items = this.items;
    var card_panel = new Ext.Container(
      {itemId: 'container', width: 940, layout: 'card', style: 'margin: auto;', activeItem: 0, items: items}
    );
    this.items = [{xtype: 'bootstrapbreadcrumb', region: 'north', panel: card_panel},  
      {xtype: 'panel', border: false, autoScroll: true, itemId: 'centering', region: 'center', items: [card_panel]}
     ];
     
   Talho.Forums.view.Layout.superclass.initComponent.apply(this, arguments);
   
   this.innerContainer = this.getComponent('centering').getComponent('container');
   this.add = function(){
     this.innerContainer.add.apply(this.innerContainer, arguements);
   }
  },
  
  autoScroll: true
});
