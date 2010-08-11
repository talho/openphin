
Ext.onReady(function(evt){
    window.Application = new PhinApplication();
});

var PhinApplication = Ext.extend(Ext.util.Observable, {
    constructor: function(config)
    {
        PhinApplication.superclass.constructor.call(this, config);
        this.initialConfig = config || {};
        this.render_layout();
    },

    render_layout: function()
    {
        var viewport = new Ext.Viewport({
		    layout: 'fit',
            renderTo: Ext.getBody(),
            items:[{
                layout: 'border',
                items: [this.body()],
                tbar: this.topbar()
            }]
	    });
    },

    body: function()
    {
        this.tabPanel = new Ext.TabPanel({
            id: 'tabpanel',
            region: 'center', // a center region is ALWAYS required for border layout
            activeTab: 0,     // first tab initially active
            enableTabScroll: true,
            items: [Talho.Article3Panel.initialize({id:'dashboard_home'})],
            plugins: [Ext.plugin.DragDropTabs]
        });

        this.favoritesToolbar = new Ext.Panel({
            region:'north',
            height: 55,
            id: 'favoritestoolbar',
            layout: 'hbox',
            layoutConfig: {margin:'10'},
            listeners:{
                scope:this,
                'render': this.setupDropZone
            }
        });

        return new Ext.Panel({
            id: 'centerpanel',
            region: 'center', // a center region is ALWAYS required for border layout
            layout: 'border',
            items:[this.tabPanel, this.favoritesToolbar]
        })

        return this.tabPanel;
    },

    topbar: function()
    {
        var tb = new Ext.Toolbar({
            items: [{
				id: 'txphinlogo',
				html: '<img src="/stylesheets/images/app_header_logo.png"/>',
				handler: this.go_to_dashboard,
                scope: this
			}]
        });

        var builder = new MenuBuilder({parent: this, tab: this.open_tab});

        $(menuConfig).each(function(index, item){
            tb.add(builder.buildMenu(item));
        }.createDelegate(this));

        return tb;
    },

    go_to_dashboard: function(){
        this.tabPanel.getComponent('dashboard_home').show();
    },

    sign_out: function(){
        window.location = "/sign_out";
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
                var xtype = config.url === undefined || config.url === '' ? 'panel' : 'ajaxpanel';

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
                else if(xtype == 'ajaxpanel')
                {
                    panel = this.tabPanel.add({
                        title: config.title,
                        itemId: config.id,
                        xtype:'ajaxpanel',
                        closable: true,
                        hideBorders:true,
                        autoScroll:true,
                        url: config.url
                    }).show();
                }
            }

            panel.addListener('show', function(panel){panel.doLayout();}); // This is necessary for when a panel is loading without
                                                                           // being shown. Layout is never being refired, but it is now.
        }
        else
        {
           this.tabPanel.getComponent(config.id).show();
        }
    },

    setupDropZone: function(ct){
        var parent = this; // save this off in a local variable so we can keep it alive and refer to it down the way for scoping sake.
        ct.dropZone = new Ext.dd.DropTarget(ct.getEl().dom, {
            ddGroup: 'TabPanelDD',
            buttonPanel: ct,
            canDrop: function(tabConfig)
            {
                if (this.buttonPanel.find('targetId', tabConfig.id).length > 0)
                {
                    return false;
                }
                else return true;
            },
            getTabConfig: function(item){
                return {
                    id: item.getItemId(),
                    title: item.title,
                    url: item.url,
                    initializer: item.initializer
                }
            },
            notifyOver: function(source, evt, data)
            {
                var tabConfig = this.getTabConfig(data.item);
                if(this.canDrop(tabConfig))
                    return 'x-dd-drop-ok';
                else
                    return 'x-dd-drop-nodrop';
            },
            notifyDrop: function(dd, e, data){
                // Build launchable item
                var tabConfig = this.getTabConfig(data.item);

                if(this.canDrop(tabConfig))
                {
                    // add the button
                    this.buttonPanel.add(new Ext.Button({
                        text: tabConfig.title,
                        tabConfig: tabConfig,
                        targetId: tabConfig.id,
                        handler: function(b, e){
                            this.open_tab(b.tabConfig);
                        },
                        scope: parent
                    }));

                    this.buttonPanel.doLayout();
                    return true;
                }
                else return false;
            }
        });
    }

});

