class Service::SWN::Phone::Base < Service::SWN::Base
  extend PropertyObject::ClassMethods
  include PropertyObject::InstanceMethods
  include Validatable
end