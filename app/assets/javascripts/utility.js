
String.prototype.stripTags = function(){
    if(arguments.length<2) strMod=this.replace(/<\/?(?!\!)[^>]*>/gi, '');
    else{
        var IsAllowed=arguments[1];
        var Specified=eval("["+arguments[1]+"]");
        if(IsAllowed){
            var strRegExp='</?(?!(' + Specified.join('|') + '))[^>]*>';
            strMod=this.replace(new RegExp(strRegExp, 'gi'), '');
        }else{
            var strRegExp='</?(' + Specified.join('|') + ')[^>]*>';
            strMod=this.replace(new RegExp(strRegExp, 'gi'), '');
        }
    }
    return strMod;
};

if(Ext)
{
    Ext.override(Ext.menu.MenuNav, {
        left : function(e, m){
            if(m.parentMenu && m.parentMenu.activeItem){
                m.parentMenu.activeItem.activate();
            }
            else if(m.ownerCt && m.ownerCt.focus)
            {
                m.ownerCt.focus();
            }
            m.hide();
        }
    });

    Ext.DomQuery.pseudos.focus = function(c, v){
        var r = [];
        var re = new RegExp(/focus/g);
        Ext.each(c, function(comp){
            var ecomp = Ext.get(comp);
            if(re.test(ecomp.getAttribute('class')))
                r.push(comp);
        });
        return r;
    };

    Ext.override(Ext.data.JsonReader, {
        getBaseProperty: function(name){
            if(this.jsonData) return this.jsonData[name];
            else return null;
        }
    });
    
    Ext.namespace("Talho.Detection");

    Talho.Detection.SVG = function () {
      return (document.implementation.hasFeature("http://www.w3.org/TR/SVG11/feature#BasicStructure", "1.1") || document.implementation.hasFeature("http://www.w3.org/TR/SVG11/feature#Shape", "1.0"))
    }
}

