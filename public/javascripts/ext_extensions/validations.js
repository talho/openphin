Ext.apply(Ext.form.VTypes, {

  phone : function(value){
    return /\(?([2-9]\d{2})(\)?)(-|.|\s)?([1-9]\d{2})(-|.|\s)?(\d{4})/.test(value);
  },
  phoneText : 'Invalid phone number.',

  // Password validation:  Simply adding vtype:'password' to a field will apply the password formatting rules.
  // To ensure that two fields are matching requires an extra step: Give the first password field a unique id
  // and add initialPassword:'YOUR_ID_HERE' to the password confirmation field.
  password : function(value, field){
    if (field.initialPassword){
      var pwd     = null;
      var curr_ct = field.ownerCt;
      while(curr_ct.ownerCt){
        pwd = curr_ct.findComponent(field.initialPassword);
        if(!pwd) curr_ct = curr_ct.ownerCt;
        else break;
      }
      this.passwordText = 'Passwords must match.';
      return (value == pwd.getValue());
    }
    this.passwordText = 'Passwords must be at least 6 characters, containing at least one number, one lowercase, and one capital';
    var hasSpecial = value.match(/(?=[-_a-zA-Z0-9]*?[A-Z])(?=[-_a-zA-Z0-9]*?[a-z])(?=[-_a-zA-Z0-9]*?[0-9])[-_a-zA-Z0-9]/i);
    var hasLength = (value.length >= 6);
    return (hasSpecial && hasLength);
  },
  passwordText : 'Passwords must be at least 6 characters, containing at least one number, one lowercase, and one capital',

  blackberry : function(value){
    return /^[0-9A-Fa-f]{8}$/i.test(value);
  },
  blackberryText : 'Invalid Blackberry PIN',

  image : function(value){
     return /^.*.(jpe?g|png|gif)$/i.test(value);
   },
  imageText : 'Must be a JPG, PNG, or GIF file'
});

