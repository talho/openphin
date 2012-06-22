//= require ./Helper

Ext.ns('Talho.Admin.Apps.view');

Talho.Admin.Apps.view.Assets = Ext.extend(Talho.Admin.Apps.view.Helper, {
  title: 'Assets',
  padding: '10px 100px',
  constructor: function(){
    Talho.Admin.Apps.view.Assets.superclass.constructor.apply(this, arguments);
  },
  initComponent: function(){
    var form_config = {border: false, labelWidth: 200, url: '/admin/app/' + this.ownerCt.appId + '.json'};
    
    this.items = [
      {xtype: 'box', cls: 't_boot', html: '<fieldset><legend>App Assets</legend></fieldset>'},
      {xtype: 'component', itemId: 'logo_thumb_url', html: '<div></div>', tpl:new Ext.Template(['<div><img src="{loc}"/></div>']), setValue: this._thumb_set_value },
      Ext.apply({xtype: 'form', itemId: 'logo', items: [
        {xtype: 'component', itemId: 'btn', fieldLabel: 'Logo (for login page, 650px wide)', autoEl: {tag: 'input', name: 'app[logo]', type: 'file'}, listeners: {scope: this, 'afterrender': this.afterUploadRender}}
      ]}, form_config),
      {xtype: 'component', itemId: 'tiny_logo_thumb_url', html: '<div></div>', tpl:new Ext.Template(['<div><img src="{loc}"/></div>']), setValue: this._thumb_set_value },
      Ext.apply({xtype: 'form', itemId: 'tinylogo', items: [
        {xtype: 'component', itemId: 'btn', autoEl: {tag: 'input', name: 'app[tiny_logo]', type: 'file'}, fieldLabel: 'Tiny Logo (for dashboard, will be scaled to 28px tall)', listeners: {scope: this, 'afterrender': this.afterUploadRender}}
      ]}, form_config),
    ];
    
    Talho.Admin.Apps.view.Assets.superclass.initComponent.apply(this, arguments);
  },
  
  afterUploadRender: function(cmp){
    cmp.el.on('change', this.field_change, this)
  },
  
  _thumb_set_value: function(val){
    this.data = {loc: val};
    if(this.rendered){
      this.update({loc: val}); 
    }
  },
  
  field_change: function(e, t, o){
    var file = t.files[0];
    if(file){
      var formData = new FormData();
      formData.append(t.name, file);
      var xhr = new XMLHttpRequest();
      xhr.addEventListener('load', function(e){
        var data = Ext.decode(e.currentTarget.responseText);
        var cmp = this.getComponent('logo_thumb_url');
        cmp.update({loc: data.logo_url});
        cmp = this.getComponent('tiny_logo_thumb_url');
        cmp.update({loc: data.tiny_logo_url});
      }.bind(this));
      xhr.open('PUT', '/admin/app/' + this.ownerCt.appId + '/upload.json', true);
      xhr.send(formData);
    }
  }
});
