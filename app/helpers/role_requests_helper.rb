module RoleRequestsHelper
  
  def to_rpt(element)
    if element.kind_of?(Array)
      if element.first.kind_of?(Hash)
        element.map{|rm| "#{rm['role']} in #{rm['jurisdiction']}"}.sort[0..1].join("</br>")
      end
    else
      element
    end
  end

end