class PhinPersonMapper
  #TODO: create a validator to check for well-formed dsml documents
  include HappyMapper
  tag 'entry', :namespace => "dsml"

end

