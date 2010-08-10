
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

            //bbar: this.bottombar()
	    });


    },

    topbar: function()
    {
        var hanMenu = new Ext.menu.Menu({
            id: 'HANMenu',
            items: [{
                text: 'HAN Home',
                handler: this.open_tab.createDelegate(this, [{id: 'han_home', title:'HAN Home', url:'/han', initializer: Talho.Alerts.initialize}])
            },{
                text: 'Send An Alert',
                handler: this.open_tab.createDelegate(this, [{id: 'new_han_alert', title:'Send An Alert', url:'/alerts/new'}])
            },{
                text: 'Alert Log and Reporting',
                handler: this.open_tab.createDelegate(this, [{id: 'han_alert_log', title:'Alert Log and Reporting', url:'/alerts'}])
            }]
        });

        var rollcallMenu = new Ext.menu.Menu({
            id: 'editMenu',
            items: [{
                text: 'Main',
                handler:this.open_tab.createDelegate(this, [{id: 'rollcall_main', title:'Rollcall Main', url:'/rollcall'}])
            },{
                text: 'Schools',
                handler: this.open_tab.createDelegate(this, [{id: 'rollcall_schools', title:'Rollcall Schools', url:'/schools'}])
            },{
                text: 'About Rollcall',
                handler: this.open_tab.createDelegate(this, [{id: 'about_rollcall', title:'About Rollcall', url:'/rollcall/about'}])
            }]
        });

        var faqMenu = new Ext.menu.Menu({
            id: 'faqMenu',
            items: [{
                text: 'H1N1 Frequently Asked Questions',
                handler: this.open_tab.createDelegate(this, [{id: 'h1n1_faq', title:'H1N1 FAQ', url:'/faqs'}])
            }]
        });

        var tutorialsMenu = new Ext.menu.Menu({
            id: 'tutorialsMenu',
            items: [{
                text: 'PHIN',
                handler: this.open_tab.createDelegate(this, [{id: 'tutorials', title:'PHIN Tutorials', url:'/tutorials#PHIN'}])
            },{
                text: 'HAN',
                handler: this.open_tab.createDelegate(this, [{id: 'tutorials', title:'HAN Tutorials', url:'/tutorials#HAN'}])
            },{
                text: 'Documents Panel',
                handler: this.open_tab.createDelegate(this, [{id: 'tutorials', title:'Documents Tutorial', url:'/tutorials#Documents'}])
            },{
                text: 'Forums',
                handler: this.open_tab.createDelegate(this, [{id: 'tutorials', title:'Forums tutorial', url:'/tutorials#Forums'}])
            },{
                text: 'Rollcall',
                handler: this.open_tab.createDelegate(this, [{id: 'tutorials', title:'Rollcall Tutorial', url:'/tutorials#RollCall'}])
            }]
        });

        var profileMenu = new Ext.menu.Menu({
            id: 'profileMenu',
            items: [{
                text: 'Profile',
                handler: this.open_tab.createDelegate(this, [{id: 'my_profile', title:'My Profile'}]) // Needs to use pathing to get the current user
            },{
                text: 'Request Roles',
                handler: this.open_tab.createDelegate(this, [{id: 'request_roles', title:'Request Roles', url:'/roll_requests/new'}])
            }]
        });

        var adminMenu = new Ext.menu.Menu({
            id: 'adminMenu',
            items: [{
                text: 'Manage Roles',
                menu: {
                    items: [{
                        text: 'Pending Role Requests',
                        handler: this.open_tab.createDelegate(this, [{id: 'pending_role_requests', title:'Pending Role Requests', url:'/admin_role_requests'}])
                    },{
                        text: 'Assign Roles',
                        handler: this.open_tab.createDelegate(this, [{id: 'assign_roles', title:'Assign Roles', url:'/role_assignments/new'}])
                    }]
                }
            },{
                text: 'Manage Groups',
                handler: this.open_tab.createDelegate(this, [{id: 'manage_groups', title:'Manage Groups', url:'/admin_groups'}])
            },{
                text: 'Manage Users',
                menu: {
                    items: [{
                        text: 'Add A User',
                        handler: this.open_tab.createDelegate(this, [{id: 'add_new_user', title:'Add A User', url:'/admin_users/new'}])
                    },{
                        text: 'Batch Users',
                        handler: this.open_tab.createDelegate(this, [{id: 'batch_new_users', title:'Batch Users', url:'/user_batch/new'}])
                    },{
                        text: 'Delete A User',
                        handler: this.open_tab.createDelegate(this, [{id: 'delete_user', title:'Delete A User', url:'/users_delete/new'}])
                    }]
                }
            },{
                text: 'Manage Invitations',
                    menu: {
                    items: [{
                        text: 'Invite Users',
                        handler: this.open_tab.createDelegate(this, [{id: 'invite_users', title:'Invite Users', url:'/admin_invitations/new'}])
                    },{
                        text: 'View Invitations',
                        handler: this.open_tab.createDelegate(this, [{id: 'view_user_invitations', title:'View Invitations', url:'/admin_invitations'}])
                    }]
                }
            }]
        });

        return new Ext.Toolbar({
            items: [{
				id: 'txphinlogo', 				
				html: '<img src="/stylesheets/images/app_header_logo.png"/>',
				handler: function(e) {
					this.tabPanel.activate(0);
				},
                scope: this
			},{
				text: 'HAN',
				menu: hanMenu  // assign our menu to this button
			},{
				text: 'Rollcall',
				menu: rollcallMenu  // assign our menu to this button
			},{
				text: 'FAQs',
				menu: faqMenu
			},{
				text: 'Forums',
				handler: this.open_tab.createDelegate(this, [{id: 'forums', title:'Forums', url:'/forums'}])
			},{
				enableTogle: undefined,
				text: 'Tutorials',
				menu: tutorialsMenu
			},
                    '->'
            ,{
				text: 'My Dashboard',
				handler: function(e) {
					this.tabPanel.activate(0);
				},
                scope: this
			},{
				text: 'Find People',
			    handler:this.open_tab.createDelegate(this, [{id: 'advanced_search', title:'Find People', url:'/search/show_advanced'}])
			}, {
				text: 'My Account',
				menu: profileMenu
			}, {
				text: 'Admin',
				menu: adminMenu
			}, {
				text: 'About TXPHIN',
			    handler: this.open_tab.createDelegate(this, [{id: 'about_phin', title:'About TXPHIN', url:'/about'}])
			}, {
				text: 'Sign Out',
                handler: function(){window.location = "/sign_out"}
			}]
        })
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

    bottombar: function()
    {

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

