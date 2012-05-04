Ext.ns('Ext.data.ux');

//Working around a problem with Ext reading json
Ext.override(Ext.data.DataReader,{
   realize: function(rs, data){
        if (Ext.isArray(rs)) {
            for (var i = rs.length - 1; i >= 0; i--) {
                // recurse
                if (Ext.isArray(data)) {
                    this.realize(rs.splice(i,1).shift(), data.splice(i,1).shift());
                }
                else {
                    // weird...rs is an array but data isn't??  recurse but just send in the whole invalid data object.
                    // the else clause below will detect !this.isData and throw exception.
                    this.realize(rs.splice(i,1).shift(), data);
                }
            }
        }
        else {
            // If rs is NOT an array but data IS, see if data contains just 1 record.  If so extract it and carry on.
            if (Ext.isArray(data) && data.length == 1) {
                data = data.shift();
            }
            if (!data[this.meta.idProperty]) {
                // TODO: Let exception-handler choose to commit or not rather than blindly rs.commit() here.
                //rs.commit();
                throw new Ext.data.DataReader.Error('realize', rs);
            }
            rs.phantom = false; // <-- That's what it's all about
            rs._phid = rs.id;  // <-- copy phantom-id -> _phid, so we can remap in Store#onCreateRecords
            rs.id = data[this.meta.idProperty];
            rs.data = data;

            rs.commit();
        }
    }
});

Ext.data.ux.RailsJsonReader = Ext.extend(Ext.data.JsonReader, {
    readResponse : function(action, response) {
        var dataRequired = action === Ext.data.Api.actions.create || action === Ext.data.Api.actions.read;
        var o = (response.responseText !== undefined) ? Ext.decode(response.responseText) : response;
        if (!o) {
            if(dataRequired)
                throw new Ext.data.JsonReader.Error('response');
            else
                o = {};
        }

        var root = this.getRoot(o);
        if (action === Ext.data.Api.actions.create) {
            var def = Ext.isDefined(root);
            if (def && Ext.isEmpty(root)) {
                throw new Ext.data.JsonReader.Error('root-empty', this.meta.root);
            }
            else if (!def) {
                throw new Ext.data.JsonReader.Error('root-undefined-response', this.meta.root);
            }
        }

        try
        {
            var data = (root) ? this.extractData(root, false) : [];
        }
        catch(e)
        {
            // there was a problem reading the data. If this was a create or read, this is a bad thing. If this was an update or delete, well, we might expect to not get any return data
            if(dataRequired)
            {
                throw e;
            }
        }

        var res = new Ext.data.Response({
            action: action,
            success: this.getSuccess(o) || (response.status >= 200 && response.status < 300), // see if the success property was filled, if not, clue off of the response code.
            data: data,
            message: this.getMessage(o),
            raw: o
        });

        if (Ext.isEmpty(res.success)) {
            throw new Ext.data.JsonReader.Error('successProperty-response', this.meta.successProperty);
        }

        return res;
    }
});