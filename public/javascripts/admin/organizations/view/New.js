
Ext.ns('Talho.Admin.Organizations.view');

Talho.Admin.Organizations.view.New = Ext.extend(Ext.form.FormPanel, {
  layout: 'hbox',
  height: 450,
  layoutConfig: {
    align: 'stretchmax'
  },
  constructor: function(config){
    this.addEvents('cancel', 'savecomplete');
    config.url = String.format('/admin/organizations{0}.json', config.orgId ? '/' + config.orgId : '');
    config.method = config.orgId ? 'PUT' : 'POST';
    config.waitMsgTarget = true;
    
    Talho.Admin.Organizations.view.New.superclass.constructor.apply(this, arguments);
  },
  initComponent: function(){
    this.setTitle(this.orgId ? 'Edit Organization' : 'New Organization');
    this.items = [
      {xtype: 'container', itemId: 'container', width: 350, layout: 'form', defaults: {anchor: '100%'}, items: [
        {xtype: 'textfield', fieldLabel: 'Name', name: 'organization[name]', allowBlank: false},
        {xtype: 'textfield', fieldLabel: 'Street', name: 'organization[street]'},
        {xtype: 'textfield', fieldLabel: 'Locality', name: 'organization[locality]', allowBlank: false},
        {xtype: 'textfield', fieldLabel: 'State', name: 'organization[state]'},
        {xtype: 'textfield', fieldLabel: 'Postal Code', name: 'organization[postal_code]'},
        {xtype: 'textfield', fieldLabel: 'Phone', name: 'organization[phone]'},
        {xtype: 'textfield', fieldLabel: 'Fax', name: 'organization[fax]'},
        {xtype: 'textfield', fieldLabel: 'E-mail', name: 'organization[distribution_email]'},
        {xtype: 'textarea', fieldLabel: 'Description', name: 'organization[description]', allowBlank: false},
        {xtype: 'combo', fieldLabel: 'Contact', hiddenName: 'organization[user_id]', itemId: 'contact', 
          displayField: 'name', valueField: 'id', queryParam: 'tag', store: new Ext.data.JsonStore({
            proxy: new Ext.data.HttpProxy({
                url: '/search/show_clean',
                api: {read: {url: '/search/show_clean', method:'POST'}}
            }),
            idProperty: 'id',
            bodyCssClass: 'users',
            restful: true,
            root: 'users',
            totalProperty: 'total',
            fields: ['name', 'email', 'id', 'title', 'extra']}),
          mode: 'remote', forceSelection: true, minChars: 2, pageSize: 10,
          tpl:'<tpl for="."><div ext:qtip=\'{extra}\' class="x-combo-list-item">{name} - {email}</div></tpl>'
         }
      ]},
      {xtype: 'audiencepanel', itemId: 'audience_panel', flex: 1, height: 400, margins: '0 0 0 10px'}
    ];
    this.buttons = [
      '->', 
      {text: 'Save', scope: this, handler: function(){this.getForm().submit({
        waitMsg: 'Saving...',
        scope: this,
        success: function(){this.fireEvent('savecomplete');},
        failure: function(form, action){
          if(action.response && action.response.responseText){
            var errors = {},
                res = Ext.decode(action.response.responseText);
            for(var i = 0; i < res.errors.length; i++){
              errors['organization['+ res.errors[i][0] + ']'] = res.errors[i][1];
            }
            form.markInvalid(errors);
          }
        }
      });}}, 
      {text: 'Cancel', scope: this, handler: function(){ this.fireEvent('cancel');}}
    ];
    this.listeners = {
      scope: this,
      'beforeaction': this.beforeSubmit
    }
    
    Talho.Admin.Organizations.view.New.superclass.initComponent.apply(this, arguments);
    
    this.on('afterrender', function(){
      var f = this.getForm()
      f.waitMsgTarget = this.ownerCt.getEl();
      f.load({
        url: String.format('/admin/organizations/{0}.json', this.orgId ? this.orgId + '/edit' : 'new'),
        waitMsg: 'Loading...',
        method: 'GET',
        success: function(form, action){
          var data = action.result.data;
          for(var k in data){
            data['organization[' + k + ']'] = data[k];
          }
          this.getForm().setValues(data);
          if(data.contact){
            var combo = this.getComponent('container').getComponent('contact');
            combo.setValue(data.contact.name);
            combo.value = data.contact.id;
            if(combo.hiddenField){combo.hiddenField.value = data.contact.id;}
          }
          this.getComponent('audience_panel').load(data.audience.jurisdictions || [], data.audience.roles || [], data.audience.users || []);
        },
        scope: this
      });
    }, this, {delay:1});
  },
  beforeSubmit: function(form, action){
    if(action.type == 'submit'){
      var audienceIds = this.getComponent('audience_panel').getSelectedIds();
  
      action.options.params = {
        'organization[group_attributes][jurisdiction_ids][]': audienceIds.jurisdiction_ids,
        'organization[group_attributes][role_ids][]': audienceIds.role_ids,
        'organization[group_attributes][user_ids][]': audienceIds.user_ids
      }
    }
  },
  border: false,
  header: false
});
