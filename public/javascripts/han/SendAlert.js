Ext.ns("Talho");

Talho.SendAlert = Ext.extend(function(){}, {
    constructor: function(config){
        Ext.apply(this, config);

        this.breadCrumb = new Ext.ux.BreadCrumb({
            itemId: 'bread_crumb_control',
            items:['Details', 'Audience', 'Preview'],
            listeners:{
                scope: this,
                'beforenavigation': this.bread_crumb_beforenavigation,
                'toindex': this.bread_crumb_toindex
            }
        });

        var panel = new Ext.Panel({
            title: 'Send Alert',
            padding: 10,
            closable: true,
            autoScroll:true,
            items:[
                {xtype: 'container', height: 50, border: false, layout: 'vbox',
                    layoutConfig: {align: 'center'},
                    items:[
                        {xtype: 'box', html:'Create a New Alert Message'},
                        this.breadCrumb
                ]},
                this._createFormCard()
            ]
        });

        this.getPanel = function(){ return panel; }
    },

    _createFormCard: function(){
        var jurisdiction_store = new Ext.data.JsonStore({
            restful: true,
            url: '/jurisdictions/user_alerter.json',
            idProperty: 'jurisdiction.id',
            fields: [{name: 'name', mapping: 'jurisdiction.name'}, {name: 'id', mapping: 'jurisdiction.id'}]
        });

        jurisdiction_store.load();

        this.call_down_message_container = new Ext.Container({layout: 'form', labelAlign: 'top', defaults: {width: 400, name: 'alert[call_down_messages][]'}});
        this.alert_preview =  new Talho.AlertDetail({});

        this.form_card = new Ext.form.FormPanel({
            border: false,
            layout: 'hbox',
            layoutConfig: {defaultMargins: '10', pack: 'center'},
            autoHeight:true,
            defaults:{autoHeight: true},
            url: '/alerts.json',
            method: 'POST',
            listeners:{
                scope: this,
                'beforeaction': this.applyAudiences,
                'actioncomplete': this.submit_success,
                'actionfailed': this.save_failure
            },
            items: [
                {xtype: 'container', layout: 'form', labelAlign: 'top', defaults:{width:400}, items:[
                    {xtype: 'textfield', fieldLabel: 'Title', name: 'alert[title]', maxLength: '46', allowBlank: false, blankText: 'You must enter a title'},
                    {xtype: 'box', cls:'formInformational', hideLabel: true, html: 'The title must be 46 characters or less including whitespace'},
                    {xtype: 'textarea', fieldLabel: 'Message', name: 'alert[message]', height: 150, enableKeyEvents: true, validator: this.validateMessage.createDelegate(this), listeners:{'keyup': function(ta){Ext.get('message_length').update(ta.getValue().length.toString());}}},
                    {xtype: 'box', cls:'formInformational', hideLabel: true, html: '(<span id="message_length">0</span> characters)<br/>Any message larger than 580 characters including whitespace will cause the message to be truncated and recipients will need to visit the TXPhin website to view the entire message contents.'},
                    this.call_down_message_container,
                    {xtype: 'textarea', fieldLabel: 'Short Message', name: 'alert[short_message]', maxLength: '160', height: 75, validator: this.validateShortMessage.createDelegate(this)},
                    {xtype: 'box', cls:'formInformational', hideLabel: true, html: 'This field allows the use of a shorter message that will be used for certain devices with message length limitations, e.g. SMS (text messaging) and Blackberry PIN. <br/><b>Maximum length: 160 characters.</b>'},
                    {xtype: 'button', text: 'Enter Audiences >', handler: function(){this.breadCrumb.next();}, scope: this, width:'auto'}
                ]},
                {xtype: 'container', itemId:'right_side_form', layout: 'form', items:[
                    {xtype: 'combo', fieldLabel: 'Jurisdiction', hiddenName:'alert[from_jurisdiction_id]', store: jurisdiction_store, mode: 'local', valueField: 'id', displayField: 'name', triggerAction: 'all', autoSelect: true, editable: false, allowBlank: false, blankText: 'Please select a jurisdiction'},
                    {xtype: 'combo', fieldLabel: 'Status', name: 'alert[status]', store: ['Actual', 'Excercise', 'Test'], editable: false, value: 'Actual', triggerAction: 'all'},
                    {xtype: 'combo', fieldLabel: 'Severity', name: 'alert[severity]', store: ['Extreme', 'Severe', 'Moderate', 'Minor', 'Unknown'], editable: false, value: 'Minor', triggerAction: 'all'},
                    {xtype: 'combo', fieldLabel: 'Delivery Time', hiddenName: 'alert[delivery_time]', valueField:'value', displayField:'display', mode: 'local', editable: false, triggerAction: 'all', value: 4320, store: new Ext.data.ArrayStore({
                        data: [[15], [30], [45], [60], [75], [90], [1440], [4320]],
                        fields: ['value', {name: 'display', mapping:0, convert: function(val){return val <= 90 ? val + ' minutes' : (val/60) + ' hours';}}]
                    })},
                    {xtype: 'combo', itemId: 'acknowledge_combo', fieldLabel: 'Acknowledgement', name: 'alert[acknowledge]', store: ['None', 'Normal', 'Advanced'], editable: false, triggerAction: 'all', value: 'None',
                        listeners:{scope: this, 'select': this.acknowledgement_select}},
                    {xtype: 'checkbox', inputValue: 1, boxLabel: 'Disable Cross-Jurisdictional Alerting', name: 'alert[not_cross_jurisdictional]'},
                    {xtype: 'checkbox', inputValue: 1, boxLabel: 'Sensitive (confidential)', name: 'alert[sensitive]'},
                    {xtype: 'checkboxgroup', itemId: 'communication_methods', fieldLabel: 'Communication Methods', cls: 'checkboxGroup', allowBlank: false, columns: 1,
                        emptyText: 'You must select at least one communication method',
                        defaults: {name: 'alert[device_types][]'}, items:[
                        {boxLabel: 'E-mail', inputValue: 'Device::EmailDevice'},
                        {boxLabel: 'Phone', inputValue: 'Device::PhoneDevice', handler: this.handlePhoneTypeCheck, scope: this},
                        {itemId: 'sms_communication_method', boxLabel: 'SMS', inputValue: 'Device::SMSDevice', handler: this.handlePhoneTypeCheck, scope: this},
                        {boxLabel: 'Fax', disabled: true, inputValue: 'Device::FaxDevice'},
                        {itemId: 'blackberry_pin_communication_method', boxLabel: 'Blackberry PIN', inputValue: 'Device::BlackberryDevice', handler: this.handlePhoneTypeCheck, scope: this}
                    ]},
                    {xtype: 'textfield', hidden: true, itemId: 'caller_id_field', actionMode: 'itemCt', fieldLabel: 'Caller ID', name: 'alert[caller_id]', value: '4114114111', maxLength: '10', maskRe: /^[0-9]{0,10}$/}
                ]}
        ]});

        this.wizard_panel = new Ext.Container({
            layout: 'card',
            border: false,
            layoutConfig:{
                layoutOnCardChange:true,
                deferredRender: true
            },
            autoHeight: true,
            items: [
                this.form_card,
                {xtype: 'container', layout:'ux.center', items:[
                    this._createAudiencePanel(),
                    {xtype: 'button', text: 'View Preview >', handler: function(){this.breadCrumb.next();}, scope: this}
                ]},
                {xtype: 'container', layout:'ux.center', items:[
                    this.alert_preview,
                    {xtype: 'button', text: 'Send Alert', handler: function(){this.form_card.getForm().submit();}, scope: this}
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
                this.call_down_message_container.add({xtype:'textfield', fieldLabel: 'Alert Response 1'});
                this.call_down_message_container.add({xtype:'textfield', fieldLabel: 'Alert Response 2'});
                this.call_down_message_container.add({xtype:'button', hideLabel: true, text:"+ Add another response", width: 'auto', name: '', scope: this, handler: function(btn){
                    this.call_down_message_container.insert(this.call_down_message_container.items.indexOf(btn), {xtype:'textfield', fieldLabel: 'Alert Response ' + this.call_down_message_container.items.length.toString()});
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

    applyAudiences: function(form, action){
            var audienceIds = this.audiencePanel.getSelectedIds();

            action.options.params = {};
            action.options.params['send'] = true;
        
            action.options.params['alert[audiences_attributes][1][jurisdiction_ids][]'] = audienceIds.jurisdiction_ids;
            action.options.params['alert[audiences_attributes][1][role_ids][]'] = audienceIds.role_ids;
            action.options.params['alert[audiences_attributes][1][user_ids][]'] = audienceIds.user_ids;
            action.options.params['alert[audience_ids][]'] = audienceIds.group_ids;

            return true;
    },

    submit_success: function(form, action){
        if(action.type == 'submit')
        {
            var path = action.result.alert_path;
            Application.fireEvent('opentab', {title: 'Alert Detail - ' + action.result.title, url: path, id: 'alert_detail_for_' + action.result.id });
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

        return {xtype: 'container', items: [this.audiencePanel], width: 600, height: 400};
    },

    bread_crumb_beforenavigation: function(bc, currentIndex, newIndex){
        var valid = true;
        if(currentIndex === 0)
        {
            valid = this.form_card.getForm().isValid();
        }
        if(valid && newIndex === 2)
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
        if(newIndex === 2) // if this is the preview panel
        {
            // build the output of the form panel and audience panel into a consumable object then pass that to alert_preview.loadData()
            var data = this.form_card.getForm().getFieldValues();
            if(data['alert[acknowledge]'] === 'Advanced' && Ext.clean(Ext.pluck(data['alert[call_down_messages][]'], 'length')).length === 0) // if we're at advanced and there are no non 0-length strings in the
            {
                var acknowledge_combo = this.form_card.getComponent('right_side_form').getComponent('acknowledge_combo');
                acknowledge_combo.setValue('Normal');
                acknowledge_combo.fireEvent('select', acknowledge_combo, acknowledge_combo.getStore().getAt(acknowledge_combo.getStore().find('field1', 'Normal'))); // go the long way around to get the select event to fire since selectByValue or setValue do not fire select

                data = this.form_card.getForm().getFieldValues();
            }
            data['alert[device_types][]'] = this.getSelectedCommunicationDevices();
            Ext.apply(data, this.audiencePanel.getSelectedItems());

            this.alert_preview.loadData(data);
        }

        this.wizard_panel.getLayout().setActiveItem(newIndex);
    },

    getSelectedCommunicationDevices: function(){
        var selectedBoxes = this.form_card.getComponent('right_side_form').getComponent('communication_methods').getValue();
        return Ext.pluck(selectedBoxes, 'inputValue');
    },

    handlePhoneTypeCheck: function(){
        var cbs = this.getSelectedCommunicationDevices();
        var caller_id = this.form_card.getComponent('right_side_form').getComponent('caller_id_field');
        if(cbs.indexOf('Device::SMSDevice') != -1 || cbs.indexOf('Device::PhoneDevice') != -1 || cbs.indexOf('Device::BlackberryDevice') != -1) // We should be showing the "Caller ID" box
        {
            caller_id.show();
        }
        else // the "Caller ID" box should not be visible
        {
            caller_id.hide();
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
    }
});

Talho.SendAlert.initialize = function(config){
    var send_alert = new Talho.SendAlert(config);
    return send_alert.getPanel();
};