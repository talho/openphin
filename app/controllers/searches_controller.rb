class SearchesController < ApplicationController
  
  before_filter :non_public_role_required
  #app_toolbar "han"
  
  def show
    if !params[:tag].blank?
      search_size = 20
      tags = params[:tag].split(/\s/).map{|x| x+'*'}.join(' ')
      @results = User.search("*" + tags, :match_mode => :any, :per_page => search_size, :page => params[:page]||1, :retry_stale => true, :sort_mode => :expr, :order => "@weight") 
      @paginated_results = @results;
      @results = sort_by_tag(@results, tags)
    end
    
    respond_to do |format|
      format.html
      format.json {
        @results = [] if @results.blank?
        render :json => @results.map{|u| {:caption => "#{u.name} #{u.email}", :value => u.id, :title => u.title,
                                          :extra => {:content => render_to_string(:partial => 'extra', :locals => {:user => u})}}}.concat([:paginate => render_to_string(:partial => 'paginate')])
      }
    end
  end

  
  def show_advanced
    options = {
      :retry_stale => true,                   # avoid nil results
      :order => :name,                        # ascending order on name
    }

    unless %w(pdf csv).include?(params[:format])
      options[:page] = params[:page]||1
      options[:per_page] = 8
    else
      options[:per_page] = 30000
      options[:max_matches] = 30000
    end

    build_fields params, conditions={}
    filters = build_filters params
    assure_name_not_in_advanced_search(conditions,filters)
    
    options[:conditions] = conditions unless conditions.empty?
    options[:match_mode] = :any if conditions[:name]
    options[:with] = filters unless filters.empty?
    @results = (conditions.empty? && filters.empty?) ? nil : User.search(options)
    
    respond_to do |format|
      format.html 
      format.pdf do
        prawnto :inline => false        
      end
      format.csv do
        @csv_options = { :col_sep => ',', :row_sep => :auto }
        @filename = "user_search_.csv"
        @output_encoding = 'UTF-8'
      end
      # for iPhone
      format.json do
        @results ||= []
          # this header is a must for CORS
          headers["Access-Control-Allow-Origin"] = "*"
          render :json => @results.map(&:to_people_results)
      end
    end
  end

  
protected

  def build_filters(params,filters={})
    [:role_ids,:jurisdiction_ids].each do |f|
      if params[f]
        filter = params[f].compact.reject(&:blank?)
        filters[f] = filter unless filter.empty?
      end
    end
    filters
  end

  def build_fields(params,fields={})
    [:name,:first_name,:last_name,:display_name,:email,:title].each do |f|
      field = params[f]
      fields[f] = field.gsub(/(:|@|-|!|~|&|"|\(|\)|\\|\|)/) { "\\#{$1}" } unless field.blank?
    end
    
    unless fields[:name].blank? || fields[:name].index('@').nil?
      fields[:email] = fields[:name]
      fields.delete(:name)
    end
    fields[:phone] = params[:phone].gsub(/([^0-9*])/,"") unless params[:phone].blank?
    fields
  end

  def sort_by_tag(results, tag)
    results = results.sort{|x,y| x.name <=> y.name}
    results.sort{|x,y|
      tsize = tag.size-2
      xval = (x.name[0..tsize].casecmp(tag[0..tsize]) == 0 ? -1 : 0)
      yval = (y.name[0..tsize].casecmp(tag[0..tsize]) == 0 ? -1 : 0)
      if(yval < xval)
        1
      else
        0
      end
    }
  end
  
  def assure_name_not_in_advanced_search(conditions,filters)
    is_advanced = !conditions.reject{|k,v|k==:name}.empty? && !filters.empty?
    conditions.reject!{|k,v|k==:name} if is_advanced
  end
    
end
