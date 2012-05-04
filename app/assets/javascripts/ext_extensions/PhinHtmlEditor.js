Ext.ns('Talho.ux');

Talho.ux.PhinHtmlEditor = Ext.extend(Ext.form.HtmlEditor, {
  createLinkText: 
  'Specify a PHIN tab config to launch. If you do not know what \n' +
  'this is, you should consider using a basic HTML portlet. Look \n' +
  'in menu.js for examples.',
  defaultLinkValue: '{title: "", initializer: "", id: ""}',
  
  // private
  createLink: function() {
    var json = prompt(this.createLinkText, this.defaultLinkValue),
      decoded_object = null;
    if (decoded_object = Ext.decode(json, true)) {
      this.relayCmd('insertHTML', "<a tab='" + Ext.encode(decoded_object) + "' href='#'>" + this.getDoc().getSelection() || "new tab link" + "</a>");
    }
  }  
});
