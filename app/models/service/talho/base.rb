class Service::TALHO::Base
  extend PropertyObject::ClassMethods
  include PropertyObject::InstanceMethods

  def fake_delivery?
    options["delivery_method"] == "test"
  end
  
  private

  def perform_delivery(body)
    
  end

end