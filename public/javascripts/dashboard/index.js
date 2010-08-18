
Ext.onReady(function(evt){
    window.Application.phin = new PhinApplication();
});

var PhinApplication = Ext.extend(Ext.util.Observable, {
    constructor: function(config)
    {
        PhinApplication.superclass.constructor.call(this, config);
        this.initialConfig = config || {};

        this.favorites = new Favorites({
            parent: this,
            listeners:{
                scope:this,
                'favoriteclick': this.open_tab
            }
        });
        
        this.render_layout();
    },

    render_layout: function()
    {
        var viewport = new Ext.Viewport({
		    layout: 'fit',
            renderTo: Ext.getBody(),
            items:[{
                layout: 'border',
                border: false,
                items: [this.body()],
                tbar: this.topbar(),
                bbar: this.bottombar()
            }]
	    });
    },

    body: function()
    {
        this.tabPanel = new Ext.TabPanel({
            id: 'tabpanel',
            border:false,
            region: 'center', // a center region is ALWAYS required for border layout
            activeTab: 0,     // first tab initially active
            enableTabScroll: true,
            items: [Talho.Article3Panel.initialize({id:'dashboard_home'})],
            plugins: [Ext.plugin.DragDropTabs],
            bbar:{
                id: 'tab_toolbar',
                items:[
                    {
                        text: 'Back',
                        id: 'tab_back',
                        handler: function(){
                            var comp = this.tabPanel.getActiveTab();
                            if(comp.back)
                                comp.back();
                        },
                        scope:this
                    },
                    {
                        text: 'Forward',
                        id: 'tab_forward',
                        handler: function(){
                            var comp = this.tabPanel.getActiveTab();
                            if(comp.forward)
                                comp.forward();
                        },
                        scope:this
                    },
                    {
                        text: 'Refresh',
                        handler: function(){
                            var comp = this.tabPanel.getActiveTab();
                            if(comp.reset)
                                comp.reset(true);
                        },
                        scope:this
                    }
                ]
            },
            listeners:{
                'beforetabchange': function(tab_panel, new_tab, old_tab){
                    if(old_tab)
                        old_tab.un('ajaxloadcomplete', this.setTabControls, this);
                    new_tab.on('ajaxloadcomplete', this.setTabControls, this);
                    this.setTabControls(new_tab);
                    return true;
                },
                scope: this
            }
        });

        this.favoritesToolbar = this.favorites.getPanel();

        return new Ext.Panel({
            id: 'centerpanel',
            region: 'center', // a center region is ALWAYS required for border layout
            layout: 'border',
            border:false,
            items:[this.tabPanel, this.favoritesToolbar]
        });
    },

    topbar: function()
    {
        var tb = new Ext.Toolbar({
            id: 'top_toolbar',
            items: [{
				id: 'txphinlogo',
				html: '<img src="/stylesheets/images/app_header_logo.png"/>',
				handler: this.go_to_dashboard,
                scope: this
			}]
        });

        var builder = new MenuBuilder({parent: this, tab: this.open_tab, redirect: this.redirect_to});

        Ext.each(Application.menuConfig, function(item, index){
            tb.add(builder.buildMenu(item));
        }, this);

        return tb;
    },

    bottombar: function()
    {
        var tb = new Ext.Toolbar({id: 'bottom_toolbar'});

        var builder = new MenuBuilder({parent: this, tab: this.open_tab, redirect: this.redirect_to});

        Ext.each(Application.bbarConfig, function(item, index){
            tb.add(builder.buildMenu(item));
        }, this);

        return tb;
    },

    go_to_dashboard: function(){
        this.tabPanel.getComponent('dashboard_home').show();
    },

    redirect_to: function(path){
       window.location = path;
    },
    
    open_tab: function(config) {
        if(this.tabPanel.getComponent(config.id) === undefined)
        {
            var panel;

            if(Ext.isFunction(config.initializer))
            {
                panel = this.tabPanel.add(config.initializer(config)).show();
                panel.initializer = config.initializer;
            }
            else if(Ext.isString(config.initializer) && Ext.isFunction(eval(config.initializer).initialize))
            {
                panel = this.tabPanel.add(eval(config.initializer).initialize(config)).show();
                panel.initializer = eval(config.initializer).initialize;
            }
            else
            {
                var xtype = config.url === undefined || config.url === '' ? 'panel' : 'centeredajaxpanel';

                if(xtype == 'panel')
                {
                    panel = this.tabPanel.add({
                        title: config.title,
                        itemId: config.id,
                        closable: true,
                        hideBorders:true,
                        autoScroll:true
                    }).show();
                }
                else if(xtype == 'centeredajaxpanel')
                {
                    panel = this.tabPanel.add({
                        title: config.title,
                        itemId: config.id,
                        xtype:'centeredajaxpanel',
                        closable: true,
                        hideBorders:true,
                        autoScroll:true,
                        url: config.url
                    }).show();
                }
            }

            panel.tab_config = config;
            panel.addListener('show', function(panel){panel.doLayout();}); // This is necessary for when a panel is loading without
                                                                           // being shown. Layout is never being refired, but it is now.
        }
        else
        {
            var existing_panel = this.tabPanel.getComponent(config.id).show();
            if(existing_panel.reset)
            {
                existing_panel.reset();
            }
        }
    },

    setTabControls: function(panel){
        this.tabPanel.getBottomToolbar().getComponent('tab_back').setDisabled(panel.canGoBack && panel.canGoBack() ? false : true);
        this.tabPanel.getBottomToolbar().getComponent('tab_forward').setDisabled(panel.canGoForward && panel.canGoForward() ? false : true);
    }

});

