Ext.ns("Talho");

// We're going to create a singleton manager here that is an observable
(function(){
    dominoes.property('ext_extensions', '/javascripts/ext_extensions');
    dominoes.rule('RowActions', '(( $css(/stylesheets/redesign/Ext.ux.grid.RowActions.css) )) $(ext_extensions)/Ext.ux.grid.RowActions.js');
    dominoes.rule('TreeGrid', '(( $css(/stylesheets/TreeGrid/css/TreeGrid.css) $css(/stylesheets/TreeGrid/css/TreeGridLevels.css) )) $(ext_extensions)/TreeGrid/TreeGrid.js > $(ext_extensions)/TreeGrid/Overrides.js');
    dominoes.rule('JurisdictionsTree', 'TreeGrid $(ext_extensions)/xActionColumn.js $(ext_extensions)/FilterableCheckboxSelectionModel.js ( /javascripts/audience/BaseSelectionGrid.js > /javascripts/audience/JurisdictionsTree.js )');
    dominoes.rule('RoleSelectionGrid', '$(ext_extensions)/FilterableCheckboxSelectionModel.js ( /javascripts/audience/BaseSelectionGrid.js > /javascripts/audience/RoleSelectionGrid.js )');
    dominoes.rule('GroupSelectionGrid', '$(ext_extensions)/FilterableCheckboxSelectionModel.js ( /javascripts/audience/BaseSelectionGrid.js > /javascripts/audience/GroupSelectionGrid.js )');
    dominoes.rule('UserSelectionGrid', '$(ext_extensions)/DataTip.js $(ext_extensions)/xActionColumn.js /javascripts/audience/UserSelectionGrid.js');
    dominoes.rule('AudiencePanel', '$(ext_extensions)/xActionColumn.js $(ext_extensions)/DoNotCollapseActive.js JurisdictionsTree RoleSelectionGrid GroupSelectionGrid UserSelectionGrid /javascripts/audience/AudiencePanel.js');
    dominoes.rule('AudienceDisplayPanel', '/javascripts/audience/AudienceDisplayPanel.js $(ext_extensions)/PagingStore.js')
    dominoes.rule('AlertDetail', 'AudienceDisplayPanel $(ext_extensions)/CenterLayout.js /javascripts/han/AlertDetail.js');
    dominoes.rule('NewInvitation', '(( $css(/stylesheets/ux/fileuploadfield/fileuploadfield.css) $css(/stylesheets/ux/RowEditor.css) )) $(ext_extensions)/FileUploadField.js $(ext_extensions)/RowEditor.js /javascripts/invitations/NewInvitationBase.js');
    dominoes.rule('ProfileBase', '(( $css(/stylesheets/redesign/profile.css) )) /javascripts/profile/ProfileBase.js');
    dominoes.rule('BatchUsers', '(( $css(/stylesheets/ux/fileuploadfield/fileuploadfield.css) $css(/stylesheets/ux/RowEditor.css) )) $(ext_extensions)/FileUploadField.js $(ext_extensions)/RowEditor.js /javascripts/ext/src/widgets/grid/EditorGrid.js');
    dominoes.rule('EditUsers', '(( $css(/stylesheets/ux/RowEditor.css) )) $(ext_extensions)/xActionColumn.js $(ext_extensions)/RowEditor.js /javascripts/ext/src/widgets/grid/EditorGrid.js');
    dominoes.rule('GMap', '$(ext_extensions)/GMapPanel.js $(ext_extensions)/GMapInfoWindow.js');

    var regList = {
        'Talho.SendAlert': {js:'$(ext_extensions)/CenterLayout.js $(ext_extensions)/BreadCrumb.js AlertDetail AudiencePanel > /javascripts/han/SendAlert.js'},
        'Talho.AlertDetail': {js:'AlertDetail'},

        'Talho.FindPeople': {js:'/javascripts/search/FindPeople.js'},
        'Talho.ManageGroups': {js:'AudienceDisplayPanel $(ext_extensions)/xActionColumn.js AudiencePanel > /javascripts/groups/ManageGroups.js'},
        'Talho.Tutorials': {js: 'AjaxPanel > /javascripts/dashboard/tutorials.js'},
        'Talho.Alerts': {js: "AjaxPanel > /javascripts/han/alerts.js"},
        'Talho.Forums': {js: "AudiencePanel $(ext_extensions)/SubmitFalse.js $(ext_extensions)/xActionColumn.js /javascripts/forums/forums.js"},
        'Talho.Topic': {js: "/javascripts/forums/topic.js"},
        'Talho.EditProfile': {js:'ProfileBase /javascripts/profile/DevicesControl.js /javascripts/profile/RolesControl.js /javascripts/profile/OrganizationsControl.js > /javascripts/profile/EditProfile.js'},
        'Talho.ShowProfile': {js:'/javascripts/profile/ShowProfile.js'},
        'Talho.EditPassword': {js:'ProfileBase > /javascripts/profile/EditPassword.js'},
        'Talho.EditDevices': {js:'ProfileBase /javascripts/profile/DevicesControl.js > /javascripts/profile/EditDevices.js'},
        'Talho.ManageRoles': {js:'ProfileBase /javascripts/profile/RolesControl.js > /javascripts/profile/ManageRoles.js'},
        'Talho.ManageOrganizations': {js:'ProfileBase /javascripts/profile/OrganizationsControl.js > /javascripts/profile/ManageOrganizations.js'},
        'Talho.Documents': {js: 'TreeGrid $(ext_extensions)/xActionColumn.js $(ext_extensions)/SubmitFalse.js $(ext_extensions)/ImageDisplayField.js AudiencePanel /javascripts/documents/AddEditFolderWindow.js /javascripts/documents/DocumentViews.js /javascripts/documents/Documents.js'},
        'Talho.DocumentSearch': {js: '$(ext_extensions)/ImageDisplayField.js /javascripts/documents/DocumentViews.js /javascripts/documents/DocumentSearch.js'},
        'Talho.NewInvitation': {js:'NewInvitation /javascripts/ext/src/widgets/grid/EditorGrid.js > /javascripts/invitations/NewInvitation.js'},
        'Talho.Invitations': {js:'/javascripts/invitations/Invitations.js'},
        'Talho.AddUser': {js:'ProfileBase /javascripts/profile/DevicesControl.js /javascripts/profile/RolesControl.js /javascripts/profile/OrganizationsControl.js > /javascripts/admin/AddUser.js'},
        'Talho.BatchUsers': {js:'BatchUsers ProfileBase > /javascripts/admin/BatchUsers.js'},
        'Talho.EditUsers': {js:'EditUsers ProfileBase /javascripts/profile/RolesControl.js > /javascripts/admin/EditUsers.js'},
        'Talho.PendingRoleRequests': {js: "AjaxPanel > /javascripts/admin/PendingRoleRequests.js"},
        'Talho.AuditLog': {js: "AjaxPanel > /javascripts/admin/AuditLog.js"},
        'Talho.HelpWindow': {js:'/javascripts/dashboard/HelpWindow.js'},
    };

    // These are rules that are intended to be loaded on their own through the loadOtherLibrary method call
    dominoes.rule('AjaxPanel', '$(ext_extensions)/MaxWidthHBox.js $(ext_extensions)/HtmlFormPanel.js $(ext_extensions)/AjaxPanel.js $(ext_extensions)/CenteredAjaxPanel.js');
    dominoes.rule('Favorites', '$(ext_extensions)/DragDropTabs.js $(ext_extensions)/RailsJsonReader.js /javascripts/dashboard/favorites.js');
    dominoes.rule('PhinLayout', '/javascripts/utility.js $(ext_extensions)/ToolBarNav.js $(ext_extensions)/NavigableTabPanel.js /dashboard/menu.js /javascripts/dashboard/MenuBuilder.js');
    dominoes.rule('Dashboard', '$(ext_extensions)/TabPanelNav.js /javascripts/utility.js /javascripts/dashboard/article3panel.js');
    dominoes.rule('ManageFavorites', 'RowActions /javascripts/dashboard/ManageFavoritesWindow.js');

    var mgr = function(config){};
    Ext.extend(mgr, Ext.util.Observable, {
        /**
         * Registers an initializer with the registration list. Allows us to determine if a script has been loaded or not
         * @param {String}      name            The string representation of the class. Should be preregistered
         * @param {Object}      classVariable   The class variable, in case we want to remove it later
         * @param {Function}    initializer     The initializer function. Singleton function that should return a panel.
         */
        reg: function(name, classVariable, initializer){
            if(!regList[name])// Here we want to register allow people to register a constructor if there is one or isn't
                regList[name] = {};
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
            if(!Ext.isEmpty(regList[name]))
                dominoes([regList[name].js], function(name, callback){
                callback(regList[name].initializer);
            }.createDelegate(this, [name, callback]));
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
