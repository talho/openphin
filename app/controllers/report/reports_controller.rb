class Report::ReportsController < ApplicationController

 before_filter :non_public_role_required
  
 include SearchModules::Search
 include ActionView::Helpers::DateHelper

  #  GET /report/reports(.:format)
  def index
   order = params[:sort].nil? ? 'created_at DESC' : "#{params[:sort]} #{params[:dir]}"
    respond_to do |format|
      format.html
      format.json do
        @reports = current_user.reports.complete.find(:all, :order=>order, :limit => params["limit"], :offset => params["start"])
        report_count = current_user.reports.complete.count
        ActiveRecord::Base.include_root_in_json = false
        @reports.collect! do |r|
          r.as_json(:inject=>{'report_path'=>report_report_path(r[:id]),'recipe'=>r.name})
        end
        render :json => {"reports"=>@reports,'total' => report_count, :success=>true}
      end
    end
  end

  # GET /report/reports/:id(.:format)
  def show
    report = current_user.reports.find_by_id(params[:id])
    rendering_path = report.rendering.path
    rendering_path.sub!(/\.html$/,"-#{params[:filter_at]}.html") if params[:filter_at]
    begin
      @rendering = File.read rendering_path
    rescue Errno::ENOENT
      Reporters::Reporter.new(:report_id=>report[:id],:render_only=>true).perform
      @rendering = File.read rendering_path
    end
    respond_to do |format|
      format.json {render :json => @rendering}
    end
  end

  # POST /report/reports/:id/reduce(.:format)
  # this is a filtered version of create
  def reduce
    # before sending to delayed job, assure that report and recipe exist
    report = Report::Report.find_by_id(params[:id])
    # before sending to delayed job, assure that filters can be decoded
    filters = nil
    if params[:filters]
      filters = {"elements" => ActiveSupport::JSON.decode(params[:filters])}
      filters["filtered_at"] = Base32::Crockford.encode(Time.now.to_i)
    end
    run_reporter(:report_id=>report[:id],:filters=>filters)
    respond_to do |format|
      format.html {}
      format.json {render :json => {:success => true, :id => report[:id], :filtered_at => filters["filtered_at"]}}
    end
  end

  #  POST /report/reports(.:format)
  def create
    begin
      unless params[:report_url]
        recipe = params[:criteria] ? params[:criteria][:recipe] : params[:recipe_id]
        # capture the resultset and generate the html rendering in delayed-job
        report = current_user.reports.create!(:recipe=>recipe,:criteria=>params[:criteria],:incomplete=>true)
        run_reporter(:report_id=>report[:id])
        respond_to do |format|
          format.html {}
          format.json {render :json => {:success => true, :report => {:name=>report.full_name}}}
        end
      else
        # copy/generate the supported format documents
        report = current_user.reports.find(params[:report_url].split(File::SEPARATOR).last.to_i)
        filepath = report.rendering.path
        basename = File.basename(filepath)
        case params[:document_format]
          when 'HTML' then copy_to_documents File.read(filepath), basename
          when 'PDF' then  copy_to_documents WickedPdf.new.pdf_from_string(File.read(filepath)), basename.sub!(/html$/,'pdf')
          when 'CSV' then  copy_to_documents report.to_csv, basename.sub(/html$/,'csv')
          else raise "Unsupported format (#{params[:document_format]}) for file #{filepath}"
        end
        respond_to do |format|
          format.html {}
          format.json {render :json => {:success => true, :report =>{:file=>{:name=>basename}}}}
        end
      end
    rescue StandardError => error
      respond_to do |format|
        format.html {}
        format.json {render :json => {:success => false, :msg => error.message, :backtrace => error.backtrace}, :content_type => 'text/html', :status => 406}
      end
    end
  end

  # GET /report/reports/:id/filters(.:format)
 #  {"xtype": "combo", "fieldLabel": "Name",  "store": ["Richard Boldway"]}
 #  {"xtype": "slider","fieldLabel": "Index", "minValue": 0, "maxValue": 100, "values": [25,50]},

  def filters
    # builds the extjs panel items ready for binding
    @report = current_user.reports.complete.find_by_id(params[:id])
    dataset = @report.dataset
    raw = {"i"=>{"$exists"=>true}}
    @filters = (dataset.find(raw).first||{}).inject([]) do |result,element|
      key = element.first
      value = element.last
      case vtype = value.class.name
        when "Fixnum","Time"
          # presets the slider to minimum and maximum found
          min = dataset.find(raw).sort([key,'ascending']).limit(1).first[key]
          max = dataset.find(raw).sort([key,'descending']).limit(1).first[key]
          unless min == max
            item = {"type"=>vtype, "name"=>key, "fieldLabel"=>key.humanize, "minValue"=>min, "maxValue"=>max, "values"=>[min,max]}
            result << item
          end
        when "String"
           # intent to change this to the 10 most popular by grouping, may need to map/reduce
          list = dataset.distinct(key)[0..9]
          unless list.size < 2
            result << {"type"=>vtype, "name"=>key, "fieldLabel"=>key.humanize, "store"=>list }
          end
        when "FalseClass","TrueClass"
          true_count = dataset.find(raw.reverse_merge({key=>true})).count
          false_count = dataset.find(raw.reverse_merge({key=>false})).count
          unless (true_count+false_count) < 2
            result << {"type"=>"Boolean", "name"=>key, "fieldLabel"=>key.humanize, "checked"=>(true_count >= false_count)}
          end
      end
      result
    end
    respond_to do |format|
      format.html {}
      format.json { render :json => {"filters"=>@filters, :success=>true} }
    end
  end

  protected

   def run_reporter(options)
     reporter = ::Reporters::Reporter.new(options)
     if Rails.env == 'development'
       reporter.perform  # for debugging
     else
       reporter.delay.perform
     end
   end

  def copy_to_documents(content,filename)
    folder = current_user.folders.find_by_name('Reports') || current_user.folders.create(:name=>'Reports')
    Dir.mktmpdir do |dir|
      path = File.join(dir,filename)
      File.open(path, 'wb') {|f| f.write(content) }
      document = current_user.documents.build({:folder_id => folder[:id],:file => File.new(path, "rb") })
      document.owner_id = current_user[:id]
      document.save!
    end
  end


end
