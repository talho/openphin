
Ext.ns("Ext.ux.plugins");

Ext.ux.plugins.ViewLoadMask = Ext.extend(Object,{
    constructor: function(config){
        config = config || {};

        Ext.apply(this, config);
    },

    init: function(cpt){
        if(cpt.getStore())
        {
            cpt.on('afterrender', function(cpt){
                cpt.mask = new Ext.LoadMask(cpt.getEl(), {store: cpt.getStore() });
                cpt.mask.show();
            });
        }
    }
});

Ext.preg('viewloadmask', Ext.ux.plugins.ViewLoadMask);