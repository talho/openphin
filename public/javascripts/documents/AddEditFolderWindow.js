Ext.ns('Talho.ux.documents');

Talho.ux.documents.AddEditFolderWindow = Ext.extend(Ext.Window,  {
    height: 600,
    width: 500,
    title: 'Add Folder',

    constructor: function(config){
        this.addEvents('foldercreated');

        Ext.apply(config, {
            layout: 'fit',
            items: {
                xtype: 'tabpanel',
                itemId: 'tp',
                activeTab: 0,
                items:[
                    {title: 'General Options', xtype:'form', padding: '5', items:[
                        {xtype: 'field', fieldLabel: 'Folder Name', anchor: '100%'},
                        {xtype: 'checkbox', boxLabel: 'Notify users when files are added to this folder.', anchor: '100%'},
                        {xtype: 'checkbox', boxLabel: 'Notify users when they have been invited to share this folder.', anchor: '100%'}
                    ]},
                    {title: 'Sharing', itemId: 'sh', layout: 'vbox', layoutConfig: {align: 'stretch'}, padding: '5', items:[
                        {xtype:'container', layout: 'form', labelAlign: 'top', items:[
                            {xtype: 'radiogroup', columns: 1, fieldLabel: 'Share As', anchor: '100%', items:[
                                {boxLabel: 'Not Shared', name: 'sharing', checked: true},
                                {boxLabel: 'Public - Shared with all users. You can create a completely external link for files in this folder.', name: 'sharing'},
                                {boxLabel: 'Protected - Shared with all users, but users will be required to log in before accessing.', name: 'sharing'},
                                {boxLabel: 'Specific Audience - Only accessible to the audience specified below', name: 'sharing', scope: this, handler: function(cb, checked){
                                    if(checked) this.getComponent('tp').getComponent('sh').getComponent('ap').enable();
                                    else this.getComponent('tp').getComponent('sh').getComponent('ap').disable(); 
                                }}
                            ]}
                        ]},
                        {itemId: 'ap', xtype: 'audiencepanel', flex: 1, disabled: true}
                    ]},
                    {title: 'Permissions'}
                ],
                buttons:[
                    {text: 'Save'},
                    {text: 'Cancel', scope: this, handler: function(){this.close()}}
                ]
            }
        });

        if(config.isEdit)
            this.title = 'Edit Folder';

        Talho.ux.documents.AddEditFolderWindow.superclass.constructor.call(this, config);
    }
});