Ext.ns('Ext.ux.grid');

Ext.ux.grid.FilterableCheckboxSelectionModel = Ext.extend(Ext.grid.CheckboxSelectionModel, {
    // private
    onRefresh : function(){
        var ds = this.grid.store,
            s = this.getSelections(),
            i = 0,
            len = s.length,
            index;

        this.silent = true;
        this.clearSelections(true);
        for(; i < len; i++){
            r = s[i];
            if((index = ds.indexOfId(r.id)) != -1){
                this.selectRow(index, true);
            }
        }
        if(s.length != this.selections.getCount()){
            this.fireEvent('selectionchange', this);
        }
        this.clearSelections(true);
        this.selections.addAll(s);
        this.silent = false;
    }
});