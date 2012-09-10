Ext.ns("Talho.Dashboard.CMS.Views");

Talho.Dashboard.CMS.Views.AdminToolbar = Ext.extend(Ext.Toolbar, {
  initComponent: function(){
    this.items = [
      {text: 'Save', itemId: 'save', scope: this, handler: function(){this.fireEvent('save');}},
      {text: 'New', scope: this, handler: function(){this.fireEvent('new');}},
      {text: 'Open', scope: this, handler: function(){this.fireEvent('open');}},
      {text: 'Delete', itemId: 'delete', scope: this, handler: function(){this.fireEvent('delete');}},
      '|',
      {text: 'Preview', itemId: 'preview_button', handler: this.togglePreview.createDelegate(this, ['preview_button', 'editview_button'])},
      {text: 'Edit View', itemId: 'editview_button', handler: this.togglePreview.createDelegate(this, ['editview_button', 'preview_button']), hidden: true},
      '|',
      {text: 'Columns', itemId: 'column_button', scope: this, handler: function(){this.fireEvent('showcolumnslider');}},
      {text: 'Add Portlet', itemId: 'add_portlet', scope: this, handler: this.addPortlet},
      {text: 'Permissions', itemId: 'permissions', scope: this, handler: function(){this.fireEvent('permissions');}}
    ];
    
    Talho.Dashboard.CMS.Views.AdminToolbar.superclass.initComponent.apply(this, arguments);
  },
  
  showColumnSlider: function(columns){
    var menu = new Ext.menu.Menu({
      plain: true,
      items: [
        new Ext.slider.SingleSlider({
          minValue: 1,
          maxValue: 4,
          width: 100,
          cls: 'cms-column-slider',
          value: columns,
          plugins: new Ext.slider.Tip(), 
          listeners: {
            scope: this,
            'change': this.sliderChange,
            'changecomplete': function(){menu.hide(); menu.destroy();}
          }
        }),
        {xtype: 'label', itemId: 'label', text: 'Columns: ' + columns.toString()}
      ]
    });
    menu.show(this.getComponent('column_button').getEl());
  },
  
  sliderChange: function(sl, val){
    var label = sl.ownerCt.getComponent('label');
    label.setText('Columns: ' + val.toString());
    this.fireEvent('columnchange', val);
  },
  
  togglePreview: function(hide, show){
    this.getComponent(hide).hide();
    this.getComponent(show).show();
    this.fireEvent('togglepreview');
  },
  
  addPortlet: function(btn){
    var menu = new Ext.menu.Menu({
      plain: true,
      items: [
        {text: 'HTML', scope: this, handler: function(){this.fireEvent('addportlet', 'html');}},
        {text: 'PHIN-aware HTML', scope: this, handler: function(){this.fireEvent('addportlet', 'phin');}},
        {text: 'RSS', scope: this, handler: function(){this.fireEvent('addportlet', 'rss');}},
        {text: 'Recent Forum Posts', scope: this, handler: function(){this.fireEvent('addportlet', 'forum');}},
        {text: 'Recent Documents', scope: this, handler: function(){this.fireEvent('addportlet', 'doc');}},
        {text: 'Recent Alerts', scope: this, handler: function(){this.fireEvent('addportlet', 'alert');}},
        {text: 'Twitter', scope: this, handler: function(){this.fireEvent('addportlet', 'twitter');}}
      ]
    });
    menu.show(btn.getEl());
  },
  
  disableEditCurrent: function(){
    var btns = ['save', 'delete', 'preview_button', 'editview_button', 'column_button', 'add_portlet', 'permissions'];
    Ext.each(btns, function(btn){
      this.getComponent(btn).disable();
    }, this);
  },
  
  enableEditCurrent: function(){
    var btns = ['save', 'delete', 'preview_button', 'editview_button', 'column_button', 'add_portlet', 'permissions'];
    Ext.each(btns, function(btn){
      this.getComponent(btn).enable();
    }, this);
  }
});
