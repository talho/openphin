
Ext.ns('Talho.Admin.OrganizationMembershipRequests.view');

Talho.Admin.OrganizationMembershipRequests.view.Index = Ext.extend(Ext.Panel, {
  autoScroll: true,
  cls: 't_boot',
  closable: true,
  initComponent: function(){
    var tpl = new Ext.XTemplate(
      '<tpl for=".">',
        '<div class="org-row" style="border:1px solid black;line-height:30px;padding:5px;margin:5px 0px">',
          'Organization - {organization}, User - {name}, Email - <a href="mailto:{email}">{email}</a>',
          '<div class="pull-right">',
            '<button class="approve btn success" style="margin:0px 5px">Approve</button>',
            '<button class="deny btn danger" style="margin:0px 5px">Deny</button>',
          '</div>',
        '</div>',
      '</tpl>',
      {compiled: true}
    );
    
    this.items = [{
      xtype: 'box', cls: 'container', style: 'margin: 20px auto 0 auto;', html: [
        '<h2>Organization Membership Requests</h2>',
        '<div class="row">',
          '<img class="span1" src="/assets/info_icon.png">',
          '<p class="span14">These are pending organization membership requests for organizations that ',
          'you have administrative rights for. You are considered to have administrative rights for an',
          'organization if you are an admin and are a member of that organization. Confirm that the ',
          'requester is a member of the organization and press "Approve". If you are not sure, it is ',
          'better to "Deny" or not respond to the organization request.</p>',
        '</div>'
      ]
    },{
      xtype: 'dataview',
      cls: 'container', style: 'margin: auto;padding:15px 0 0 0;',
      region: 'center',
      autoScroll: true,
      tpl: tpl,
      itemSelector: 'div.org-row',
      emptyText: 'There are no unapproved requests at this time.',
      store: new Ext.data.JsonStore({
        url: '/admin/organization_membership_requests.json',
        restful: true,
        fields: ['id', 'name', 'organization', 'email'],
        autoLoad: true
      }),
      listeners: {
        scope: this,
        'click': this.org_clicked
      }
    }];
    
    Talho.Admin.OrganizationMembershipRequests.view.Index.superclass.initComponent.apply(this, arguments);
  },
  
  org_clicked: function(dv, i, n, e){
    var btn = Ext.get(e.getTarget('button'));
    if(btn){
      var id = dv.getStore().getAt(i).get('id'),
          url = String.format("/admin/organization_membership_requests/{0}.json", id);
      n = Ext.get(n);
      n.hide();
      
      Ext.Ajax.request({
        url: url,
        method: btn.hasClass('approve') ? 'PUT' : 'DELETE',
        success: function(){
          n.remove();
        },
        failure: function(){
          n.show();
        }
      });
    }
  }
});
