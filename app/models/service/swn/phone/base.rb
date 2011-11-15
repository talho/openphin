class Service::Swn::Phone::Base < Service::Swn::Base
  extend PropertyObject::ClassMethods
  include PropertyObject::InstanceMethods
  include Validatable
end