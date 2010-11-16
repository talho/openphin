Ext.ns('Ext.ux.layout');

Ext.ux.layout.HBoxLayoutReduex = Ext.extend(Ext.layout.HBoxLayout, {
  onLayout: function(container, target) {
        Ext.ux.layout.HBoxLayoutReduex.superclass.onLayout.call(this, container, target);
        var tSize = this.getLayoutTargetSize();
        container.setWidth(tSize.width);
    },

  getLayoutTargetSize : function(){
    var ret = Ext.ux.layout.HBoxLayoutReduex.superclass.getLayoutTargetSize.call(this, arguments);

    var calcs = this.calculateChildBoxes(this.getVisibleItems(this.container), ret);

    ret.width = 0;
    Ext.each(calcs.boxes, function(box){ret.width += box.width;});
    return ret;
    }
});

Ext.Container.LAYOUTS['ux.hblreduex'] = Ext.ux.layout.HBoxLayoutReduex;