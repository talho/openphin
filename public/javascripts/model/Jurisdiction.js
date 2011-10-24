
Ext.define('Talho.model.Jurisdiction', {
  extend: 'Ext.data.Model',
  fields: [
    'name', 
    'id', 
    'leaf', 
    'children', 
    'depth',
    {name: 'icon', defaultValue: Ext.BLANK_IMAGE_URL}, 
    {name: 'expanded', convert: function(v, rec){
      if(rec.get('expandProcessed')){
        return v;
      }
      rec.set('expandProcessed', true);
      if(rec.get('depth') < 2){ 
        return true;
      }
      else{
        return false;
      }
    }},
    {name: 'expandProcessed', type: 'boolean', defaultValue: false}
  ]
});
