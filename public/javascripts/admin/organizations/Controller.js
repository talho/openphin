Ext.ns("Talho.Admin.Organizations");

Talho.Admin.Organizations.Controller = Ext.extend(Ext.util.Observable, {
  constructor: function(config){
    Ext.apply(this, config);
    
    var index = new Talho.Admin.Organizations.view.Index();
    var layout = new Talho.Admin.Organizations.view.Layout({
      title: this.title || 'Manage Organizations',
      itemId: this.itemId,
      items: [
        index
      ]
    });
    
    index.on('activate', this.clearOtherCards, this);
    index.on('showorg', this.showOrg, this);
    index.on('neworg', this.newOrg, this);
    
    this.getPanel = function(){
      return layout;
    }
  },
  
  clearOtherCards: function(){
    this.getPanel().innerContainer.items.each(function(item, index){
      if(index > 0){
        item.destroy();
      }
    });
  },
  
  showOrg: function(id){
    var ic = this.getPanel().innerContainer;
    ic.add(new Talho.Admin.Organizations.view.Show());
    ic.layout.setActiveItem(ic.items.getCount() - 1);
  },
  
  newOrg: function(id){
    var ic = this.getPanel().innerContainer;
    ic.add(new Talho.Admin.Organizations.view.New({orgId: id}));
    ic.layout.setActiveItem(ic.items.getCount() - 1);
  }
});

Talho.ScriptManager.reg('Talho.Admin.Organizations', Talho.Admin.Organizations.Controller, function(config){
  var cont = new Talho.Admin.Organizations.Controller(config);
  return cont.getPanel();
});
