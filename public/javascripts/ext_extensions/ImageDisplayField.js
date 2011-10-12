Ext.ns('Ext.ux')

/**
 * @class Ext.ux.form.ImageDisplayField
 * @extends Ext.form.DisplayField
 * A display-only span with its class set to an "image" class specified as value
 * @constructor
 * Creates a new DisplayField.
 * @param {Object} config Configuration options
 * @xtype displayfield
 */
Ext.ux.ImageDisplayField = Ext.extend(Ext.BoxComponent,  {
    value: '',

    autoEl: {tag: 'span', cls: 'ux-image-display-field'},

    onRender: function(){
        Ext.ux.ImageDisplayField.superclass.onRender.apply(this, arguments);

        this.el.addClass(this.value);
    },

    setValue: function(val){
        if(this.rendered){
            this.el.removeClass(this.value);
            this.el.addClass(val);
        }
        this.value = val;

        return this;
    }
});

Ext.reg('imagedisplayfield', 'Ext.ux.ImageDisplayField');