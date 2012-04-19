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
    },
    
    // private
    handleMouseDown : function(g, rowIndex, e){
        if(e.button !== 0 || this.isLocked()){
            return;
        }
        var view = this.grid.getView();
        if(e.shiftKey && !this.singleSelect && this.last !== false){
            var last = this.last;
            this.selectRange(last, rowIndex, e.ctrlKey);
            this.last = last; // reset the last
            view.focusRow(rowIndex);
        }else{
            var isSelected = this.isSelected(rowIndex);
            if((e.ctrlKey || this.simple) && isSelected){
                this.deselectRow(rowIndex);
            }else if(!isSelected || this.getCount() > 1){
                this.selectRow(rowIndex, this.simple || e.ctrlKey || e.shiftKey);
                view.focusRow(rowIndex);
            }
        }
    }

});