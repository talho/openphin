Ext.ns("Talho");

Talho.SendAlert = Ext.extend(function(){}, {
    mode: 'new',
    audience_warning_size: 100,   // alerts with audiences larger than this will need user confirmation before sending
    constructor: function(config){
        Ext.apply(this, config);

        this.breadCrumb = new Ext.ux.BreadCrumb({
            itemId: 'bread_crumb_control',
            width: 500,
            items:['Alert Details', 'Recipients', 'Preview'],
            listeners:{
                scope: this,
                'beforenavigation': this.bread_crumb_beforenavigation,
                'toindex': this.bread_crumb_toindex
            }
        });
        
        this.breadCrumb.on('afterrender', function(){
          this.breadCrumb.setWidth(this.breadCrumb.getEl().down('*').getWidth());
          this.getPanel().doLayout();
        }, this, {delay: 1});

        var panel = new Ext.Panel({
            title: this.title,
            padding: 10,
            closable: true,
            autoScroll:true,
            items:[
                {xtype: 'container', height: 50, layout: 'vbox',
                    layoutConfig: {align: 'center'},
                    items:[
                        this.breadCrumb
                ]},
                this._createFormCard()
            ]
        });
        panel.addEvents('fatalerror');

        var showLoading = false;
        switch(this.mode)
        {
            case 'new': break; // do nothing
            case 'update':
            case 'cancel': // load values from server
              showLoading = true;
              this.loadAlertDetail(this.mode);
              break;
        }

        if(showLoading)
        {
            panel.on('render', function(panel){
                panel.loadMask = new Ext.LoadMask(panel.getEl(), {msg:"Loading...", removeMask: true});
                panel.loadMask.show();
            }, this, {single: true, delay: 1})
        }

        this.getPanel = function(){ return panel; }
    },

    _createFormCard: function(){
        var jurisdiction_store = new Ext.data.JsonStore({
            restful: true,
            url: '/jurisdictions/user_alerter.json',
            idProperty: 'id',
            fields: [{name: 'name', mapping: 'name'}, {name: 'id', mapping: 'id'}],
            listeners: {
              scope: this,
              'load': function(store, records){
                if(records.length == 1){
                  this.form_card.getComponent('right_side_form').getComponent('alert_jurisdiction').setValue(records[0].get('id'));
                }
              }
            }
        });

        jurisdiction_store.load();

        this.call_down_message_container = new Ext.Container({layout: 'form', labelAlign: 'top', defaults: {width: 400}});
        this.alert_preview =  new Talho.AlertDetail({
          width: 820,
          buttons: [          
            {xtype: 'button', text: 'Back', handler: function(){this.breadCrumb.previous();}, scope: this},
            {xtype: 'button', text: 'Send Alert', handler: this.submit_alert, scope: this}
          ]
        });

        this.form_card = new Ext.form.FormPanel({
            border: false,
            layout: 'column',
            width: '820',
            defaults:{style: 'padding:5px;', columnWidth: .5},
            url: '/han_alerts.json',
            method: 'POST',
            listeners:{
                scope: this,
                'beforeaction': this.beforeSubmit,
                'actioncomplete': this.submit_success,
                'actionfailed': this.save_failure
            },
            items: [
                {xtype: 'container', itemId:'left_side_form', layout: 'form', labelAlign: 'top', defaults:{anchor: '100%'}, items:[
                    {xtype: 'textfield', itemId:'alert_title', fieldLabel: 'Title', name: 'han_alert[title]', maxLength: '46', style: 'font-weight: bold; font-size: 150%; height: 3ex;', allowBlank: false, blankText: 'Alerts must have a title'},
                    {xtype: 'box', itemId: 'alert_title_label', cls:'formInformational', hideLabel: true, html: 'The title must be 46 characters or less including whitespace'},
                    {xtype: 'textarea', itemId: 'alert_message', fieldLabel: 'Message', name: 'han_alert[message]', height: 150, enableKeyEvents: true, validator: this.validateMessage.createDelegate(this), listeners:{'keyup': function(ta){Ext.get('message_length').update(ta.getValue().length.toString());}}},
                    {xtype: 'box', cls:'formInformational', hideLabel: true, html: '(<span id="message_length">0</span> characters)<br/>Any message larger than 580 characters including whitespace will cause the message to be truncated and recipients will need to visit the TXPhin website to view the entire message contents.'},
                    this.call_down_message_container,
                    {xtype: 'textarea', itemId: 'alert_short_message', fieldLabel: 'Short Message', name: 'han_alert[short_message]', maxLength: '160', height: 75, validator: this.validateShortMessage.createDelegate(this)},
                    {xtype: 'box', cls:'formInformational', hideLabel: true, html: 'This field allows the use of a shorter message that will be used for certain devices with message length limitations, e.g. SMS (text messaging) and Blackberry PIN. <br/><b>Maximum length: 160 characters.</b>'}
                ]},
                {xtype: 'container', itemId:'right_side_form', layout: 'form', defaults: {anchor: '100%'}, items:[
                    {xtype: 'combo', itemId: 'alert_jurisdiction', fieldLabel: 'Jurisdiction', hiddenName:'han_alert[from_jurisdiction_id]', store: jurisdiction_store, mode: 'local', valueField: 'id', displayField: 'name', triggerAction: 'all', autoSelect: true, editable: false, allowBlank: false, blankText: 'Please select a jurisdiction'},
                    {xtype: 'combo', itemId: 'alert_status', fieldLabel: 'Status', name: 'han_alert[status]', store: ['Actual', 'Excercise', 'Test'], editable: false, value: 'Actual', triggerAction: 'all'},
                    {xtype: 'combo', itemId: 'alert_severity', fieldLabel: 'Severity', name: 'han_alert[severity]', store: ['Extreme', 'Severe', 'Moderate', 'Minor', 'Unknown'], editable: false, value: 'Minor', triggerAction: 'all'},
                    {xtype: 'combo', itemId: 'alert_delivery_time', fieldLabel: 'Delivery Time', hiddenName: 'han_alert[delivery_time]', valueField:'value', displayField:'display', mode: 'local', editable: false, triggerAction: 'all', value: 4320, store: new Ext.data.ArrayStore({
                        data: [[15], [30], [45], [60], [75], [90], [1440], [4320]],
                        fields: ['value', {name: 'display', mapping:0, convert: function(val){return val <= 90 ? val + ' minutes' : (val/60) + ' hours';}}]
                    })},
                    {xtype: 'combo', itemId: 'acknowledge_combo', fieldLabel: 'Acknowledgement', name: 'han_alert[acknowledge]', store: ['None', 'Normal', 'Advanced'], editable: false, triggerAction: 'all', value: 'None',
                        listeners:{scope: this, 'select': this.acknowledgement_select}},
                    {xtype: 'checkbox', itemId: 'alert_cross_jurisdictional', inputValue: 1, boxLabel: 'Disable Cross-Jurisdictional Alerting', name: 'han_alert[not_cross_jurisdictional]'},
                    {xtype: 'checkbox', itemId: 'alert_sensitive', inputValue: 1, boxLabel: 'Sensitive (confidential)', name: 'han_alert[sensitive]'},
                    {xtype: 'checkboxgroup', itemId: 'communication_methods', fieldLabel: 'Communication Methods', cls: 'checkboxGroup', allowBlank: false, columns: 1,
                        emptyText: 'You must select at least one communication method',
                        defaults: {name: 'han_alert[device_types][]'}, items:[
                        {boxLabel: 'E-mail', inputValue: 'Device::EmailDevice'},
                        {boxLabel: 'Phone', inputValue: 'Device::PhoneDevice', handler: this.handlePhoneTypeCheck, scope: this},
                        {itemId: 'sms_communication_method', boxLabel: 'SMS', inputValue: 'Device::SMSDevice', handler: this.handlePhoneTypeCheck, scope: this},
                        {boxLabel: 'Fax', disabled: true, inputValue: 'Device::FaxDevice'},
                        {itemId: 'blackberry_pin_communication_method', boxLabel: 'Blackberry PIN', inputValue: 'Device::BlackberryDevice', handler: this.handlePhoneTypeCheck, scope: this},
                        {xtype: 'hidden', value:'Device::ConsoleDevice'}
                    ]}
                ]}
          ],
          buttons: [{xtype: 'button', itemId: 'alert_next_btn', text: 'Next', handler: function(){this.breadCrumb.next();}, scope: this}]
        });

        this.wizard_panel = new Ext.Container({
            layout: 'card',
            border: false,
            layoutConfig:{
                layoutOnCardChange:true,
                deferredRender: true
            },
            autoHeight: true,
            items: [
                {xtype: 'container', layout: 'ux.center', items: this.form_card },
                {xtype: 'container', itemId: 'audience_container', layout:'ux.center', items:[
                    this._createAudiencePanel()
                ]},
                {xtype: 'container', layout:'ux.center', items:[
                    this.alert_preview
                ]}
            ],
            activeItem: 0            
        });

        return this.wizard_panel;
    },

    acknowledgement_select: function(combo, record){
        if(record.get('field1') === 'Advanced')
        {
            if(this.call_down_message_container.items.length === 0)
            {
                // insert 2 text boxes and a button to add more into the acknowledgement
                this.call_down_message_container.add({xtype:'textfield', fieldLabel: 'Alert Response 1', name: 'han_alert[call_down_messages][1]'});
                this.call_down_message_container.add({xtype:'textfield', fieldLabel: 'Alert Response 2', name: 'han_alert[call_down_messages][2]'});
                this.call_down_message_container.add({xtype:'button', hideLabel: true, text:"+ Add another response", width: 'auto', name: '', scope: this, handler: function(btn){
                    var resp_num = this.call_down_message_container.items.length.toString();
                    this.call_down_message_container.insert(this.call_down_message_container.items.indexOf(btn), {xtype:'textfield', fieldLabel: 'Alert Response ' + resp_num, name: 'han_alert[call_down_messages][' + resp_num + ']'});
                    this.form_card.doLayout();
                    this.getPanel().doLayout();
                }});

                // And we need to disable sms and blackberry because they cannot handle advanced acknowledgements
                var cbGroup = this.form_card.getComponent('right_side_form').getComponent('communication_methods');
                cbGroup.items.get(cbGroup.items.findIndex('itemId', 'sms_communication_method')).disable().setValue();
                cbGroup.items.get(cbGroup.items.findIndex('itemId', 'blackberry_pin_communication_method')).disable().setValue();
            }
        }
        else
        {
            // clear the container that contains the acknowledgement call downs.
            this.call_down_message_container.removeAll(true);

            // Enable the checkboxes
            var cbGroup = this.form_card.getComponent('right_side_form').getComponent('communication_methods');
            cbGroup.items.get(cbGroup.items.findIndex('itemId', 'sms_communication_method')).enable();
            cbGroup.items.get(cbGroup.items.findIndex('itemId', 'blackberry_pin_communication_method')).enable();
        }
        this.form_card.doLayout();
        this.getPanel().doLayout();
    },

    beforeSubmit: function(form, action){
      if (action.options.force === true || this.checkAudienceSize() ){
        this.applyAudiences(form, action);
      } else {
        return false;
      }
    },

    applyAudiences: function(form, action){
        action.options.params = {};
        action.options.params['send'] = true;
        if(this.mode === 'new')
        {
            var audienceIds = this.audiencePanel.getSelectedIds();
            action.options.params['han_alert[audiences_attributes][1][jurisdiction_ids][]'] = audienceIds.jurisdiction_ids;
            action.options.params['han_alert[audiences_attributes][1][role_ids][]'] = audienceIds.role_ids;
            action.options.params['han_alert[audiences_attributes][1][user_ids][]'] = audienceIds.user_ids;
            action.options.params['han_alert[audience_ids][]'] = audienceIds.group_ids;
        }
        return true;
    },

    checkAudienceSize: function(){
      if (this.alert_preview.data['han_alert[recipient_count]'] > this.audience_warning_size ){
        Ext.Msg.show({
          scope: this,
          title:'Large Audience',
          msg: 'ATTENTION: This alert will be sent to <span style="font-size: 120%; font-weight: bold;">' + this.alert_preview.data['han_alert[recipient_count]'] +
               '</span> people.  <br> Press OK to send the alert. <br> Press CANCEL to modify the audience.',
          buttons: Ext.Msg.OKCANCEL,
          fn: function(buttonId){if (buttonId == 'ok') { this.form_card.getForm().submit({force: true}) } else { this.breadCrumb.previous(); } },
          animEl: 'elId',
          closable: false,
          icon: Ext.MessageBox.WARNING
        });
        return false;
      } else {
        return true;
      }
    },

    submit_alert: function(){
        if(this.mode === 'new')
            this.form_card.getForm().submit();
        else if(this.mode === 'update' || this.mode === 'cancel')
            this.form_card.getForm().submit({url:'/han_alerts/' + this.alertId + '.json', method: 'PUT'});
    },

    submit_success: function(form, action){
        if(action.type == 'submit')
        {
            Application.fireEvent('opentab', {title: 'Alert Log and Reporting', url: '/han_alerts', id: 'han_alert_log', initializer: 'Talho.Alerts' });
            this.getPanel().ownerCt.remove(this.getPanel()); // We're going to close the window now that we've successfully created an alert
        }
    },

    save_failure: function(form, action){
        Ext.Msg.alert('Error', action.response.responseText);
    },

    _createAudiencePanel: function(){
        this.audiencePanel = new Ext.ux.AudiencePanel({
            showGroups: true,
            width: 600,
            height: 400
        });

        return {xtype: 'panel', border: false, itemId: 'audience_container', items: [this.audiencePanel], width: 600, 
          buttons: [
            {xtype: 'button', text: 'Back', handler: function(){this.breadCrumb.previous();}, scope: this},
            {xtype: 'button', text: 'Next', handler: function(){this.breadCrumb.next();}, scope: this}
          ]
        };
    },

    bread_crumb_beforenavigation: function(bc, currentIndex, newIndex){
        var valid = true;
        if(currentIndex === 0)
        {
            valid = this.form_card.getForm().isValid();
        }
        if(valid && newIndex === 2) // leaving the preview as "2" is a bit of a hack: if we have a 2 to go to, then the audience panel is there, otherwise it's not
        {
            var selectedItems = this.audiencePanel.getSelectedItems();
            valid = selectedItems.groups.length > 0 || selectedItems.roles.length > 0 || selectedItems.jurisdictions.length > 0 || selectedItems.users.length > 0;
            if(!valid)
            {
                alert('Please select at least one user, jurisdiction, role, or group to send this alert to.');
                if(currentIndex !== 1)
                    this.breadCrumb.goToIndex(1);
            }
        }
        return valid; // need to validate at this stage before we let them move off the current page
    },

    bread_crumb_toindex: function(bc, previousIndex, newIndex){
        if(newIndex === this.breadCrumb.length - 1) // if this is the last panel
        {
            var data = {};
            if(this.mode === 'new')
            {
                // build the output of the form panel and audience panel into a consumable object then pass that to alert_preview.loadData()
                data = this.form_card.getForm().getFieldValues();
                var call_downs = this.getCallDownMessages(data);
                if(data['han_alert[acknowledge]'] === 'Advanced' && Ext.clean(Ext.pluck(call_downs, 'length')).length === 0) // if we're at advanced and there are no non 0-length strings in the
                {
                    var acknowledge_combo = this.form_card.getComponent('right_side_form').getComponent('acknowledge_combo');
                    acknowledge_combo.setValue('Normal');
                    acknowledge_combo.fireEvent('select', acknowledge_combo, acknowledge_combo.getStore().getAt(acknowledge_combo.getStore().find('field1', 'Normal'))); // go the long way around to get the select event to fire since selectByValue or setValue do not fire select

                    data = this.form_card.getForm().getFieldValues();
                }
                data['han_alert[call_down_messages][]'] = call_downs;
                data['han_alert[device_types][]'] = this.getSelectedCommunicationDevices();
                Ext.apply(data, this.audiencePanel.getSelectedItems());
            }
            else if(this.mode === 'update' || this.mode === 'cancel')
            {
                var alert_json = this.alert_json.alert.han_alert || this.alert_json.alert;
                data = this.form_card.getForm().getFieldValues();
                // look for json to handle the rest
                data['han_alert[title]'] = '[' + (this.mode === 'cancel' ? 'Cancel' : 'Update') + '] - ' + alert_json.title;
                data['han_alert[status]'] = alert_json.status;
                data['han_alert[from_jurisdiction_id]'] = alert_json.from_jurisdiction_id;
                if (this.recipient_count) {
                  data['han_alert[recipient_count]'] = this.recipient_count;
                }
                data['han_alert[call_down_messages][]'] = [];
                Ext.each(this.getSelectedResponders(), function(responder, index){
                    responder = responder * 1; // turn this into an int
                    data['han_alert[call_down_messages][]'][responder - 1] = alert_json.call_down_messages[responder];
                }, this);

                data.roles = [];
                data.users = [];
                data.jurisdictions = [];
                data.groups = [];

                Ext.each(this.alert_json.audiences.roles, function(r){data.roles.push({name: (r.role || r).name, id: (r.role || r).id, type: 'role'})});
                Ext.each(this.alert_json.audiences.users, function(u){data.users.push({name: (u.user || u).display_name, id: (u.user || u).id, profile_path: '/users/' + (u.user || u).id + '/profile', type: 'user'})});
                Ext.each(this.alert_json.audiences.jurisdictions, function(j){data.jurisdictions.push({name: (j.jurisdiction || j).name, id: (j.jurisdiction || j).id, type: 'jurisdiction'})});
                Ext.each(this.alert_json.audiences.groups, function(g){data.groups.push({name: (g.group || g).name, id: (g.group || g).id, type: 'group'})});
            }
            this.alert_preview.loadData(data);
        }

        this.wizard_panel.getLayout().setActiveItem(newIndex);
    },

    getCallDownMessages: function(data){
        var i = 1, call_downs = [];
        var call_down = data['han_alert[call_down_messages][' + i + ']'];
        while(!Ext.isEmpty(call_down, true))
        {
            call_downs.push(call_down);
            call_down = data['han_alert[call_down_messages][' + ++i + ']']
        }

        return call_downs;
    },

    getSelectedCommunicationDevices: function(){
        var comm_methods = this.form_card.getComponent('right_side_form').getComponent('communication_methods');
        if(comm_methods){
            var selectedBoxes = comm_methods.getValue();
            return Ext.pluck(selectedBoxes, 'inputValue');
        }

        return [];
    },

    getSelectedResponders: function(){
        var comm_methods = this.form_card.getComponent('right_side_form').getComponent('alert_responders');
        if(comm_methods){
            var selectedBoxes = comm_methods.getValue();
            return Ext.pluck(selectedBoxes, 'inputValue');
        }

        return [];
    },

    handlePhoneTypeCheck: function(){
        var cbs = this.getSelectedCommunicationDevices();
        var caller_id = this.form_card.getComponent('right_side_form').getComponent('caller_id_field');
        if(cbs.indexOf('Device::SMSDevice') != -1 || cbs.indexOf('Device::PhoneDevice') != -1) // We should be showing the "Caller ID" box
        {
            if(!this.form_card.getComponent('right_side_form').getComponent('caller_id_field'))
            {
                this.form_card.getComponent('right_side_form').add({xtype: 'textfield', itemId: 'caller_id_field', actionMode: 'itemCt', fieldLabel: 'Caller ID', name: 'han_alert[caller_id]', value: '', allowBlank: false, maxLength: '10', maskRe: /^[0-9]{0,10}$/});
                this.form_card.doLayout();
            }
        }
        else // the "Caller ID" box should not be visible
        {
            this.form_card.getComponent('right_side_form').getComponent('caller_id_field').destroy();
            this.form_card.doLayout();
        }
    },

    validateShortMessage: function(value){
        var cbs = this.getSelectedCommunicationDevices();
        if(Ext.isEmpty(value) && (cbs.indexOf('Device::SMSDevice') != -1 || cbs.indexOf('Device::BlackberryDevice') != -1))
        {
            return 'Short message is required to send via SMS or Blackberry Device';
        }
        else
            return true;
    },

    validateMessage: function(value){
        var cbs = this.getSelectedCommunicationDevices();
        if(Ext.isEmpty(value) && (cbs.indexOf('Device::EmailDevice') != -1 || cbs.indexOf('Device::PhoneDevice') != -1))
        {
            return 'Message is required to send via Email or Phone';
        }
        else
            return true;
    },

    loadAlertDetail: function(mode){
        Ext.Ajax.request({
            url: '/han_alerts/' + this.alertId + '/edit.json?_action=' + mode,
            method: 'GET',
            callback: this.alertDetailLoad_complete,
            scope: this
        })
    },

    /**
     * Loads the values for the form manually. Removes a number of form items, changes a few others, and loads values into the rest.
     * @param {Object}  options     The configuration object passed in to the Ajax.request
     * @param {Boolean} success     The success property, as determined by Ext's default methods
     * @param {Object}  response    The action response. Should decode response.responseText to get the JSON result.
     */
    alertDetailLoad_complete: function(options, success, response){
        if(success)  
        {
            this.alert_json = Ext.decode(response.responseText, true);
            var alertInfo = this.alert_json.alert.han_alert || this.alert_json.alert;
            var deviceTypes = this.alert_json.devices;

            // load the form up
            var bcContainer = this.breadCrumb.ownerCt;
            var index = bcContainer.items.indexOf(this.breadCrumb);
            this.breadCrumb.destroy();
            this.breadCrumb = new Ext.ux.BreadCrumb({
                itemId: 'bread_crumb_control',
                items:['Details', 'Preview'],
                listeners:{
                    scope: this,
                    'beforenavigation': this.bread_crumb_beforenavigation,
                    'toindex': this.bread_crumb_toindex
                }
            });
            bcContainer.insert(index, this.breadCrumb);

            this.wizard_panel.remove(this.wizard_panel.getComponent('audience_container'), true);

            var leftSide = this.form_card.getComponent('left_side_form');
            var rightSide = this.form_card.getComponent('right_side_form');

            // rewrite forms that should be different
            var alertTitle = leftSide.getComponent('alert_title');
            var ix = leftSide.items.indexOf(alertTitle);
            leftSide.remove(alertTitle, true);
            leftSide.insert(ix, {xtype: 'displayfield', itemId:'alert_title', fieldLabel: 'Title', name: 'han_alert[title]', value: '[' + (this.mode === 'cancel' ? 'Cancel' : 'Update') + '] - ' + alertInfo.title});
            leftSide.getComponent('alert_title_label').destroy();
            rightSide.getComponent('alert_jurisdiction').disable();

            // remove unneeded fields
            rightSide.getComponent('alert_status').destroy();
            rightSide.getComponent('communication_methods').destroy();
            rightSide.getComponent('acknowledge_combo').getStore().loadData(['None', 'Normal']);

            // If there are call down messages, create the checkbox group for selecting which responses to carry through
            if(Ext.isObject(alertInfo.call_down_messages))
            {
                var i = 1, groupItems = [];
                while(!Ext.isEmpty(alertInfo.call_down_messages[i]))
                {
                    groupItems.push({boxLabel: alertInfo.call_down_messages[i], inputValue: i, checked: true});
                    i++;
                }
                if(groupItems.length > 0)
                    rightSide.add({xtype: 'checkboxgroup', itemId: 'alert_responders', fieldLabel: 'Responders', cls: 'checkboxGroup', columns: 1, defaults: {name: 'han_alert[responders][]'}, items: groupItems})
            }

            // create hidden fields
            Ext.each(deviceTypes, function(value){
                rightSide.add({xtype:'hidden', value: value, name: 'han_alert[device_types][]'})
            }, this);
            leftSide.add({xtype:'hidden', value: this.mode, name: '_action'});

            this.recipient_count = this.alert_json.recipient_count;
            leftSide.doLayout();
            rightSide.doLayout();
            this.getPanel().doLayout();

            // fill in values
            leftSide.getComponent('alert_message').setValue(alertInfo.message);
            leftSide.getComponent('alert_short_message').setValue(alertInfo.short_message);
            rightSide.getComponent('alert_severity').setValue(alertInfo.severity);


            this.getPanel().loadMask.hide();
        }
        else
        {
            try {
                var msg = Ext.decode(response.responseText, true).msg;
                alert(msg);
            }
            catch(e){
                alert("There was an issue with loading the information for the alert. Please try again.");
            }
            this.getPanel().fireEvent('fatalerror', this.getPanel());
        }
    }
});

Talho.SendAlert.initialize = function(config){
    var send_alert = new Talho.SendAlert(config);
    return send_alert.getPanel();
};

Talho.ScriptManager.reg('Talho.SendAlert', Talho.SendAlert, Talho.SendAlert.initialize);
