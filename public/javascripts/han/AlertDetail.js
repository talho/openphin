
Ext.ns('Talho');

/**
 * This panel should be able to take a textual, JSON specification of an alert or an alert ID and display the details for said alert. This is not a true
 * extension due to its very specific implementation.
 */
Talho.AlertDetail = Ext.extend(Ext.Container, {
    constructor: function(config){
        Ext.applyIf(config, {
            autoHeight: true,
            layout: 'ux.center',
            defaults:{autoHeight: true,
                style: {
                    'margin-bottom': '10px'
                }
            }
        });

        Ext.apply(config, { // we want to absolutely override the items passed in the constructor.
            items:[
                {xtype: 'box', itemId: 'alert_title', style: {'text-align': 'center', 'margin-bottom': '10px'}},
                {collapsible: true, itemId: 'alert_detail_panel', title: 'Details', width: 800, layout: 'hbox', padding: '5', items: [
                        {xtype: 'container', itemId: 'left_detail', flex: 2, layout: 'form', labelWidth: 175, items:[
                            {xtype: 'displayfield', itemId: 'alert_message', hideLabel:true},
                            {xtype: 'displayfield', itemId: 'alert_short_text', fieldLabel: 'Short Text'},
                            {xtype: 'container', layout: 'form', labelWidth: 175, itemId: 'alert_response_container', hideLabel: true},
                            {xtype: 'displayfield', hidden: true, actionMode: 'itemCt',  itemId: 'alert_created_at', fieldLabel: 'Created at'},
                            {xtype: 'displayfield', itemId: 'alert_disable_cross_jurisdictional', fieldLabel: 'Disable Cross-Jurisdictional alerting?'}
                        ], margins:'0 15 0 0'},
                        {xtype: 'container', itemId: 'right_detail', flex: 1, layout: 'form', items: [
                            {xtype: 'displayfield', itemId: 'alert_severity', fieldLabel: 'Severity'},
                            {xtype: 'displayfield', itemId: 'alert_status', fieldLabel: 'Status'},
                            {xtype: 'displayfield', itemId: 'alert_acknowledge', fieldLabel: 'Acknowledge'},
                            {xtype: 'displayfield', itemId: 'alert_sensitive', fieldLabel: 'Sensitive (confidential)'},
                            {xtype: 'displayfield', itemId: 'alert_delivery_time', fieldLabel: 'Delivery Time'},
                            {xtype: 'displayfield', itemId: 'alert_delivery_methods', fieldLabel: 'Methods'}
                        ]}
                    ]
                },
                {collapsible: true, collapsed: true, itemId: 'audience_holder', title: 'Audience', width: 800, items: new Ext.ux.AudienceDisplayPanel({width: 'auto', itemId: 'audience_panel'})},
                {xtype: 'grid', hidden: true, itemId: 'acknowledgement_grid', collapsible: true, title: 'Acknowledgements', width: 800, store: new Ext.data.Store({
                        reader: new Ext.data.JsonReader({fields: ['name', 'email', 'device', 'response']})
                    }), disableSelection: true, autoExpandColumn: 'name_column',
                    columns:[
                        {id: 'name_column', field: 'name', header: 'Name'},
                        {field: 'email', header: 'E-mail'},
                        {field: 'device', header: 'Acknowledgement Device', width: 200},
                        {field: 'response', header: 'Acknowledgement Response', width: 200}
                    ],
                    bbar:{items: ['->', {text:'Export as CSV'}, {text:'Export as PDF'}]}
                }
            ]
        });

        Talho.AlertDetail.superclass.constructor.call(this, config);
    },

    initComponent: function(){
        var loadAlert = Ext.isNumber(this.alertId) ? true: false;

        Talho.AlertDetail.superclass.initComponent.call(this);

        if(loadAlert)
        {
            // perform load from AJAX

            // show the acknowledgement grid
        }
    },

    /**
         *  Loads the data from a passed object. This is expected to be used mostly as part of the new alert preview, taking data built from the form.
         * @param data
         */
    loadData: function(data){
        if(!this.rendered)
        {
            this.on('render', this.loadData.createDelegate(this, [data]), this, {single:true, delay:10});
        }
        else
        {
            this.data = data;
            this.getComponent('alert_title').update(data['alert[title]']);
            var detail_panel = this.getComponent('alert_detail_panel');
            var leftPane = detail_panel.getComponent('left_detail');
            leftPane.getComponent('alert_message').update(data['alert[message]']);
            leftPane.getComponent('alert_short_text').update(data['alert[short_message]']);

            var alertResponseContainer = leftPane.getComponent('alert_response_container');
            alertResponseContainer.removeAll(true);
            Ext.each(data['alert[call_down_messages][]'], function(call_down, index){
                if(!Ext.isEmpty(call_down))
                {
                    alertResponseContainer.add({xtype: 'displayfield', html: call_down, fieldLabel: 'Alert Response ' + (index + 1).toString()});
                }
            }, this);

            leftPane.getComponent('alert_created_at').hide();
            leftPane.getComponent('alert_disable_cross_jurisdictional').update(data['alert[not_cross_jurisdictional]'] ? 'Yes' : 'No');
            var rightPane = this.getComponent('alert_detail_panel').getComponent('right_detail');
            rightPane.getComponent('alert_severity').update(data['alert[severity]']);
            rightPane.getComponent('alert_status').update(data['alert[status]']);
            rightPane.getComponent('alert_acknowledge').update(data['alert[acknowledge]']);
            rightPane.getComponent('alert_sensitive').update(data['alert[sensitive]'] ? 'Yes' : 'No');

            var delivery_time = data['alert[delivery_time]'];
            rightPane.getComponent('alert_delivery_time').update(delivery_time <= 90 ? delivery_time + ' minutes' : (delivery_time/60) + ' hours');

            var delivery_methods = data['alert[device_types][]'] || [];
            if(!Ext.isArray(delivery_methods))
                delivery_methods = [delivery_methods];

            var methods_string = Ext.invoke(delivery_methods, 'match', /(?!Device)[^:\W]*(?=Device)/i).join(', ');
            rightPane.getComponent('alert_delivery_methods').update(methods_string);

            var audienceHolder = this.getComponent('audience_holder');
            audienceHolder.getComponent('audience_panel').load(data);

            if(audienceHolder.collapsed)
            {
                audienceHolder.removeListener('expand', this.triggerRecipientStoreLoad);
                audienceHolder.addListener({
                    'expand':{
                        fn: this.triggerRecipientStoreLoad,
                        scope: this,
                        single: true
                    }
                });
            }
            else
            {
                this.triggerRecipientStoreLoad(audienceHolder);
            }

            detail_panel.doLayout();
        }
    },

    triggerRecipientStoreLoad: function(panel){
        var params = {'user_ids[]': [], 'group_ids[]': [], 'jurisdiction_ids[]': [], 'role_ids[]': []};
        Ext.each(this.data.users, function(user){params['user_ids[]'].push(user.id)});
        Ext.each(this.data.groups, function(group){params['group_ids[]'].push(group.id)});
        Ext.each(this.data.jurisdictions, function(jurisdiction){params['jurisdiction_ids[]'].push(jurisdiction.id)});
        Ext.each(this.data.roles, function(role){params['role_ids[]'].push(role.id)});
        panel.getComponent('audience_panel').loadRecipientStoreFromAjax('/audiences/determine_recipients.json', params);
    }
});