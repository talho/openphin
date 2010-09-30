Ext.ns("Talho");

// We're going to create a singleton manager here that is an observable
(function(){
    dominoes.property('ext_extensions', '/javascripts/ext_extensions');
    dominoes.rule('RowActions', '(( $css(/stylesheets/redesign/Ext.ux.grid.RowActions.css) )) $(ext_extensions)/Ext.ux.grid.RowActions.js');
    dominoes.rule('TreeGrid', '(( $css(/stylesheets/TreeGrid/css/TreeGrid.css) $css(/stylesheets/TreeGrid/css/TreeGridLevels.css) )) $(ext_extensions)/TreeGrid/TreeGrid.js');
    dominoes.rule('AudiencePanel', '$(ext_extensions)/DataTip.js RowActions TreeGrid $(ext_extensions)/DoNotCollapseActive.js > $(ext_extensions)/AudiencePanel.js');
    dominoes.rule('AlertDetail', '$(ext_extensions)/AudienceDisplayPanel.js $(ext_extensions)/CenterLayout.js /javascripts/han/AlertDetail.js');

    var regList = {
        'Talho.SendAlert': {js:'$(ext_extensions)/CenterLayout.js $(ext_extensions)/BreadCrumb.js AlertDetail AudiencePanel > /javascripts/han/SendAlert.js'},
        'Talho.AlertDetail': {js:'AlertDetail'},
        'Talho.AdvancedSearch': {js:'AjaxPanel > /javascripts/searches/AdvancedSearch.js'},
        'Talho.ManageGroups': {js:'$(ext_extensions)/AudienceDisplayPanel.js RowActions AudiencePanel > /javascripts/groups/ManageGroups.js'},
        'Talho.Tutorials': {js: 'AjaxPanel > /javascripts/dashboard/tutorials.js'},
        'Talho.Alerts': {js: "AjaxPanel > /javascripts/han/alerts.js"}
    };

    // These are rules that are intended to be loaded on their own through the loadOtherLibrary method call
    dominoes.rule('AjaxPanel', '$(ext_extensions)/MaxWidthHBox.js $(ext_extensions)/HtmlFormPanel.js $(ext_extensions)/AjaxPanel.js $(ext_extensions)/CenteredAjaxPanel.js');
    dominoes.rule('Favorites', '$(ext_extensions)/DragDropTabs.js $(ext_extensions)/RailsJsonReader.js /javascripts/dashboard/favorites.js');
    dominoes.rule('PhinLayout', '/dashboard/menu.js /javascripts/dashboard/MenuBuilder.js');
    dominoes.rule('Dashboard', '/javascripts/utility.js /javascripts/dashboard/article3panel.js');

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