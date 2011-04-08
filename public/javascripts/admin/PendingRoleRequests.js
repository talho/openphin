Ext.namespace('Talho');

Talho.PendingRoleRequests = Ext.extend(Ext.util.Observable, {
  constructor: function(config) {
    Ext.apply(this, config);

    Talho.PendingRoleRequests.superclass.constructor.call(this, config);

    var panel = new Ext.CenteredAjaxPanel({
      url: this.url,
      title: this.title,
      itemId: this.id,
      closable: true,
      hideBorders: true,
      autoScroll: true,
      listeners: {scope: this, 'ajaxloadcomplete': this.panelLoaded}
    });

    this.getPanel = function(){ return panel; }
  },

    panelLoaded: function(panel){
      var panelDom = Ext.getDom(panel.dom);
      var userLink = Ext.get(Ext.DomQuery.selectNode('.requester_email a', panelDom));
      if(userLink) userLink.removeAllListeners(); // we want to leave this as an inline link so we don't run it through the list
      if(userLink) userLink.on('click', this.userLink_clicked, this);
    },

    userLink_clicked: function(evt, elem){
        // open the user tab
        var url = Ext.get(elem).getAttribute('url');
        var user_id = url.match(/[0-9]*(?=\/profile)/);
        Application.fireEvent('opentab', {title: 'Profile: ' + elem.textContent, user_id: user_id, id: 'user_profile_for_' + user_id, initializer: 'Talho.ShowProfile'});
    }
});

Talho.PendingRoleRequests.initialize = function(config){
  var alerts = new Talho.PendingRoleRequests(config);
  return alerts.getPanel();
};

Talho.ScriptManager.reg('Talho.PendingRoleRequests', Talho.PendingRoleRequests, Talho.PendingRoleRequests.initialize);
