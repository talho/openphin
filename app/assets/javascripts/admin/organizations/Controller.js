//= require ext_extensions/xActionColumn
//= require ext_extensions/BootstrapBreadcrumbContainer
//= require_tree ./view
//= require_self

Ext.ns("Talho.Admin.Organizations");

Talho.Admin.Organizations.Controller = Ext.extend(Ext.util.Observable, {
  constructor: function(config){
    Ext.apply(this, config);
    
    this.index = new Talho.Admin.Organizations.view.Index({itemId: 'index'});
    var layout = new Talho.Admin.Organizations.view.Layout({
      title: this.title || 'Manage Organizations',
      itemId: this.itemId,
      items: [
        this.index
      ]
    });
    
    this.index.on('activate', this.index.reload, this.index);
    this.index.on('activate', this.clearOtherCards, this);
    this.index.on('showorg', this.showOrg, this);
    this.index.on('neworg', this.newOrg, this);
    this.index.on('editorg', this.newOrg, this);
    this.index.on('delorg', this.deleteOrg, this);
    
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
    var show = ic.add(new Talho.Admin.Organizations.view.Show({orgId: id}));
    ic.layout.setActiveItem(ic.items.getCount() - 1);
  },
  
  newOrg: function(id){
    var ic = this.getPanel().innerContainer;
    var ne = ic.add(new Talho.Admin.Organizations.view.New({orgId: id}));
    ic.layout.setActiveItem(ic.items.getCount() - 1);
    
    ne.on('cancel', function(){ic.layout.setActiveItem(0);}, this);
    ne.on('savecomplete', function(){ic.layout.setActiveItem(0);}, this);
  },
  
  deleteOrg: function(id){
    if(confirm("Are you sure you would like to delete this organization?")){
      this.index.mask();
      Ext.Ajax.request({
        url: String.format("/admin/organizations/{0}.json", id),
        method: 'DELETE',
        scope: this,
        success: function(){
          this.index.reload();
        },
        failure: function(){
          this.index.reload();
          alert('Something went wrong, unable to delete the chosen org');
        }
      });
    }
  }
});

Talho.ScriptManager.reg('Talho.Admin.Organizations', Talho.Admin.Organizations.Controller, function(config){
  var cont = new Talho.Admin.Organizations.Controller(config);
  return cont.getPanel();
});
