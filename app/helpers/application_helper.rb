module ApplicationHelper
  def current_user
    user = super
    present user if user
  end

  def s(str, options=nil)
    content_tag :span, str, options
  end

  def d(str, options=nil)
    content_tag :div, str, options
  end

  def yn(value)
    value ? 'Yes' : 'No'
  end

  def tagged_form_for(name, *args, &block)
    options = args.last.is_a?(Hash) ? args.pop : {}
    options = options.merge(:builder => TaggedBuilder)
    args = (args << options)
    form_for(name, *args, &block)
  end

=begin
    output the portal toolbar in the following format:
      <h1><%= link_to 'TXPhin', root_path %></h1>
      <ul>
        <li<%= ' class="current"' if toolbar == 'han' %>><%= link_to s("HAN"), hud_path %></li>
        <li<%= ' class="current"' if toolbar == 'rollcall' %>><%= link_to s("RollCall"), roll_calls_path %></li>
        <li<%= ' class="current"' if toolbar == 'faqs' %>><%= link_to s("FAQs"), faqs_path %></li>
      </ul>
=end
  def portal_toolbar
    output = "<h1><a href='/'>TXPhin</a></h1>"
    output+="<ul>"
    @controller.applications.each do |name, app|
      output+="<li#{" class='current'" if app.entry == controller.class}>#{link_to(name, url_for(:controller => app.entry.controller_name))}</li>";
    end
    output+="</ul>"
    output
  end

  #output an application's toolbar
  def application_toolbar
    render :partial => @controller.toolbar
  end

  def tab_me(paths)
    paths = [paths] unless paths.class.name == "Array"

    paths.each do |path|
      case path.class.name
        when "Hash"
        return " class='current'" if (path[:action].blank? && controller.controller_name == path[:controller]) || (controller.action_name == path[:action] && controller.controller_name == path[:controller])
      when "String"
        return " class='current'" if request.request_uri.split('?')[0]==path
      else
        ""
      end
    end
    ""
  end
  
  def for_moderators_of(record, &block)
    current_user.moderator_of?(record) && concat(capture(&block))
  end

  def for_super_admin(&block)
    current_user.is_super_admin? && concat(capture(&block))
  end

  def textilize_alternate(text)
    RedCloth.new(text.gsub(/</, '&lt;').gsub(/>/, '&gt;')).to_html
  end

  def link_if_public(user)
    if ( user.respond_to?("public") && user.public ) 
      link_to h(user.name), user_profile_path(user)
    else
      h(user.name)
    end
  end  

end