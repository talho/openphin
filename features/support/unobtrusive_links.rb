module Webrat
  class Link

  protected

    def css_class
      @element["class"]
    end

    def http_method_from_css_class
      method = /(post|put|delete|destroy)/.match(css_class).to_a.last
      method == 'destroy' ? 'delete' : method
    end

    def http_method
      http_method_from_css_class || :get
    end
  end
end