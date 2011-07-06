class Report::ReportsController < ApplicationController
  
 before_filter :non_public_role_required
  
 include ActionView::Helpers::DateHelper

  # GET /reports
  # GET /reports.json
  def index
#      @reports = Report::Report.paginate_for(:all,current_user,params[:page] || 1)
   params[:sort] = 'recipe_id' if params[:sort] == 'recipe'
   order = params[:sort].nil? ? 'created_at DESC' : "#{params[:sort]} #{params[:dir]}"
    respond_to do |format|
      format.html
      format.json do
        @reports = current_user.reports.find(:all, :order=>order, :limit => params["limit"], :offset => params["start"])
        report_count = current_user.reports.count
        ActiveRecord::Base.include_root_in_json = false
        @reports.collect! do |r|
          r.as_json(:inject=>{'report_path'=>report_report_path(r[:id]),'recipe'=>r.recipe.type_humanized})
        end
        render :json => {"reports"=>@reports,'total' => report_count, :success=>true}
      end
    end
  end

  # GET /report/1
  # GET /report/1.json
  def show
    report = current_user.reports.find_by_id(params[:id])
    rendering_path = report.rendering.path
    begin
      @rendering = File.read rendering_path
      respond_to do |format|
        format.json {render :json => @rendering}
      end
    rescue Errno::ENOENT
      REPORT_LOGGER.error "\nMissing #{rendering_path} rendering file"
    end
  end

  # POST /reports
  # POST /reports.json
  def create
    begin
      report = nil
      unless params[:report_url]
        # capture the resultset and generate the html rendering in delayed-job
        # before sending to delayed job, assure that the recipe exist in this Rails environment
        recipe = params[:recipe_type].constantize.find_or_create

        report = current_user.reports.create(:recipe=>recipe,:incomplete=>true)
#        Delayed::Job.enqueue( Reporters::Reporter.new(:report_id=>report[:id]) )
        Reporters::Reporter.new(:report_id=>report[:id]).perform  # for debugging
        respond_to do |format|
          format.html {}
          format.json {render :json => {:success => true, :id => report[:id]}}
        end
      else
        # copy/generate the supported format documents
        report = current_user.reports.find(params[:report_url].split(File::SEPARATOR).last.to_i)
        filepath = report.rendering.path
        basename = File.basename(filepath)
        case params[:document_format]
          when 'HTML': copy_to_documents File.read(filepath), basename
          when 'PDF':  copy_to_documents WickedPdf.new.pdf_from_string(File.read(filepath)), basename.sub(/html$/,'pdf')
          else raise "Unsupported format (#{params[:document_format]}) for file #{filepath}"
        end
        respond_to do |format|
          format.html {}
          format.json {render :json => {:success => true, :id => report[:id]}}
        end
      end
    rescue StandardError => error
      respond_to do |format|
        format.html {}
        format.json {render :json => {:success => false, :msg => error.as_json}, :content_type => 'text/html', :status => 406}
      end
    end
  end

  protected

  def copy_to_documents(content,filename)
    document = nil
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

