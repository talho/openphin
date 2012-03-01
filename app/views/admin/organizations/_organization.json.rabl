extends 'organizations/_organization'
child :contact => :contact do
  attributes :id, :email
  attributes :display_name => :name
end
child :group => :audience do
  child :users do
    attributes :id, :email
    attributes :display_name => :name
    node(:profile_path) {|u| user_profile_path(u)}
  end
  glue :jurisdictions do
    child :to_a do
      attributes :id, :name
    end
  end
  child :roles do
    attributes :id, :name
  end
end