/**
 * Builds up a menu by recursively calling buildMenu to get each Ext.MenuItem that's been specified
 * @constructor
 * @params  {Object}    config  configuration object
 * @config     {Object}   parent  the calling object, used to look for custom handlers as specified in the menu config
 * @config     {Function} tab      the function used to open new tabs
 */
var MenuBuilder = Ext.extend(Ext.util.Observable, {
    constructor: function(config)
    {
        Ext.apply(this, config);

        if(!Ext.isFunction(this.tab))
        {
            if(Ext.isFunction(this.parent.open_tab))
                this.tab = this.parent.open_tab;
            else
                this.tab = Ext.emptyFn;
        }

        if(!Ext.isFunction(this.redirect))
        {
            if(Ext.isFunction(this.parent.redirect_to))
                this.redirect = this.parent.redirect_to;
            else
                this.redirect = Ext.emptyFn;
        }

    },

    buildMenu: function(menuConfig)
    {
        // check and see if a string was sent in. These will be things like '->', ' ' and '-' for the fill, spacer, and separator shortcuts
        if(Ext.isString(menuConfig))
            return menuConfig;

        var item;

        var handler;
        if(!Ext.isEmpty(menuConfig.tab))
        {
            handler = this.tab.createDelegate(this.parent, [menuConfig.tab]);
        }
        else if(!Ext.isEmpty(menuConfig.win))
        {
            handler = this.win.createDelegate(this.parent, [menuConfig.win]);
        }
        else if(!Ext.isEmpty(menuConfig.handler) && Ext.isFunction(this.parent[menuConfig.handler]))
        {
            handler = this.parent[menuConfig.handler].createDelegate(this.parent, [menuConfig]);
        }
        else if(!Ext.isEmpty(menuConfig.redirect))
        {
            handler = this.redirect.createDelegate(this.parent, [menuConfig.redirect]);
        }
        else
        {
            handler = undefined;
        }

        // if it's a menu, we're going to create the new menu, and then call buildMenu on the menu's children
        var submenu = undefined;
        if(!Ext.isEmpty(menuConfig.items))
        {
            submenu = new Ext.menu.Menu({ ignoreParentClicks:true });
            Ext.each(menuConfig.items, function(item, index){
                submenu.add(this.buildMenu(item));
            }, this);
        }


        item = {
            text: menuConfig.name,
            icon: menuConfig.icon,
            itemId: menuConfig.itemId,
            menu: submenu,
            handler: handler
        };

        return item;
    }
});