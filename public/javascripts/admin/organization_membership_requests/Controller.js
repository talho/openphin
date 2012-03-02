
Ext.ns('Talho.Admin.OrganizationMembershipRequests');

Talho.Admin.OrganizationMembershipRequests.Controller = Ext.extend(Ext.util.Observable, {
  constructor: function(config){
    Talho.Admin.OrganizationMembershipRequests.Controller.superclass.constructor.apply(this, arguments);
    Ext.apply(this, config);
    
    var panel = new Talho.Admin.OrganizationMembershipRequests.view.Index({
      itemId: this.itemId,
      title: this.title || "Organization Membership Requets"
    });
    
    this.getPanel = function(){
      return panel;
    }
  }
});

Talho.ScriptManager.reg('Talho.Admin.OrganizationMembershipRequests', Talho.Admin.OrganizationMembershipRequests.Controller, function(config){
  var cont = new Talho.Admin.OrganizationMembershipRequests.Controller(config);
  return cont.getPanel();
});