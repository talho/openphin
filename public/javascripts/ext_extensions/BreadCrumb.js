
Ext.ns('Ext.ux');

Ext.ux.BreadCrumb = Ext.extend(Ext.Container, {
    border: false,

    initComponent: function(){

        this.addEvents(
                'beforenavigation',
                'next',
                'previous',
                'toindex'
        );

        var items = this.items;
        this.length = items.length;
        delete this.items;

        // Build up the HTML string with the strings provided in the items element
        var itemList = Ext.DomHelper.createDom({tag:'ol', cls:'breadCrumbList'});
        var itemTemplate = Ext.DomHelper.createTemplate({tag: 'li', cls: 'breadCrumbItem', html: '{0}', index: '{1}'});
        itemTemplate.compile();
        Ext.each(items, function(item, index){
           if(Ext.isString(item) || Ext.isString(item.html) || Ext.isString(item.title))
           {
               itemTemplate.append(itemList, [item.html || item.title || item, index]);
           }
        });

        var extItemList = Ext.get(itemList);
        extItemList.down('[index=0]').addClass('selected');
        extItemList.on('click', this.on_breadcrumb_item_clicked, this);
        this.contentEl = itemList;

        Ext.ux.BreadCrumb.superclass.initComponent.call(this);
    },

    on_breadcrumb_item_clicked: function(event, element, o){
        var elem = event.getTarget('.breadCrumbItem', null, true);
        if(!elem || elem.hasClass('selected'))
            return; // Do nothing if we didn't click on a breadcrumbItem or if that item is already selected

        var newIndex = parseInt(elem.getAttribute('index'));
        this.goToIndex(newIndex);
    },

    next: function(){
        var selected = this.getEl().select('.selected').first();
        var selectedIndex = parseInt(selected.getAttribute('index'));
        this.goToIndex(selectedIndex + 1);
    },

    previous: function(){
        var selected = this.getEl().select('.selected').first();
        var selectedIndex = parseInt(selected.getAttribute('index'));
        this.goToIndex(selectedIndex - 1);
    },

    goToIndex: function(index){
        var selected = this.getEl().select('.selected').first();
        var selectedIndex = parseInt(selected.getAttribute('index'));

        if(index === selectedIndex)
            return;
        if(this.noSkipForward && index > selectedIndex && index !== selectedIndex + 1)
            return; // We're only allowing users to move forward one index at a time
        if(this.noSkipBack && index < selectedIndex && index !== selectedIndex - 1)
            return; // We're only allowing users to move back one index at a time

        var elem = this.getEl().select('[index=' + index + ']');
        if(!elem)
            return;

        if(this.fireEvent('beforenavigation', this, selectedIndex, index) !== false)
        {
            selected.removeClass('selected');
            elem.addClass('selected');
            if(selectedIndex - 1 === index)
                this.fireEvent('previous', this, selectedIndex, index);
            else if(selectedIndex + 1 === index)
                this.fireEvent('next', this, selectedIndex, index);

            this.fireEvent('toindex', this, selectedIndex, index); // Fire the toindex event no matter which direction we've traveled. Most card layouts will hook to this
        }
    }
});