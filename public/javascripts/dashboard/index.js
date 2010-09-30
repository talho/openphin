
Ext.onReady(function(evt){
    window.Application.phin = new PhinApplication();
});

var PhinApplication = Ext.extend(Ext.util.Observable, {
    constructor: function(config)
    {
        PhinApplication.superclass.constructor.call(this, config);

        Ext.QuickTips.init();
        Ext.apply(Ext.QuickTips.getQuickTip(),{
            dismissDelay: 0
        });

        this.initialConfig = config || {};

        Application.addListener({
            'opentab':{
                fn: this.open_tab,
                scope: this
            }
        });

        Talho.ScriptManager.loadOtherLibrary('Favorites PhinLayout Dashboard', function(){
            this.favorites = new Favorites({
                parent: this,
                listeners:{
                    scope:this,
                    'favoriteclick': this.open_tab
                }
            });

            this.render_layout();
        }.createDelegate(this));
    },

    render_layout: function(){
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

    body: function(){
        this.tabPanel = new Ext.TabPanel({
            id: 'tabpanel',
            border:false,
            region: 'center', // a center region is ALWAYS required for border layout
            activeTab: 0,     // first tab initially active
            enableTabScroll: true,
            items: [Talho.Article3Panel.initialize({itemId:'dashboard_home'})],
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
                        id: 'tab_reset',
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
                        old_tab.un('afternavigation', this.setTabControls, this);
                    new_tab.on('afternavigation', this.setTabControls, this);
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

    topbar: function(){
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

    bottombar: function(){
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

    /**
     * Opens a new tab in the primary tab panel based on the config
     * @param {Object}    config   Lists the configuration options for the tab
     * @config {String}     title       Title of the new tab
     * @config {String}     id          ID of the new tab. This determines if the tab is unique in favorites and in the tab panel.
     */
    open_tab: function(config) {
        if(this.tabPanel.getComponent(config.id) === undefined) {
            var panel;

            if(Talho.ScriptManager.exists(config.initializer))
            {
                panel = this.tabPanel.add({title: config.title, listeners:{'render':{fn: function(panel){new Ext.LoadMask(panel.getEl());}, delay: 10 }} }).show();
                Talho.ScriptManager.getInitializer(config.initializer, this.getInitializer_callback.createDelegate(this, [config, panel], true));
                return;
            }
            else if(Ext.isFunction(config.initializer))
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
                    panel = this.tabPanel.add({title: config.title, listeners:{'render':{fn: function(panel){new Ext.LoadMask(panel.getEl());}, delay: 10 }} }).show();
                    Talho.ScriptManager.loadOtherLibrary('AjaxPanel', this.loadOtherLibrary_callback.createDelegate(this, [config, panel], true));
                    return;
                }
            }

            panel.tab_config = config;
            panel.addListener({
                'show':function(panel){panel.doLayout();},// This is necessary for when a panel is loading without being shown. Layout is never being refired, but it is now.
                'fatalerror': function(panel){
                    this.tabPanel.remove(panel, true);
                },
                scope: this
            }); 
        }
        else
        {
            var existing_panel = this.tabPanel.getComponent(config.id).show();
            if(existing_panel.reset)
            {
                existing_panel.reset(config);
            }
        }
    },

    loadOtherLibrary_callback: function(name, config, tempPanel){
        this.tabPanel.remove(tempPanel);

         panel = this.tabPanel.add({
            title: config.title,
            itemId: config.id,
            xtype:'centeredajaxpanel',
            closable: true,
            hideBorders:true,
            autoScroll:true,
            url: config.url
        }).show();

        this.newTabPropertiesAndEvents(panel, config);
    },

    getInitializer_callback: function(initializer, config, tempPanel){
        this.tabPanel.remove(tempPanel);
        var panel = this.tabPanel.add(initializer(config)).show();
        panel.initializer = initializer;

        this.newTabPropertiesAndEvents(panel, config);
    },

    newTabPropertiesAndEvents: function(panel, config){
        panel.tab_config = config;
        panel.addListener({
            'show':function(panel){panel.doLayout();},// This is necessary for when a panel is loading without being shown. Layout is never being refired, but it is now.
            'fatalerror': function(panel){
                this.tabPanel.remove(panel, true);
            },
            scope: this
        });
    },

    setTabControls: function(panel){
        this.tabPanel.getBottomToolbar().getComponent('tab_back').setDisabled(panel.canGoBack && panel.canGoBack() ? false : true);
        this.tabPanel.getBottomToolbar().getComponent('tab_forward').setDisabled(panel.canGoForward && panel.canGoForward() ? false : true);
        this.tabPanel.getBottomToolbar().getComponent('tab_reset').setDisabled(panel.reset ? false : true);
    }

});

