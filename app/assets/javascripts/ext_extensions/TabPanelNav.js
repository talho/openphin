Ext.ns("Ext.ux.plugin");

Ext.ux.plugin.TabPanelNav = Ext.extend(function(){}, {
    init: function(cmp){
        this.component = cmp;
        this.component.on('afterrender', this.component_afterrender, this, {delay:10});
    },

    component_afterrender: function(){
        var cmpbody = this.component.strip;
        this.component.navigation = new Ext.KeyNav(cmpbody, {
            'left': this.left,
            'right': this.right,
            'up': this.up,
            'down': this.down,
            scope: this
        });

        this.component.on('tabchange', this.focus_on_tabchange, this);
    },

    left: function(e){
        var elem = e.getTarget('li', null, true);
        var prev = elem.prev('li');
        if(prev)
        {
            prev.down('a.x-tab-right').focus();
        }
        else // otherwise go to end
        {
            elem.up('ul').select('li a.x-tab-right').last().focus();
        }
    },

    right: function(e){
        var elem = e.getTarget('li', null, true);
        var next = elem.next('li');
        if(!next.hasClass('x-tab-edge'))
        {
           next.down('a.x-tab-right').focus();
        }
        else // otherwise go to start
        {
            elem.up('ul').select('li a.x-tab-right').first().focus();
        }
    },

    up: function(e){
        var elem = e.getTarget('li', null, true);
        var close = elem.down('a.x-tab-strip-close');
        if(close)
            close.focus();
    },

    down: function(e){
        var elem = e.getTarget('li', null, true);
        var tab = elem.down('a.x-tab-right');
        if(tab)
            tab.focus();
    },

    focus_on_tabchange: function(tabpanel, panel){
        var tabStripItem = tabpanel.getTabEl(panel);
        if(tabStripItem){
            Ext.get(tabStripItem).down('a.x-tab-right').focus();
        }
    }
});