
Ext.ns('Talho');

/**
 * This panel should be able to take a textual, JSON specification of an alert or an alert ID and display the details for said alert. This is not a true
 * extension due to its very specific implementation.
 */
Talho.AlertDetail = Ext.extend(Ext.Panel, {
  border:false,
    constructor: function(config){
        
        this.acknowledgement_store = new Ext.data.Store({reader: new Ext.data.JsonReader({fields: ['name', 'email', 'device', 'response', 'acknowledged_at']})});

        Ext.apply(config, { // we want to absolutely override the items passed in the constructor.
            items:[
                {xtype: 'box', html: 'This is a Preview:  Please review carefully before sending.', style: 'text-align: center; font-weight: bold;', itemId: 'preview_message'},
                {xtype: 'container', itemId: 'alert_detail_panel', layout: 'column',  defaults:{style: 'padding:5px;'}, items: [
                        {xtype: 'container', itemId: 'left_detail', columnWidth: .66, layout: 'form', labelWidth: 175, items:[
                            {xtype: 'displayfield', itemId: 'alert_title', fieldLabel: 'Alert Title'},
                            {xtype: 'displayfield', itemId: 'alert_message', fieldLabel: 'Message'},
                            {xtype: 'displayfield', itemId: 'alert_short_text', fieldLabel: 'Short Text'},
                            {xtype: 'displayfield', hidden: true, actionMode: 'itemCt',  itemId: 'alert_author', fieldLabel: 'Author'},
                            {xtype: 'container', layout: 'form', labelWidth: 175, itemId: 'alert_response_container', hideLabel: true},
                            {xtype: 'displayfield', hidden: true, actionMode: 'itemCt',  itemId: 'alert_created_at', fieldLabel: 'Created at'},
                            {xtype: 'displayfield', itemId: 'alert_disable_cross_jurisdictional', fieldLabel: 'Disable Cross-Jurisdictional alerting?'} ,
                            {xtype: 'displayfield', itemId: 'alert_recipient_count', actionMode: 'itemCt', fieldLabel: 'Total Recipients', html:'Calculating...', cls: 'working-notice recipient_count'}
                        ]},
                        {xtype: 'container', itemId: 'right_detail', columnWidth: .34, layout: 'form', items: [
                            {xtype: 'displayfield', itemId: 'alert_severity', fieldLabel: 'Severity'},
                            {xtype: 'displayfield', itemId: 'alert_status', fieldLabel: 'Status'},
                            {xtype: 'displayfield', itemId: 'alert_acknowledge', fieldLabel: 'Acknowledge'},
                            {xtype: 'displayfield', itemId: 'alert_sensitive', fieldLabel: 'Sensitive (confidential)'},
                            {xtype: 'displayfield', itemId: 'alert_delivery_time', fieldLabel: 'Delivery Time'},
                            {xtype: 'displayfield', itemId: 'alert_delivery_methods', fieldLabel: 'Methods'}
                        ]}
                    ]
                },
                {collapsible: true, collapsed: true, titleCollapse: true, itemId: 'audience_holder',
                    title: 'Alert Recipients (Primary Audience)', width: 800,
                    items: new Ext.ux.AudienceDisplayPanel({width: 'auto', itemId: 'audience_panel'})},
                {xtype: 'spacer', height: 10 },
                {xtype: 'grid', hidden: true, itemId: 'acknowledgement_grid', collapsible: true,
                    title: 'Acknowledgements', width: 800, height: 250, store: this.acknowledgement_store,
                    disableSelection: true, autoExpandColumn: 'name_column',
                    columns:[
                        {id: 'name_column', field: 'name', header: 'Name'},
                        {field: 'email', header: 'E-mail'},
                        {field: 'device', header: 'Acknowledgement Device', width: 200, renderer: function(value){return value.match(/(?!Device)[^:\W]*(?=Device)/i)}},
                        {field: 'response', header: 'Acknowledgement Response', width: 200},
                        {field: 'acknowledged_at', header: 'Acknowledgement Time', renderer: Ext.util.Format.dateRenderer('F j, Y, g:i a'), width: 200}
                    ],
                    bbar:new Ext.Toolbar({
                        //store: this.acknowledgement_store,
                        //pageSize: 10,
                        //prependButtons: true,
                        items: [{text:'Export as CSV', handler: function(){window.open("/han_alerts/" + this.alertId + ".csv");}, scope: this},
                            {text:'Export as PDF', handler: function(){window.open("/han_alerts/" + this.alertId + ".pdf");}, scope: this}, '->'],
                        listeners:{'beforechange': function(toolbar, o){return toolbar.cursor != o.start;}}
                    })
                }
            ]
        });

        Talho.AlertDetail.superclass.constructor.call(this, config);
    },

    initComponent: function(){
        var loadAlert = !Ext.isEmpty(this.alertId) ? true: false;

        Talho.AlertDetail.superclass.initComponent.call(this);

        if(loadAlert) {
            // perform load from AJAX
            Ext.Ajax.request({
                url: '/han_alerts/' + this.alertId + '.json',
                method: 'GET',
                scope: this,
                callback: this.getAlertDetailFromServer_complete
            });

            this.on('render', function(panel){
                panel.loadMask = new Ext.LoadMask(this.getEl());
                panel.loadMask.show();
            }, this, {delay: 10, single: true});

            // show the acknowledgement grid
            this.getComponent('acknowledgement_grid').show();
            this.getComponent('preview_message').hide();
        }
    },

    getAlertDetailFromServer_complete: function(options, success, response){
        var alert_json = Ext.decode(response.responseText);
        var call_downs = [];
        var i = 1;
        while(alert_json.alert.call_down_messages && !Ext.isEmpty(alert_json.alert.call_down_messages[i.toString()])){
            call_downs.push(alert_json.alert.call_down_messages[(i++).toString()]);
        }

        // we're going to rewrite this into something that the loadData method can understand
        var data = {
            'han_alert[title]': alert_json.alert.title,
            'han_alert[message]': alert_json.alert.message,
            'han_alert[short_message]': alert_json.alert.short_message,
            'han_alert[not_cross_jurisdictional]': alert_json.alert.not_cross_jurisdictional,
            'han_alert[severity]': alert_json.alert.severity,
            'han_alert[status]': alert_json.alert.status,
            'han_alert[acknowledge]': alert_json.alert.acknowledge ? call_downs.length > 0 ? 'Advanced' : 'Normal' : 'None',
            'han_alert[sensitive]': alert_json.alert.sensitive,
            'han_alert[delivery_time]': alert_json.alert.delivery_time,
            'han_alert[call_down_messages][]': call_downs,
            'han_alert[created_at]': new Date(alert_json.alert.created_at),
            'han_alert[device_types][]': Ext.pluck(alert_json.alert.alert_device_types, 'device'),
            'han_alert[author]': alert_json.alert.author.display_name,
            'han_alert[recipient_count]': alert_json.recipient_count,
            'han_alert[from_jurisdiction_id]': alert_json.from_jurisdiction_id
        };

        Ext.apply(data, alert_json.audiences);
        this.loadData(data);

        var acknowledgements = [];
        // let's go ahead and rewrite the alert attempts to something that works better for us
        Ext.each(alert_json.alert_attempts, function(attempt, index){
            acknowledgements.push({name: attempt.user.display_name,
                email: attempt.user.email,
                device: attempt.acknowledged_alert_device_type ? attempt.acknowledged_alert_device_type.device : "",
                response: attempt.call_down_response ? alert_json.alert.call_down_messages[attempt.call_down_response.toString()] : attempt.call_down_response === 0 ? "Acknowledged" : "",
                acknowledged_at: attempt.acknowledged_at
            });
        }, this);

        this.acknowledgement_store.loadData(acknowledgements);

        if(this.loadMask) this.loadMask.hide();
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

            var detail_panel = this.getComponent('alert_detail_panel');
            var leftPane = detail_panel.getComponent('left_detail');
            if(!Ext.isEmpty(this.alertId)) leftPane.getComponent('alert_title').getEl().id = this.alertId;
            leftPane.getComponent('alert_title').update(data['han_alert[title]']);
            leftPane.getComponent('alert_message').update(data['han_alert[message]']);
            leftPane.getComponent('alert_short_text').update(data['han_alert[short_message]']);

            var alertResponseContainer = leftPane.getComponent('alert_response_container');
            alertResponseContainer.removeAll(true);
            Ext.each(data['han_alert[call_down_messages][]'], function(call_down, index){
                if(!Ext.isEmpty(call_down))
                {
                    alertResponseContainer.add({xtype: 'displayfield', html: call_down, fieldLabel: 'Alert Response ' + (index + 1).toString()});
                }
            }, this);

            if(data['han_alert[created_at]']){
                leftPane.getComponent('alert_created_at').update(data['han_alert[created_at]'].format('F j, Y, g:i a'));
                leftPane.getComponent('alert_created_at').show();
            }
            if(data['han_alert[author]']){
                leftPane.getComponent('alert_author').update(data['han_alert[author]']);
                leftPane.getComponent('alert_author').show();
            }
            if(data['han_alert[recipient_count]']){
               this.updateRecipientCount(data['han_alert[recipient_count]'], leftPane.getComponent('alert_recipient_count'));
            } else {
              this.buttons[1].disable();
              leftPane.getComponent('alert_recipient_count').removeClass('large-bold');
              leftPane.getComponent('alert_recipient_count').removeClass('big-red');
              leftPane.getComponent('alert_recipient_count').addClass('working-notice');
              leftPane.getComponent('alert_recipient_count').update('Calculating...');
              Ext.Ajax.request({
                url: '/han_alerts/calculate_recipient_count.json',
                method: 'POST',
                params: this.buildAudienceParams(),
                scope: this,
                success: function(result){
                    this.data[ 'han_alert[recipient_count]'] = result.responseText * 1;
                    this.updateRecipientCount(result.responseText, leftPane.getComponent('alert_recipient_count'));
                    this.buttons[1].enable(); //Send Alert button
                },
                failure: function(){
                  leftPane.getComponent('alert_recipient_count').update('Server Error.');
                  this.buttons[1].enable(); //Send Alert button
                }
              });
            }

            leftPane.getComponent('alert_disable_cross_jurisdictional').update(data['han_alert[not_cross_jurisdictional]'] ? 'Yes' : 'No');
            var rightPane = this.getComponent('alert_detail_panel').getComponent('right_detail');
            rightPane.getComponent('alert_severity').update(data['han_alert[severity]']);
            rightPane.getComponent('alert_status').update(data['han_alert[status]']);
            rightPane.getComponent('alert_acknowledge').update(data['han_alert[acknowledge]']);
            rightPane.getComponent('alert_sensitive').update(data['han_alert[sensitive]'] ? 'Yes' : 'No');

            var delivery_time = data['han_alert[delivery_time]'];
            rightPane.getComponent('alert_delivery_time').update(delivery_time <= 90 ? delivery_time + ' minutes' : (delivery_time/60) + ' hours');

            var delivery_methods = data['han_alert[device_types][]'] || [];
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

    updateRecipientCount: function(value, recipientField){
      var warning_level = 100;
      recipientField.removeClass('working-notice');
      if (value > warning_level){ recipientField.addClass('big-red'); } else { recipientField.addClass('large-bold');  }
      recipientField.update(value);
    },

    buildAudienceParams: function(){
      var params = {'user_ids[]': [], 'group_ids[]': [], 'jurisdiction_ids[]': [], 'role_ids[]': []};
      Ext.each(this.data.users, function(user){params['user_ids[]'].push(user.id)});
      Ext.each(this.data.groups, function(group){params['group_ids[]'].push(group.id)});
      Ext.each(this.data.jurisdictions, function(jurisdiction){params['jurisdiction_ids[]'].push(jurisdiction.id)});
      Ext.each(this.data.roles, function(role){params['role_ids[]'].push(role.id)});
      if ( this.data["han_alert[not_cross_jurisdictional]"]) { params['not_cross_jurisdictional'] = 1; }
      params['from_jurisdiction_id'] = this.data["han_alert[from_jurisdiction_id]"]  ;
      return params;
    },

    triggerRecipientStoreLoad: function(panel){
      var params = this.buildAudienceParams();
      panel.getComponent('audience_panel').loadRecipientStoreFromAjax('/audiences/determine_recipients.json', params);
    }
});

Talho.AlertDetail.initialize = function(config){

    Ext.apply(config, {
        items:[new Talho.AlertDetail({
            alertId: config.alertId
        })],
        autoScroll: true,
        closable: true,
        padding: '10'
    });

    return new Ext.Panel(config);
};

Talho.ScriptManager.reg('Talho.AlertDetail', Talho.AlertDetail, Talho.AlertDetail.initialize);
