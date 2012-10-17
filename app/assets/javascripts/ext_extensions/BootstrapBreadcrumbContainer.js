
(function(){
  Ext.ns('Ext.ux')
  
  var bodyTemplate = new Ext.XTemplate('<div class="t_boot">',
    '<div class="t_boot container" style="padding-top: 10px;">',
      '<div class="t_boot row" >',
        '<ul class="t_boot breadcrumb offset4 span7">',
          '<li>&nbsp;</li>',
        '</ul>',
      '</div>',
    '</div>',
  '</div>', {
    compiled: true
  });
  
  var itemTemplate = new Ext.XTemplate('<tpl for=".">',
    '<li>',
      '<tpl if="active">',
        '{title}',
      '</tpl>',
      '<tpl if="!active">',
        '<a href="#" index="{i}">{title}</a>',
      '</tpl>',
      '<tpl if="!last"><span class="divider">/</span></tpl>',
    '</li>',
  '</tpl>', {
    compiled: true
  })
  
  Ext.ux.BootstrapBreadcrumbContainer = Ext.extend(Ext.BoxComponent, {
    constructor: function(config){
      Ext.apply(this, config);
      Ext.ux.BootstrapBreadcrumbContainer.superclass.constructor.apply(this, arguments);
      this.addEvents('beforenav');
    },
    initComponent: function(){
      this.on('afterrender', function(){
        if(!this.panel && this.panelSelector){
          this.panel = this.ownerCt.getComponent(this.panelSelector);
        }
        
        this.panel.on('add', this.itemAdd, this);
        this.panel.on('remove', this.itemRemove, this);
        this.panel.items.each(function(item){item.on('activate', this.drawItems, this)}, this);
        this.drawItems();
      }, this, {delay:1, once: true});
      Ext.ux.BootstrapBreadcrumbContainer.superclass.initComponent.apply(this, arguments);
    },
    onRender: function(ct, position){
      var targs = {};
      if(position){
        this.el = bodyTemplate.insertBefore(position, targs, true);
      }
      else{
        this.el = bodyTemplate.append(ct, targs, true);
      }
      
      this.listEl = this.el.select('ul', true).first();
    },
    drawItems: function(){
      // build an object with breadcrumb info
      var targs = [];
      this.panel.items.each(function(item, index, length){
        var obj = {title: item.title, active: this.panel.layout.activeItem === item, last: index === length - 1, i: index};
        targs.push(obj);
      }, this);
      
      this.listEl.select('a').removeAllListeners();
      // render template
      itemTemplate.overwrite(this.listEl, targs);
      this.listEl.select('a').on('click', this.onCrumbClicked, this);
    },
    onCrumbClicked: function(e, t, o){
      t = Ext.get(t);
      if(t.is('a')){
        var new_index = Number(t.getAttribute('index')),
            current_index = this.panel.items.indexOf(this.panel.layout.activeItem);
        if(this.fireEvent('beforenav', this, new_index, current_index) !== false){
          this.panel.layout.setActiveItem(new_index);
        }
      }
    },
    itemAdd: function(cont, comp, i){
      comp.on('activate', this.drawItems, this);
      this.drawItems();
    },
    itemRemove: function(cont, comp){
      this.drawItems();
    }
  });
  
  Ext.reg('bootstrapbreadcrumb', Ext.ux.BootstrapBreadcrumbContainer);
})();
