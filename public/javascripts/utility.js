
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
}