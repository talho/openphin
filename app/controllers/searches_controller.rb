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

  def show_clean
    unless params[:tag].blank?
      search_size = 20
      tags = params[:tag].split(/\s/).map{|x| '*' + x + '*'}.join(' ')
      @results = User.search(tags, :match_mode => :all, :per_page => search_size, :page => params[:page]||1, :retry_stale => true, :sort_mode => :expr, :order => "@weight")
      @results = sort_by_tag(@results, tags)
    end

    @results = [] if @results.blank?
    render :json => @results.map{|u| {:caption => "#{u.name} #{u.email}", :name => u.name, :email => u.email, :id => u.id, :title => u.title,
                                      :extra => render_to_string(:partial => 'extra.json', :locals => {:user => u})}}


  end
  
  def show_advanced
    if request.get? && params.count == 2
      @results = []
    else
      strip_blank_elements(params[:conditions])
      strip_blank_arrays(params[:with])
      prevent_email_in_name(params)
      sanitize(params[:conditions])
      params[:conditions][:phone].gsub!(/([^0-9*])/,"") unless params[:conditions].blank? || params[:conditions][:phone].blank?
      @results = User.search(params.merge!(build_options(params)))
    end
    
    respond_to do |format|
      format.html
      format.pdf { prawnto :inline => false }
      format.csv do
        @csv_options = { :col_sep => ',', :row_sep => :auto }
        @filename = "user_search_.csv"
        @output_encoding = 'UTF-8'
      end
     format.iphone do
       @results ||= []
         # this header is a must for CORS
         headers["Access-Control-Allow-Origin"] = "*"
         render :json => @results.map(&:to_iphone_results)
     end
     format.json do
       for_admin = current_user.is_admin?
       @results ||= []
       #@results.compact!  # it is possible for shinx to return nil elements in this array
       render :json => { 'success' => true,
                         'results' => @results.collect {|u| u.to_json_results(for_admin)},
                         'total' => @results.total_entries}
     end
   end
  end
  
protected

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
  
  def build_options(params)
    #  map EXT params to Sphinx params
    unless params[:limit].blank?
        params[:per_page] =  params.delete(:limit)
    end
    unless params[:start].blank?
      params[:page] = (params.delete(:start).to_i / params[:per_page].to_i).floor + 1
    end
    unless params[:dir].blank?
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
    if %w(pdf csv).include?(params[:format])
      options[:per_page] = 30000
      options[:max_matches] = 30000
    end
    return options
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
  
end
