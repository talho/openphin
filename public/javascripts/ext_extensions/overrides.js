// Override default window configuration to constrain header
Ext.override(Ext.Window, {
  constrain: true
});

// Override Ext.Container to add the findComponent function
Ext.override(Ext.Container, {
  /**
   * Perform a breadth first search using getComponent on all children until a component is found or there are no more children to search
   * @param  {String} id     The id or itemId of the component to search for
   * @return {Ext.Component} The first matching component
   */
  findComponent: function(id){
    var found = this.getComponent(id);
    var current_level = this.items.getRange();
    var next_level = new Ext.util.MixedCollection();
    while(found === undefined && current_level.length > 0){
      for(var i = 0; i < current_level.length; i++){
        if(current_level[i].isXType && current_level[i].isXType('container')){
          var found = current_level[i].getComponent(id);
          if(found !== undefined)
            break;
          else
            next_level.addAll(current_level[i].items.getRange());
        }
      }
      current_level = next_level.getRange();
      next_level.clear();
    }
    return found;
  }
});


Ext.override(Ext.grid.RowSelectionModel, {
  selectRow : function(index, keepExisting, preventViewNotify){
      if(!this.grid || this.isLocked() || (index < 0 || index >= this.grid.store.getCount()) || (keepExisting && this.isSelected(index))){
          return;
      }
      var r = this.grid.store.getAt(index);
      if(r && this.fireEvent('beforerowselect', this, index, keepExisting, r) !== false){
          if(!keepExisting || this.singleSelect){
              this.clearSelections();
          }
          this.selections.add(r);
          this.last = this.lastActive = index;
          if(!preventViewNotify){
              if(this.grid.getView().mainBody){ this.grid.getView().onRowSelect(index);}
          }
          if(!this.silent){
              this.fireEvent('rowselect', this, index, r);
              this.fireEvent('selectionchange', this);
          }
      }
  }
});

// Override HTML Editor create link so we are able to force users to open links in new browser tabs/windows
Ext.override(Ext.form.HtmlEditor, {
  /**
   * If true, when a link is created, set the target attribute to '_blank' forcing links to open in new windows. Defaults to false
   */
  linksInNewWindow: false,
  
  // private
  createLink: function() {
    var url = prompt(this.createLinkText, this.defaultLinkValue);
    if (url && url != 'http:/' + '/') {
      if(this.linksInNewWindow){
        this.relayCmd('insertHTML', "<a href='" + url + "' target='_blank'>" + this.getDoc().getSelection() + "</a>");
      }
      else{
        this.relayCmd('createlink', url);
      }
    }
  }
});

String.prototype.summarizeHtml = function(maxChars) {
  // token matches a word, tag, or special character
  var input = this,
    token = /\w+|[^\w<]|<(\/)?(\w+)[^>]*(\/)?>|</g,
    selfClosingTag = /^(?:[hb]r|img)$/i,
    output = "",
    charCount = 0,
    openTags = [],
    match;

  // Set the default for the max number of characters
  // (only counts characters outside of HTML tags)
  maxChars = maxChars || 250;

  while ((charCount < maxChars) && (match = token.exec(input))) {
    // If this is an HTML tag
    if (match[2]) {
      output += match[0];
      // If this is not a self-closing tag
      if (!(match[3] || selfClosingTag.test(match[2]))) {
        // If this is a closing tag
        if (match[1]) openTags.pop();
        else openTags.push(match[2]);
      }
    } else {
      charCount += match[0].length;
      if (charCount <= maxChars) output += match[0];
    }
  }

  // Close any tags which were left open
  var i = openTags.length;
  while (i--) output += "</" + openTags[i] + ">";
  
  return output;
};