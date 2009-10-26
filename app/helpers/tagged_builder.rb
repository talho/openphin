class TaggedBuilder < ActionView::Helpers::FormBuilder
  
  # <p>
  # <label for="product description"">Description</label><br/>
  # <%= form.text_area 'description' %>
  # </p>
  
  # It is intended that this to be the home for openphin form standards, Please add functionality
  # here.
  
  def self.create_tagged_field(method_name)
    define_method(method_name) do |label, *args|
      @template.content_tag("p",
        @template.content_tag("label", label.to_s.humanize, :for => "#{@object_name}_#{label}") + 
        "<br/>" + 
        super)
    end
  end
  
  %w[password_field text_field radio_button file_field text_area collection_select].each do |name|
    create_tagged_field(name)
  end
  
  def check_box(field_name, *args)
    @template.content_tag(:p, super + " " + field_error(field_name) + field_label(field_name, *args))
  end
  
  def many_check_boxes(name, subobjects, id_method, name_method, options = {})
    @template.content_tag(:p) do
      field_name = "#{object_name}[#{name}][]"
      subobjects.map do |subobject|
        @template.check_box_tag(field_name, subobject.send(id_method), object.send(name).include?(subobject.send(id_method))) + " " + subobject.send(name_method)
      end.join("<br />") + @template.hidden_field_tag(field_name, "")
    end
  end

  def submit(*args)
    @template.content_tag(:p, super)
  end
  
  # requires the validation reflection plugin
  def field_required?(field_name)
    object.class.reflect_on_validations_for(field_name).map(&:macro).include?(:validates_presence_of)
  end
  
  

end

