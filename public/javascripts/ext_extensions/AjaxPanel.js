
/**
 * @constructor
 * @param {object}    config        the Panel configuration
 * @config {string}   url           the url of the html document that will be loaded into this panel
 */
Ext.AjaxPanel = Ext.extend(Ext.Panel, 
/**
 * @lends Ext.AjaxPanel.prototype
 */
{
  initComponent: function()
  {
    Ext.AjaxPanel.superclass.initComponent.call(this);
    
    this.addEvents( 
      /**
       * @event ajaxloadcomplete
       * Fires after the ajax document has loaded
       * @param {Ext.Component} this
       */
      'ajaxloadcomplete'
    );                    

    // do any special initialization events here
    this.url = this.url || ''
  },
  
  /**
   * Call the parent render, find the updater, set it up to call
   */
  onRender: function(ct, position)
  {
    Ext.AjaxPanel.superclass.onRender.call(this, ct, position);
    
    this.loadAJAX()
  },
  
  loadAJAX: function()
  {
    var updater = this.getUpdater();
    
    if(this.renderer != null)
    {
      updater.setRenderer(this.renderer);
    }
    
    if(this.url !== '')
    {
      updater.update({
        url: this.url,
        method: 'GET',
        callback: this.handleAJAXLoad,
        scope: this
      });
    }
  },
  
  /**
   * This is called after the updater completes. It should parse and hookup links
   * and forms and should call the specific callback
   */
  handleAJAXLoad: function(el, success, response, options)
  {
    this.findParentByType('panel').doLayout();
    var els = el.select('a');
    els.each(function(a){
      var href = a.dom.href;
      a.dom.href = '#';
      a.addListener('click', function(evt, target, href)
      {        
        this.url = href;
        this.loadAJAX();
      }, this, href)
    }, this);
    
    var forms = el.select('form');
    forms.each(function(form)
    {
      
    }, this);
    
    this.fireEvent('ajaxloadcomplete', this);
  }
});

Ext.reg('ajaxpanel', Ext.AjaxPanel);