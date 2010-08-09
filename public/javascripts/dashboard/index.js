
Ext.onReady(function(evt){
    window.Application = new PhinApplication();
});

var PhinApplication = Ext.extend(Ext.util.Observable, {
    constructor: function(config)
    {
        PhinApplication.superclass.constructor.call(this, config);
        this.initialConfig = config || {};
        this.tablist = {};
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
                handler: this.open_tab.createDelegate(this, ['HAN Home', {href:'/han', initializer: Talho.Alerts.initialize}])
            },{
                text: 'Send An Alert',
                handler: this.open_tab.createDelegate(this, ['Send An Alert', {href:'/alerts/new'}])
            },{
                text: 'Alert Log and Reporting',
                handler: this.open_tab.createDelegate(this, ['Alert Log and Reporting', {href:'/alerts'}])
            }]
        });

        var rollcallMenu = new Ext.menu.Menu({
            id: 'editMenu',
            items: [{
                text: 'Main',
                handler:this.open_tab.createDelegate(this, ['Rollcall Main', {href:'/rollcall'}])
            },{
                text: 'Schools',
                handler: this.open_tab.createDelegate(this, ['Rollcall Schools', {href:'/schools'}])
            },{
                text: 'About Rollcall',
                handler: this.open_tab.createDelegate(this, ['About Rollcall', {href:'/rollcall/about'}])
            }]
        });

        var faqMenu = new Ext.menu.Menu({
            id: 'faqMenu',
            items: [{
                text: 'H1N1 Frequently Asked Questions',
                handler: this.open_tab.createDelegate(this, ['H1N1 FAQ', {href:'/faqs'}])
            }]
        });

        var tutorialsMenu = new Ext.menu.Menu({
            id: 'tutorialsMenu',
            items: [{
                text: 'PHIN',
                handler: this.open_tab.createDelegate(this, ['PHIN Tutorials', {href:'/tutorials#PHIN'}])
            },{
                text: 'HAN',
                handler:this.open_tab.createDelegate(this, ['HAN Tutorials', {href:'/tutorials#HAN'}])
            },{
                text: 'Documents Panel',
                handler: this.open_tab.createDelegate(this, ['Documents Tutorial', {href:'/tutorials#Documents'}])
            },{
                text: 'Forums',
                handler: this.open_tab.createDelegate(this, ['Forums tutorial', {href:'/tutorials#Forums'}])
            },{
                text: 'Rollcall',
                handler: this.open_tab.createDelegate(this, ['Rollcall Tutorial', {href:'/tutorials#RollCall'}])
            }]
        });

        var profileMenu = new Ext.menu.Menu({
            id: 'profileMenu',
            items: [{
                text: 'Profile',
                handler: this.open_tab.createDelegate(this, ['My Profile']) // Needs to use pathing to get the current user
            },{
                text: 'Request Roles',
                handler: this.open_tab.createDelegate(this, ['Request Roles', {href:'/roll_requests/new'}])
            }]
        });

        var adminMenu = new Ext.menu.Menu({
            id: 'adminMenu',
            items: [{
                text: 'Manage Roles',
                menu: {
                    items: [{
                        text: 'Pending Role Requests',
                        handler: this.open_tab.createDelegate(this, ['Pending Role Requests', {href:'/admin_role_requests'}])
                    },{
                        text: 'Assign Roles',
                        handler: this.open_tab.createDelegate(this, ['Assign Roles', {href:'/role_assignments/new'}])
                    }]
                }
            },{
                text: 'Manage Groups',
                handler: this.open_tab.createDelegate(this, ['Manage Groups', {href:'/admin_groups'}])
            },{
                text: 'Manage Users',
                menu: {
                    items: [{
                        text: 'Add A User',
                        handler: this.open_tab.createDelegate(this, ['Add A User', {href:'/admin_users/new'}])
                    },{
                        text: 'Batch Users',
                        handler: this.open_tab.createDelegate(this, ['Batch Users', {href:'/user_batch/new'}])
                    },{
                        text: 'Delete A User',
                        handler: this.open_tab.createDelegate(this, ['Delete A User', {href:'/users_delete/new'}])
                    }]
                }
            },{
                text: 'Manage Invitations',
                    menu: {
                    items: [{
                        text: 'Invite Users',
                        handler: this.open_tab.createDelegate(this, ['Invite Users', {href:'/admin_invitations/new'}])
                    },{
                        text: 'View Invitations',
                        handler: this.open_tab.createDelegate(this, ['View Invitations', {href:'/admin_invitations'}])
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
				handler: this.open_tab.createDelegate(this, ['Forums', {href:'/forums'}])
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
			    handler:this.open_tab.createDelegate(this, ['Find People', {href:'/search/show_advanced'}])
			}, {
				text: 'My Account',
				menu: profileMenu
			}, {
				text: 'Admin',
				menu: adminMenu
			}, {
				text: 'About TXPHIN',
			    handler: this.open_tab.createDelegate(this, ['About TXPHIN', {href:'/about'}])
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
            items: [Talho.Article3Panel.initialize()]
        });

        this.tablist['Dashboard'] = 0;

        return new Ext.Panel({
            id: 'centerpanel',
            region: 'center', // a center region is ALWAYS required for border layout
            layout: 'border',
            items:[this.tabPanel,{
                xtype:'toolbar',
                region:'north',
                height: 55,
                id: 'favoritestoolbar',
                border: false
            }]
        })

        return this.tabPanel;
    },

    bottombar: function()
    {

    },

    open_tab: function(title, config) {
        if(this.tablist[title] === undefined)
        {
            var panel;

            if(Ext.isFunction(config.initializer))
            {
                panel = this.tabPanel.add(config.initializer(config)).show();
            }
            else
            {
                var xtype = config.href === undefined || config.href === '' ? 'panel' : 'ajaxpanel';

                if(xtype == 'panel')
                {
                    panel = this.tabPanel.add({
                    title: title,
                        closable: true,
                        hideBorders:true,
                        autoScroll:true
                    }).show();
                }
                else if(xtype == 'ajaxpanel')
                {
                    panel = this.tabPanel.add({
                        title: title,
                        xtype:'ajaxpanel',
                        closable: true,
                        hideBorders:true,
                        autoScroll:true,
                        url: config.href
                    }).show();
                }
            }

            panel.addListener('close', function(p){
                delete this.tablist[p.title];
            }, this);

            this.tablist[title] = panel
        }
        else
        {
           this.tablist[title].show();
        }
    }
});

