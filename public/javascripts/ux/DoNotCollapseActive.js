
Ext.define('Talho.ux.DoNotCollapseActive', {
    alertnateClassName: ['Ext.ux.plugins.DoNotCollapseActive'],
    alias: ['plugin.donotcollapseactive'],
    constructor: function(config){
        config = config || {};

        Ext.apply(this, config);
    },

    init: function(cpt){
        this.component = cpt;

        this.component.items.each(function(item){
            item.canCollapse = true;
            item.on('beforecollapse', this.canCollapse)
        }, this);

        if(Ext.isNumber(this.component.activeItem))
        {
            this.component.items.getAt(this.component.activeItem).canCollapse = false; // make sure the initial active item cannot collapse
        }

        if(!Ext.isDefined(this.component.layoutConfig)) this.component.layoutConfig = {};
        Ext.apply(this.component.layoutConfig, {
           beforeExpandOriginal: Ext.layout.AccordionLayout.prototype.beforeExpand,
           beforeExpand : function(p, anim){
                this.activeItem.canCollapse = true; // give the active item permission to collapse. This is only called when another item is expanded.
                this.beforeExpandOriginal(p, anim);
            }
        });
    },

    canCollapse: function(panel){
        var collapse = panel.canCollapse === true;
        panel.canCollapse = false; // We've not collapsed the item, take away its permission to collapse
        return collapse;
    }
});