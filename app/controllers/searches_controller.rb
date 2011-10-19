class SearchesController < ApplicationController

  before_filter :non_public_role_required
  #app_toolbar "han"
  include SearchModules::Search

  def show
    if !params[:tag].blank?
      search_size = 20
      tags = params[:tag].split(/\s/).map{|x| x+'*'}.join(' ')
      @results = User.search("*" + tags, :match_mode => :all, :with => {:applications => current_user_applications}, :per_page => search_size, :page => params[:page]||1, :retry_stale => true, :sort_mode => :expr, :order => "@weight") 
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
      without = params[:without_ids].nil? || params[:without_ids].empty? || params[:without_ids][0].blank? ? {} : {:user_id => params[:without_ids]}
      search_size = (params[:limit]||20).to_i
      page = (params[:start]||0).to_i/search_size + 1
      tags = params[:tag].split(/\s/).map{|x| '*' + x + '*'}.join(' ')
      @results = User.search(tags, :match_mode => :all, :without => without, :with => {:applications => current_user_applications}, :per_page => search_size, :page => page, :retry_stale => true, :sort_mode => :expr, :order => "@weight")
      total = @results.total_entries
      @results = sort_by_tag(@results, tags)
    end

    @results = [] if @results.blank?
    render :json => { :total => total,
                      :users => @results.map{|u| {:caption => "#{u.name} #{u.email}", :name => u.name, :email => u.email, :id => u.id, :title => u.title,
                                      :extra => render_to_string(:partial => 'extra.json', :locals => {:user => u})}}}
  end

  def show_advanced
    if request.get? && params.count == 2
      @results = []
    else
      normalize_search_params(params)
      @results = User.search(params)
    end
    respond_to do |format|
      format.html
      format.pdf
      format.csv
     format.iphone do
       @results ||= []
         # this header is a must for CORS
         headers["Access-Control-Allow-Origin"] = "*"
         render :json => @results.map(&:to_iphone_results)
     end
     format.json do
       @results ||= []
       @results.compact!  # it is possible for sphinx to return nil elements in this array
       render :json => { 'success' => true,
                         'results' => @results.collect {|u| u.to_json_results(current_user.is_admin?)},
                         'total' => @results.total_entries}
     end
   end
  end

protected

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
