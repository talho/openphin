
Ext.ns('Talho.Admin.Organizations.view');

Talho.Admin.Organizations.view.Show = Ext.extend(Ext.Panel, {
  initComponent: function(){
    Ext.Ajax.request({
      url: '/admin/organizations/' + this.orgId + '.json',
      success: function(resp){
        var data = Ext.decode(resp.responseText)
        this.update(data);
      },
      callback: function(){
        if(this.loadMask){this.loadMask.hide();}
      },
      scope: this
    });
    
    this.on('afterrender', function(){this.loadMask = new Ext.LoadMask(this.ownerCt.ownerCt.getEl()); this.loadMask.show();}, this, {delay:1});
    
    Talho.Admin.Organizations.view.Show.superclass.initComponent.apply(this, arguments);
  },
  tpl: new Ext.XTemplate(
    '<div class="t_boot">',
      '<h2>{name}</h2>',
      '<div class="content row" style="padding:0px;">',
        '<div class="span8">',
          '<address>',
            '<tpl if="street">',
              '{street}<br/>',
            '</tpl>',
            '{locality}',
            '<tpl if="state || postal_code">',
              ', {state} {postal_code}<br/>',
            '</tpl>',
          '</address>',
        '</div>',
        '<div class="span8">',
          '<address>',
            '<tpl if="phone">',
              'P: {phone}<br/>',
            '</tpl>',
            '<tpl if="fax">',
              'F: {fax}<br/>',
            '</tpl>',
            '<tpl if="distribution_email">',
              '<a href="mailto:{distribution_email}">{distribution_email}</a>',
            '</tpl>',
          '</address>',
        '</div>',
      '</div>',
      '<p>{description}</p>',
      '<tpl if="contact">',
        '<tpl for="contact">',
          '<p>',
            'Contact:<br/>',
            '{name}',
          '</p>',
        '</tpl>',
      '</tpl>',
    '</div>',
    {compiled: true}
  ),
  border: false,
  title: 'Organization Detail',
  header: false
});
