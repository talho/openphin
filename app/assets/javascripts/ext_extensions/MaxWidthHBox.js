

Ext.layout.MaxWidthHBoxLayout = Ext.extend(Ext.layout.HBoxLayout, {
    calculateChildBoxes: function(visibleItems, targetSize)
    {
        for (i = 0; i < visibleItems.length; i++) {
            child       = visibleItems[i];

            if(!child.flex && child.maxWidth && child.getWidth())
            {
                child.setSize('auto');
            }

            childHeight = child.height;
            childWidth  = child.width;
            canLayout   = true;//!child.hasLayout && Ext.isFunction(child.doLayout);

            if (!Ext.isNumber(childWidth) && !child.flex && !childWidth && Ext.isNumber(child.maxWidth) && canLayout) {
                child.doLayout();

                childSize   = child.getSize();
                child.setSize(Math.min(childSize.width, child.maxWidth));
            }
        }

        return Ext.layout.MaxWidthHBoxLayout.superclass.calculateChildBoxes.call(this, visibleItems, targetSize);
    }
});

Ext.Container.LAYOUTS.mwhbox = Ext.layout.MaxWidthHBoxLayout;