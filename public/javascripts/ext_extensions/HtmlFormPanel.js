Ext.ns('Ext.ux');

/**
 *
 * @constructor
 * @param   {Object}    config
 * @config    {Element}  htmlForm       The dom form element that will be used as the informational source as well as the initial content
 */
Ext.ux.HtmlFormPanel = Ext.extend(Ext.form.FormPanel, {
    initComponent: function(){
        this.html = this.htmlForm.dom.innerHTML;
        this.initialConfig.url = this.htmlForm.getAttribute('action');
        this.initialConfig.method = this.htmlForm.getAttribute('method').toUpperCase();

        Ext.ux.HtmlFormPanel.superclass.initComponent.call(this);

        this.on('afterrender', this.setupSubmitButton, this);
    },

    setupSubmitButton: function(cpt){
        var submitBtn = cpt.getEl().select('input[type="submit"]');
        if(submitBtn)
        {
            submitBtn.on('click', function(){ this.getForm().submit(); }, this);
        }
    }
});