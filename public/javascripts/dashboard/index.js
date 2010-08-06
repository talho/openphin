
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
                handler: this.open_tab.createDelegate(this, ['HAN Home', '/han'])
            },{
                text: 'Send An Alert',
                handler: this.open_tab.createDelegate(this, ['Send An Alert', '/alerts/new'])
            },{
                text: 'Alert Log and Reporting',
                handler: this.open_tab.createDelegate(this, ['Alert Log and Reporting', '/alerts'])
            }]
        });

        var rollcallMenu = new Ext.menu.Menu({
            id: 'editMenu',
            items: [{
                text: 'Main',
                handler:this.open_tab.createDelegate(this, ['Rollcall Main', '/rollcall'])
            },{
                text: 'Schools',
                handler: this.open_tab.createDelegate(this, ['Rollcall Schools', '/schools'])
            },{
                text: 'About Rollcall',
                handler: this.open_tab.createDelegate(this, ['About Rollcall', '/rollcall/about'])
            }]
        });

        var faqMenu = new Ext.menu.Menu({
            id: 'faqMenu',
            items: [{
                text: 'H1N1 Frequently Asked Questions',
                handler: this.open_tab.createDelegate(this, ['H1N1 FAQ', '/faqs'])
            }]
        });

        var tutorialsMenu = new Ext.menu.Menu({
            id: 'tutorialsMenu',
            items: [{
                text: 'PHIN',
                handler: this.open_tab.createDelegate(this, ['PHIN Tutorials', '/tutorials#PHIN'])
            },{
                text: 'HAN',
                handler:this.open_tab.createDelegate(this, ['HAN Tutorials', '/tutorials#HAN'])
            },{
                text: 'Documents Panel',
                handler: this.open_tab.createDelegate(this, ['Documents Tutorial', '/tutorials#Documents'])
            },{
                text: 'Forums',
                handler: this.open_tab.createDelegate(this, ['Forums tutorial', '/tutorials#Forums'])
            },{
                text: 'Rollcall',
                handler: this.open_tab.createDelegate(this, ['Rollcall Tutorial', '/tutorials#RollCall'])
            }]
        });

        var profileMenu = new Ext.menu.Menu({
            id: 'profileMenu',
            items: [{
                text: 'Profile',
                handler: this.open_tab.createDelegate(this, ['My Profile'])
            },{
                text: 'Request Roles',
                handler: this.open_tab.createDelegate(this, ['Request Roles'])
            }]
        });

        var adminMenu = new Ext.menu.Menu({
            id: 'adminMenu',
            items: [{
                text: 'Manage Roles',
                menu: {
                    items: [{
                        text: 'Pending Role Requests',
                        handler: this.open_tab.createDelegate(this, ['Pending Role Requests'])
                    },{
                        text: 'Assign Roles',
                        handler: this.open_tab.createDelegate(this, ['Assign Roles'])
                    }]
                }
            },{
                text: 'Manage Groups',
                handler: this.open_tab.createDelegate(this, ['Manage Groups'])
            },{
                text: 'Manage Users',
                menu: {
                    items: [{
                        text: 'Add A User',
                        handler: this.open_tab.createDelegate(this, ['Add A User'])
                    },{
                        text: 'Batch Users',
                        handler: this.open_tab.createDelegate(this, ['Batch Users'])
                    },{
                        text: 'Delete A User',
                        handler: this.open_tab.createDelegate(this, ['Delete A User'])
                    }]
                }
            },{
                text: 'Manage Invitations',
                    menu: {
                    items: [{
                        text: 'Invite Users',
                        handler: this.open_tab.createDelegate(this, ['Invite Users'])
                    },{
                        text: 'View Invitations',
                        handler: this.open_tab.createDelegate(this, ['View Invitations'])
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
				handler: this.open_tab.createDelegate(this, ['Forums', '/forums'])
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
			    handler:this.open_tab.createDelegate(this, ['Find People'])
			}, {
				text: 'My Account',
				menu: profileMenu
			}, {
				text: 'Admin',
				menu: adminMenu
			}, {
				text: 'About TXPHIN',
			    handler: this.open_tab.createDelegate(this, ['About TXPHIN'])
			}, {

				text: 'Sign Out'
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
            items: [{title: 'Dashboard', contentEl:'dashboard_feed_articles', autoScroll:true}]
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

    open_tab: function(title, href) {
        if(this.tablist[title] === undefined)
        {
            var xtype = href === undefined || href === '' ? 'panel' : 'ajaxpanel';

            var panel = this.tabPanel.add({
                title: title,
                iconCls: 'tabs',
                closable: true,
                layout:'hbox',
                hideBorders:true,
                autoScroll:true,
                listeners:{
                    scope: this,
                    close: function(p)
                    {
                        delete this.tablist[p.title];
                    }
                },
                items:[
                    {
                        flex:1
                    },
                    {
                        xtype: xtype,
                        bodyCssClass: 'content',
                        url: href
                    },
                    {
                        flex:1
                    }]
            }).show();

            this.tablist[title] = panel
        }
        else
        {
           this.tablist[title].show();
        }
    }
});

