
Ext.define('Talho.store.Jurisdictions', {
  extend: 'Ext.data.TreeStore',
  model: 'Talho.model.Jurisdiction',
  autoLoad: true,
  storeId: 'jurisdictionTree',
  proxy: {
    type: 'ajax',
    url: '/audiences/jurisdictions.json'
  },
  root:{
    expanded: true,
    name: ''
  }
})
