module SearchModules
  module Search

    # this method is to prevent an inadverent denial-of-service
    def prevent_email_in_name(params)
      unless params[:name].blank? || params[:name].index('@').nil?
        params[:conditions][:email] = params[:name]
        params.delete(:name)
      end
    end

    def sanitize(conditions,exclude=[:phone])
      return unless conditions
      email = /[:"\*\!&]/
      other = /[:"@\-\*\!\~\&]/
      conditions.reject{ |k,v| exclude.include? k }.each do |k,v|
        regexp = (k == "email") ? email : other
        conditions[k] = v.gsub(regexp,'') unless conditions[k].blank?
      end
    end

    def strip_blank_elements(hsh)
      return if hsh.blank?
      hsh.delete_if{|k,v| v.blank?} if hsh
    end

    def strip_blank_arrays(hsh)
      return if hsh.blank?
      hsh.delete_if{|k,v| v.to_s.blank?} if hsh
    end

    def clean_phone_number(conditions)
        conditions[:phone].gsub!(/([^0-9*])/,"") if conditions && conditions[:phone].present?
    end

    def build_options(params)
      #  map EXT params to Sphinx params
      if params[:limit].present?
          params[:per_page] =  params.delete(:limit)
      end
      if params[:start].present?
        params[:page] = (params.delete(:start).to_i / params[:per_page].to_i).floor + 1
      end
      if params[:dir].present?
        params[:sort_mode] = params.delete(:dir).downcase.to_sym
      else
        params[:sort_mode] = :asc
      end
      options = HashWithIndifferentAccess.new(
        :retry_stale => true,                                        # avoid nil results
        :order => :last_name,                                        # ascending order on name
        :sort_mode => params[:sort_mode],
        :page => params[:page] ? params[:page].to_i : 1,             # paginate pages
        :per_page => params[:per_page] ? params[:per_page].to_i : 8, # paginate entries per page
        :star => true                                                # auto wildcard
      )
      options
    end

    def current_user_applications
      current_user.roles.map{|r| r.application.to_crc32 }
    end

    def normalize_search_params(params)
      strip_blank_elements(params[:conditions])
      strip_blank_arrays(params[:with])
      prevent_email_in_name(params)
      sanitize(params[:conditions])
      params[:with] = Hash.new if !params.has_key?(:with)
      params[:with][:applications] = current_user_applications
      if params[:admin_mode] == "1"
        if !params[:with].has_key?(:jurisdiction_ids)
          params[:with][:jurisdiction_ids] = Array.new
          current_user.jurisdictions.admin.each { |j|
            j.self_and_descendants.each { |jsub| params[:with][:jurisdiction_ids].push(jsub.id) }
          }
        end
      end
      clean_phone_number(params[:conditions])
      params.merge!(build_options(params))
    end

    def normalize_reports_params(params)
      strip_blank_elements(params[:conditions])
      strip_blank_arrays(params[:with])
      prevent_email_in_name(params)
      sanitize(params[:conditions])
      params[:with] = Hash.new if !params.has_key?(:with)
      params[:with][:applications] = current_user_applications
      clean_phone_number(params[:conditions])
      params.merge!(build_options(params))
    end


  end
end