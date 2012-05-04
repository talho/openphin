Ext.ns('Talho');

Talho.ShowProfile = Ext.extend(Ext.util.Observable, {
  constructor: function(config){
    Ext.apply(this, config);
    Talho.ShowProfile.superclass.constructor.call(this, config);

    var url = '/users/' + this.user_id + '/profile.json';
    Ext.Ajax.request({
      url: url,
      scope: this,
      success: function(response, options) {
        this.getPanel().url = url;
        var record = Ext.decode(response.responseText);
        this.userdata = record.userdata;
        this.renderProfile();
      }
    });

    this.inner_panel  = new Ext.Panel({
      layout: 'column',
      cls: 'inner-panel',
      layoutConfig: {defaultMargins:'5'}
    });

    this.primary_panel = new Ext.Panel({
      layout: 'column',
      autoScroll: true,
      padding: 5,
      itemId: config.id,
      cls: 'primary-panel t_boot',
      closable: true,
      title: this.title,
      items: [{xtype:'container',html:'&nbsp;',columnWidth:0.5},this.inner_panel,{xtype:'container',html:'&nbsp;',columnWidth:0.5}]
    });  

    this.getPanel = function(){
        return this.primary_panel;
    };
  },

    buildLeftColumn: function(){
      var singleDataBox = Ext.extend(Ext.BoxComponent, {
        tpl: '<tpl if="dataPoint">' +
              '<fieldset style="margin-bottom: 20px; border: none; border-top: 1px solid #EEEEEE;">' +
                '<legend style="color: #999999;padding-left:0px;">{label}</legend>' +
                '<span style="font-size: 130%;"> {dataPoint} </span>' +
             '</fieldset></tpl>'
      });

      var assembledItems = [{
        xtype: 'box',
        data: this.userdata,
        tpl: '<h2> {display_name} </h2>'}];

      if (this.userdata.can_edit){
        assembledItems.push([
          new Ext.Container({
            items:[{
              xtype: "box",
              data: this.userdata,
              tpl: '<tpl if="(first_name +\' \' + last_name) != display_name">' +
                   '<small>({first_name} {last_name})</small></tpl>'
            },
            new Ext.Button({ scope: this, width: 100, handler: this.openEditUserTab,text: "Edit This Account" })]
          })
        ]);
      } else {
        assembledItems.push({
          xtype: "box",
          data: this.userdata,
          tpl: '<tpl if="(first_name +\' \' + last_name) != display_name">' +
               '<small>({first_name} {last_name})</small></tpl>'});
      }

      if (this.userdata.privateProfile){
        assembledItems.push({xtype:'box',tpl:'<span>This profile information is private.</span>'});
      } else {
        assembledItems.push([{
          xtype: 'box',
          data: this.userdata,
          tpl: '<fieldset style="margin-bottom: 20px; border: none; border-top: 1px solid #EEEEEE;">' +
               '<legend style="color: #999999;padding-left:0px;">Roles</legend>' +
               '<tpl for="role_memberships"><p style="font-size: 130%;">{role} in {jurisdiction}</p></tpl></fieldset>'
          },new singleDataBox({data:{ label: "Employer",        dataPoint: this.userdata.employer} }),
          new singleDataBox({data:{ label: "Occupation",      dataPoint: this.userdata.occupation} }),
          new singleDataBox({data:{ label: "Job Description", dataPoint: this.userdata.job_description} }),
          new singleDataBox({data:{ label: "Bio",             dataPoint: this.userdata.bio} }),
          new singleDataBox({data:{ label: "Credentials",     dataPoint: this.userdata.credentials} }),
          new singleDataBox({data:{ label: "Experience",      dataPoint: this.userdata.experience} })
        ]);
      }
      return assembledItems;
    },

    buildRightColumn: function(){
      var deviceMap = {'email': 'E-Mail', 'office_phone': 'Office Phone', 'home_phone': 'Home Phone', 'mobile_phone': 'Mobile Phone', 'fax': 'Fax' };
      for (var i=0; i < this.userdata.contacts.length; i++ ) { // create nicer labels for display
        this.userdata.contacts[i]['label'] = deviceMap[this.userdata.contacts[i]['type']]; 
      }
      return [{xtype: 'box', data: this.userdata, tpl: '<ul class="media-grid"><li><a style="margin:0px;"><img class="thumbnail" src="{photo}" /></a></li></ul>', height: 200},
      {xtype: 'box', data: this.userdata,
        tpl: '<fieldset style="margin-bottom: 20px; margin-top: 30px; border:none; border-top: 1px solid #EEEEEE;">'+
             '<legend style="color: #999999;padding-left:0px">Contact Information</legend><tpl for="contacts">'+
             '<tpl if="address"><div style="margin-bottom: 10px;"><span style="color: #555555">{label}:</span>'+
             '<p style="font-size: 130%; ">{address}</p></div></tpl></tpl></fieldset>'},
      {xtype: 'box', data: this.userdata,
        tpl: '<tpl if="!Ext.isEmpty(organizations)">' +
             '<fieldset style="margin-bottom: 20px; border: none; border-top: 1px solid #EEEEEE;">' +
             '<legend style="color: #999999;padding-left:0px;">Organizations</legend><tpl for="organizations">' +
             '<p style="font-size: 130%;">{name}</p></tpl></fieldset></tpl>'
      }];
    },

    renderProfile: function(){
      var leftColumn = new Ext.Panel({
        width: 500,
        padding: 5,
        border: false,
        items: this.buildLeftColumn()
      });
      var rightColumn = new Ext.Panel({
        width: 250,
        padding: 5,
        border: false,
        items: this.buildRightColumn()
      });
      this.inner_panel.add(
        leftColumn,
        rightColumn
      );
      this.inner_panel.doLayout();
      this.primary_panel.doLayout();
    },

    openEditUserTab: function(){
      Application.fireEvent('opentab', {
        title: 'Edit Account: ' + this.userdata.first_name + ' ' + this.userdata.last_name,
        url: '/users/' + this.userdata.user_id + '/profile',
        user_id: this.userdata.user_id,
        id: 'edit_user_for_' + this.userdata.user_id, initializer: 'Talho.EditProfile'
      });
    }
});

/**
 * Initializer for the ShowProfile object. Returns a panel
 */
Talho.ShowProfile.initialize = function(config){
    var show_profile_panel = new Talho.ShowProfile(config);
    return show_profile_panel.getPanel();
};

Talho.ScriptManager.reg('Talho.ShowProfile', Talho.ShowProfile, Talho.ShowProfile.initialize);
