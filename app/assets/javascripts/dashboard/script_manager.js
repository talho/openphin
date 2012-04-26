Ext.ns("Talho");

// We're going to create a singleton manager here that is an observable
(function(){
    dominoes.property('ext_extensions', '/assets/ext_extensions');
    dominoes.property('js', '/assets');
    dominoes.property('css', '/assets');
    dominoes.property('cms', '/assets/dashboard/cms');
    dominoes.property('admin', '$(js)/admin');
    
    dominoes.rule('RowActions', '(( $css($(css)/redesign/Ext.ux.grid.RowActions.css) )) $(ext_extensions)/Ext.ux.grid.RowActions.js');
    dominoes.rule('TreeGrid', '(( $css($(css)/TreeGrid/css/TreeGrid.css) $css($(css)/TreeGrid/css/TreeGridLevels.css) )) $(ext_extensions)/TreeGrid/TreeGrid.js > $(ext_extensions)/TreeGrid/Overrides.js');
    dominoes.rule('JurisdictionsTree', 'TreeGrid $(ext_extensions)/xActionColumn.js $(ext_extensions)/FilterableCheckboxSelectionModel.js ( $(js)/audience/BaseSelectionGrid.js > $(js)/audience/JurisdictionsTree.js )');
    dominoes.rule('RoleSelectionGrid', '$(ext_extensions)/FilterableCheckboxSelectionModel.js ( $(js)/audience/BaseSelectionGrid.js > $(js)/audience/RoleSelectionGrid.js )');
    dominoes.rule('GroupSelectionGrid', '$(ext_extensions)/FilterableCheckboxSelectionModel.js ( $(js)/audience/BaseSelectionGrid.js > $(js)/audience/GroupSelectionGrid.js )');
    dominoes.rule('UserSelectionGrid', '$(ext_extensions)/DataTip.js $(ext_extensions)/xActionColumn.js $(js)/audience/UserSelectionGrid.js');
    dominoes.rule('AudiencePanel', '$(ext_extensions)/xActionColumn.js $(ext_extensions)/DoNotCollapseActive.js JurisdictionsTree RoleSelectionGrid GroupSelectionGrid UserSelectionGrid $(js)/audience/AudiencePanel.js');
    dominoes.rule('AudienceDisplayPanel', '$(js)/audience/AudienceDisplayPanel.js $(ext_extensions)/PagingStore.js');
    dominoes.rule('NewInvitation', '(( $css($(css)/ux/fileuploadfield/fileuploadfield.css) $css($(css)/ux/RowEditor.css) )) $(ext_extensions)/FileUploadField.js $(ext_extensions)/RowEditor.js $(js)/invitations/NewInvitationBase.js');
    dominoes.rule('ProfileBase', '(( $css($(css)/redesign/profile.css) )) $(js)/profile/ProfileBase.js');
    dominoes.rule('BatchUsers', '(( $css($(css)/ux/fileuploadfield/fileuploadfield.css) $css($(css)/ux/RowEditor.css) )) $(ext_extensions)/FileUploadField.js $(ext_extensions)/RowEditor.js $(js)/ext/src/widgets/grid/EditorGrid.js');
    dominoes.rule('EditUsers', '(( $css($(css)/ux/RowEditor.css) )) $(ext_extensions)/xActionColumn.js $(ext_extensions)/RowEditor.js $(js)/ext/src/widgets/grid/EditorGrid.js');
    dominoes.rule('GMap', '$(ext_extensions)/GMapPanel.js $(ext_extensions)/GMapInfoWindow.js');
    dominoes.rule('Portlets', '$(ext_extensions)/Portal.js > ( $(cms)/portlet.js > ( $(cms)/portlets/html.js > $(cms)/portlets/phin.js ) $(cms)/portlets/rss.js $(cms)/portlets/documents.js $(cms)/portlets/forum.js $(cms)/portlets/alerts.js ( $(ext_extensions)/jsonp.js $(cms)/portlets/twitter.js ) )')

    var regList = {
      'Talho.FindPeople': {js:'$(js)/search/FindPeople.js'},
      'Talho.ManageGroups': {js:'AudienceDisplayPanel $(ext_extensions)/xActionColumn.js AudiencePanel > $(js)/groups/view/list.js $(js)/groups/view/create_edit.js $(js)/groups/view/detail.js $(js)/groups/ManageGroups.js'},
      'Talho.Tutorials': {js: 'AjaxPanel > $(js)/dashboard/tutorials.js'},
      'Talho.Forums': {js: "AudiencePanel $(ext_extensions)/SubmitFalse.js $(ext_extensions)/xActionColumn.js $(js)/forums/forums.js"},
      'Talho.Topic': {js: "$(js)/forums/topic.js"},
      'Talho.EditProfile': {js:'ProfileBase $(js)/profile/DevicesControl.js $(js)/profile/RolesControl.js $(js)/profile/OrganizationsControl.js > $(js)/profile/EditProfile.js'},
      'Talho.ShowProfile': {js:'$(js)/profile/ShowProfile.js'},
      'Talho.EditPassword': {js:'ProfileBase > $(js)/profile/EditPassword.js'},
      'Talho.EditDevices': {js:'ProfileBase $(js)/profile/DevicesControl.js > $(js)/profile/EditDevices.js'},
      'Talho.ManageRoles': {js:'ProfileBase $(js)/profile/RolesControl.js > $(js)/profile/ManageRoles.js'},
      'Talho.ManageOrganizations': {js:'ProfileBase $(js)/profile/OrganizationsControl.js > $(js)/profile/ManageOrganizations.js'},
      'Talho.Documents': {js: '$(js)/lib/fileuploader.js $css($(css)/fileuploader.css) TreeGrid $(ext_extensions)/xActionColumn.js $(ext_extensions)/SubmitFalse.js $(ext_extensions)/ImageDisplayField.js AudiencePanel $(js)/documents/AddEditFolderWindow.js $(js)/documents/DocumentViews.js $(js)/documents/Documents.js'},
      'Talho.DocumentSearch': {js: '$(ext_extensions)/ImageDisplayField.js $(js)/documents/DocumentViews.js $(js)/documents/DocumentSearch.js'},
      'Talho.NewInvitation': {js:'NewInvitation $(js)/ext/src/widgets/grid/EditorGrid.js > $(js)/invitations/NewInvitation.js'},
      'Talho.Invitations': {js:'$(js)/invitations/Invitations.js'},
      'Talho.AddUser': {js:'ProfileBase $(js)/profile/DevicesControl.js $(js)/profile/RolesControl.js $(js)/profile/OrganizationsControl.js > $(admin)/AddUser.js'},
      'Talho.BatchUsers': {js:'BatchUsers ProfileBase > $(admin)/BatchUsers.js'},
      'Talho.EditUsers': {js:'EditUsers ProfileBase $(js)/profile/RolesControl.js > $(admin)/EditUsers.js'},
      'Talho.PendingRoleRequests': {js: "AjaxPanel > $(admin)/PendingRoleRequests.js"},
      'Talho.AuditLog': {js: "AjaxPanel > $(admin)/AuditLog.js"},
      'Talho.ReportView': {js:'$(js)/reports/ReportView.js'},
      'Talho.Reports': {js:'$(js)/reports/Reports.js'},
      'Talho.HelpWindow': {js:'$(js)/dashboard/help_window.js'},
      'Talho.Dashboard.CMS.Admin': {js: '$(ext_extensions)/xActionColumn.js $(ext_extensions)/PhinHtmlEditor.js Portlets > $(cms)/views/admin_toolbar.js $(cms)/views/view_portal.js $(cms)/views/admin_portal.js $(cms)/views/new_dashboard_window.js $(cms)/views/open_dashboard_window.js AudiencePanel $(cms)/views/manage_permissions_window.js $(cms)/admin_controller.js'},
      'Talho.Admin.Organizations': {js: '$(ext_extensions)/xActionColumn.js AudiencePanel $(ext_extensions)/BootstrapBreadcrumbContainer.js $(admin)/organizations/Controller.js $(admin)/organizations/view/Layout.js $(admin)/organizations/view/Index.js $(admin)/organizations/view/Show.js $(admin)/organizations/view/New.js '},
      'Talho.Admin.OrganizationMembershipRequests': {js: '$(admin)/organization_membership_requests/Controller.js $(admin)/organization_membership_requests/view/Index.js'}
    };

    // These are rules that are intended to be loaded on their own through the loadOtherLibrary method call
    dominoes.rule('AjaxPanel', '$(ext_extensions)/MaxWidthHBox.js $(ext_extensions)/HtmlFormPanel.js $(ext_extensions)/AjaxPanel.js $(ext_extensions)/CenteredAjaxPanel.js');
    dominoes.rule('Favorites', '$(ext_extensions)/DragDropTabs.js $(ext_extensions)/RailsJsonReader.js $(js)/dashboard/favorites.js');
    dominoes.rule('PhinLayout', '$(js)/utility.js $(ext_extensions)/ToolBarNav.js $(ext_extensions)/NavigableTabPanel.js /dashboard/menu.js $(js)/dashboard/menu_builder.js');
    dominoes.rule('Dashboard', 'Portlets > $(cms)/views/view_portal.js $(cms)/view_controller.js');
    dominoes.rule('ManageFavorites', 'RowActions $(js)/dashboard/manage_favorites_window.js');

    var mgr = function(config){};
    Ext.extend(mgr, Ext.util.Observable, {
        /**
         * Registers an initializer with the registration list. Allows us to determine if a script has been loaded or not
         * @param {String}      name            The string representation of the class. Should be preregistered
         * @param {Object}      classVariable   The class variable, in case we want to remove it later
         * @param {Function}    initializer     The initializer function. Singleton function that should return a panel.
         */
        reg: function(name, classVariable, initializer){
            if(!regList[name]){// Here we want to register allow people to register a constructor if there is one or isn't
                regList[name] = {};
            }
            Ext.apply(regList[name], {
                initializer: initializer,
                classVariable: classVariable
            });
        },

        addInitializer:function(name, config){
            if(regList[name]){
                throw("Initializer " + name +" has already been configured. Please use a unique name");
            }
            regList[name] = config;
        },

        exists: function(name){
            return !Ext.isEmpty(regList[name]);
        },

        isLoaded: function(name){
            return !Ext.isEmpty(regList[name]) && Ext.isFunction(regList[name].initializer);
        },

        getInitializer: function(name, callback){
            if(!this.isLoaded(name)){
                this.load(name, callback);
            }
            else{
                callback(regList[name].initializer);
            }
        },

        load: function(name, callback){
            if(!Ext.isEmpty(regList[name])){
              dominoes([regList[name].js], function(name, callback){
                  callback(regList[name].initializer);
              }.createDelegate(this, [name, callback]));
            }
        },

        loadOtherLibrary: function(name, callback){
            try
            {
                dominoes(name, function(name, callback){callback(name);}.createDelegate(this, [name, callback]));
            }
            catch(e){
                callback(name); // maybe send an error message here at some point
            }
        }

        /*,

        unload: function(name){
            var cls = regList[name].classVariable;

            delete regList[name].classVariable;
            delete regList[name].initializer;
            delete cls;
        }  */
    });

    Talho.ScriptManager = new mgr({});
})();
