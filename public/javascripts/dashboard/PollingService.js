

(function(){
    var polling_service = Ext.extend(Ext.util.Observable, {
        constructor: function(config){
            this._polling_provider = new Ext.direct.PollingProvider({
                interval: 15000,
                url: '/polling.json'
            });

            this._poll_targets = [];
        },

        /**
         * Add a polling point to the polling service. Provide a name, parameters, callback and optional scope.
         * @param {String|Object}   service_name    either the string name of the poll (params will be sent as the value of this name), or an object definition for the poll.
         *  @service_name {String}   service_name    string name of the poll
         *  @service_name {Object}   params          @see params
         *  @service_name {Function} callback|cb     @see callback
         *  @service_name {Object}   scope           @see scope
         * @param {Object}          [params]        the parameters sent to the server to identify which sort of information we are polling for
         * @params {String}          [id]            used to identify the config used. If this is not provided, the polling service will attempt to match the params straight-up
         * @param {Function}        [callback]      the callback for each successful server poll. function(result, service_name, params)
         * @param {Object}          [scope]         the scope that the callback will be executed under
         */
        poll: function(service_name, params, callback, scope){
            var config = service_name;
            if(Ext.isString(service_name)){
                config = {
                    service_name: service_name,
                    params: params,
                    cb: callback,
                    scope: scope
                }
            }

            this._poll_targets.push(config);
            this._polling_provider.connect();
        },

        /**
         * Stop a poll from running based on the service name and the params
         * @param {String} service_name the name of the poll you wish to stop.
         * @param {Object} params       the params as passed into the polling service originally, used to identify the poll if the name is not unique
         */
        stop_poll: function(service_name, callback, scope){
            var sel = Ext.partition(this._poll_targets, function(target){ return target.service_name == service_name; })[0];

            if(sel.length > 1 && params){
                sel = Ext.partition(sel, function(target){
                    if(target.params.id){
                        return target.params.id === params.id;
                    }
                    else{
                        return target.params === params;
                    }
                })[0];
            }

            Ext.each(sel, function(s){ this._poll_targets.remove(s)}, this);

            if(Ext.empty(this._poll_targets)){
                this._stop();
            }
        },

        _start: function(){

        },

        _stop: function(){

        }
    });

    Application.PollingService = new polling_service();

})();