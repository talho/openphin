Ext.ns('Ext.ux');

Ext.ux.ToolBarNav = Ext.extend(function(config){Ext.apply(this, config);}, {
    init: function(cmp){
        this.component = cmp;

        cmp.on('afterrender', this.after_cmp_render, this, {delay: 10});
    },

    after_cmp_render: function(){
        this.component.navigation = new Ext.KeyNav(this.component.getEl(), {
            'left': this.left,
            'right': this.right,
            'down': this.down,
            scope: this
        });

        this.component.items.each(function(item){
            if(item.btnEl){
                item.btnEl.on('blur', function(e, elem, o){o.item.focused = false}, this, {item: item});
                item.btnEl.on('focus', function(e, elem, o){o.item.focused = true}, this, {item: item});
            }
        }, this);
    },

    left: function(e){
        var btnIndex = this.component.items.findIndex('focused', 'true');
        var nextIndex = btnIndex - 1 >= 0 ? btnIndex - 1 : this.component.items.length - 1;
        var item = this.component.items.get(nextIndex);
        while(!item.btnEl)
        {
            nextIndex = nextIndex - 1 >= 0 ? nextIndex - 1 : this.component.items.length - 1;
            item = this.component.items.get(nextIndex);
            if(nextIndex == this.component.items.length - 1)
                break;
        }
        item.focus();
    },

    right: function(e){
        var btnIndex = this.component.items.findIndex('focused', 'true');
        var nextIndex = btnIndex + 1 < this.component.items.length ? btnIndex + 1 : 0;
        var item = this.component.items.get(nextIndex);
        while(!item.btnEl)
        {
            nextIndex = nextIndex + 1 < this.component.items.length ? nextIndex + 1 : 0;
            item = this.component.items.get(nextIndex);
            if(nextIndex == 0)
                break;
        }
        item.focus();
    },

    down: function(e){
        var btnIndex = this.component.items.findIndex('focused', 'true');
        if(btnIndex < 0) return;
        var item = this.component.items.get(btnIndex);
        if(item && item.menu)
            item.onClick({button: 0, preventDefault: Ext.emptyFn});
    }
});