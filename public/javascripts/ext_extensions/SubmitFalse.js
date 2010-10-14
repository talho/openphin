Ext.ns('Ext.ux.form');

Ext.ux.form.SubmitFalse = Ext.extend(function(config){
    Ext.apply(this, config);
},
{
    uncheckedValue: 'off',
    
    init:function(component){
        var originalRender = component.onRender;
        var originalSetValue = component.setValue;
        var negValue = this.uncheckedValue;

        var buildInputElement = function(el, name){
            return Ext.DomHelper.insertAfter(el, {
                tag: 'input',
                type: 'hidden',
                value: negValue.toString(),
                name: name
            }, true);
        };

        Ext.apply(component, {
            onRender: function(){
                originalRender.apply(this, arguments);
                if (!this.checked) {
                    this.uncheckedHiddenElement = buildInputElement(this.el, this.getName());
                }
                else {
                    this.uncheckedHiddenElement = null;
                }
            },

            setValue: function(){
                originalSetValue.apply(this, arguments);
                if (this.checked) {
                    if (this.uncheckedHiddenElement != null) {
                        this.uncheckedHiddenElement.remove();
                        this.uncheckedHiddenElement = null;
                    }
                }
                else {
                    this.uncheckedHiddenElement = buildInputElement(this.el, this.getName());
                }
            }
        });
    }
});