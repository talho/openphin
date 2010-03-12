class SearchesController < ApplicationController
  
  before_filter :non_public_role_required
  #app_toolbar "han"
  
  def show 
    if !params[:tag].blank?
      search_size = 300
      tags = params[:tag].split(/\s/).map{|x| x+'*'}.join(' ')
      @results = User.search("*" + tags, :match_mode => :any, :per_page => search_size, :retry_stale => true, :sort_mode => :expr, :order => "@weight")
      @results = sort_by_tag(@results, tags)
    end
    
    respond_to do |format|
      format.html
      format.json {
        @results = [] if @results.blank?
        render :json => @results.map{|u| {:caption => u.name, :value => u.id}} 
      }
    end
  end

  
  def show_advanced
    options = {
      :match_mode => :any,                    # 
      :retry_stale => true,                   # avoid nil results
      :order => :name,                        # ascending order on name
      :page=>params[:page]||1, :per_page=>8   # pagination, most entries have several roles
    }
    
    filters = build_filters params
    options[:with] = filters unless filters.empty?
    
    build_fields params, conditions={}
    options[:conditions] = conditions unless conditions.empty?
    options[:match_mode] = (conditions.size>1) ? :extended : :any

    @results = User.search options
  
  respond_to do |format|
    format.html 
    format.json {
      render :json => @results 
    }
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
    [:first_name,:last_name,:display_name,:email,:title].each do |f|
      field = params[f]
      fields[f] = field unless field.blank?
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
  
end
