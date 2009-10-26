module ApplicationHelper
  def current_user
    user = super
    present user if user 
  end
  
  def s(str,options=nil)
    content_tag :span, str, options
  end

  def d(str,options=nil)
    content_tag :div, str, options
  end
  
  def tagged_form_for(name, *args, &block)
    options = args.last.is_a?(Hash) ? args.pop : {}
    options = options.merge(:builder => TaggedBuilder)
    args = (args << options)
    form_for(name, *args, &block)
  end
  
end