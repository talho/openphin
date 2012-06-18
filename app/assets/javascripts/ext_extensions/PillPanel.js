Ext.ns("Ext.ux");

Ext.ux.PillPanel = Ext.extend(Ext.TabPanel, {
  activeItem : 0,
  initComponent : function() {
    this.tabPosition = 'top';
    this.headerCfg = {
      cls : 'x-pill-strip-wrap t_boot',
      style : 'border-width: 0px;padding: 10px 50px'
    };
    Ext.ux.PillPanel.superclass.initComponent.call(this);
  },
  onRender : function() {
    Ext.TabPanel.superclass.onRender.apply(this, arguments);

    var tar = this.stripWrap = this.header;
    this.strip = tar.createChild({
      tag : 'ul',
      cls : 'pills',
      style : 'margin: 0px;'
    });
    this.edge = this.strip.createChild({
      tag : 'span',
      cls : 'x-tab-edge',
      cn : [{
        tag : 'span',
        cls : 'x-tab-strip-text',
        cn : '&#160;'
      }]
    });
    this.body.addClass('x-tab-panel-body-' + this.tabPosition);

    if(!this.itemTpl) {
      var tt = new Ext.Template('<li class="{cls}" id="{id}">', '<a class="" href="#">{text}</a>', '</li>');
      tt.disableFormats = true;
      tt.compile();
      Ext.ux.PillPanel.prototype.itemTpl = tt;
    }

    this.items.each(this.initTab, this);
  },
  initTab : function(item, index) {
    var before = this.strip.dom.childNodes[index], 
        p = this.getTemplateArgs(item), 
        el = before ? this.itemTpl.insertBefore(before, p) : this.itemTpl.append(this.strip, p), 
        cls = 'x-tab-strip-over', 
        tabEl = Ext.get(el);

    if(item.tabTip) {
      tabEl.child('a', true).qtip = item.tabTip;
    }
    item.tabEl = el;

    // Route *keyboard triggered* click events to the tab strip mouse handler.
    tabEl.select('a').on('click', function(e) {
      if(!e.getPageX()) {
        this.onStripMouseDown(e);
      }
    }, this, {
      preventDefault : true
    });

    item.on({
      scope : this,
      disable : this.onItemDisabled,
      enable : this.onItemEnabled,
      titlechange : this.onItemTitleChanged,
      iconchange : this.onItemIconChanged,
      beforeshow : this.onBeforeShowItem
    });
  },
  
  onItemTitleChanged : function(item) {
    var el = this.getTabEl(item);
    if(el) {
      Ext.fly(el).child('a', true).innerHTML = item.title;
    }
  },
  
  setActiveTab : function(item){
      item = this.getComponent(item);
      if(this.fireEvent('beforetabchange', this, item, this.activeTab) === false){
        return;
      }
      if(!this.rendered){
        this.activeTab = item;
        return;
      }
      if(this.activeTab != item){
        if(this.activeTab){
          var oldEl = this.getTabEl(this.activeTab);
          if(oldEl){
            Ext.fly(oldEl).removeClass('active');
          }
        }
        this.activeTab = item;
        if(item){
          var el = this.getTabEl(item);
          Ext.fly(el).addClass('active');
          this.stack.add(item);

          this.layout.setActiveItem(item);
          // Need to do this here, since setting the active tab slightly changes the size
          this.delegateUpdates();
          if(this.scrolling){
            this.scrollToTab(item, this.animScroll);
          }
        }
        this.fireEvent('tabchange', this, item);
      }
    }
});

Ext.reg('pillpanel', Ext.ux.PillPanel);
