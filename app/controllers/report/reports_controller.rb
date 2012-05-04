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
        # capture the resultset and generate the html rendering in delayed-job
        report = current_user.reports.create!(:recipe=>params[:recipe_id],:criteria=>params,:incomplete=>true)
        run_reporter(:report_id=>report[:id])
        respond_to do |format|
          format.html {}
          format.json {render :json => {:success => true, :report => {:name=>report.name}}}
        end
      else
        # copy/generate the supported format documents
        report = current_user.reports.find(params[:report_url].split(File::SEPARATOR).last.to_i)
        filepath = report.rendering.path
        basename = File.basename(filepath)
        case params[:document_format]
          when 'HTML' then copy_to_documents File.read(filepath), basename
          when 'PDF' then  copy_to_documents WickedPdf.new.pdf_from_string(File.read(filepath)), basename.sub!(/html$/,'pdf')
          when 'CSV' then  copy_to_documents data2csv(report), basename.sub(/html$/,'csv')
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

  # DEPRECATE
  def html2csv(table_string)
    doc = Nokogiri::HTML(table_string)
    data = []
    header = doc.xpath('//table/thead/tr/th').inject(""){|s,ele| s << %Q(\"#{ele.text}\", )}
    embedded = []
    idx = 0
    doc.xpath('//table/tr').each do |tr|
      idx += 1 if tr.xpath('./@class[contains(., "report-data-first")]').present?
      break if idx > 1
      tr.xpath('th').each { |embedded_th| embedded.push(embedded_th.text) }
    end
    header += embedded.uniq.inject(""){|s,ele| s << %Q(\"#{ele}\", )}
    idx = 0
    data[idx] = header.sub(/, $/,"")
    idx += 1 unless doc.xpath('//table/tr[contains(@class,"report-data-first")]').present?
    doc.xpath('//table/tr').each do |row|
      if row.xpath('./@class[contains(., "report-data-first")]').present?
        idx += 1
        data[idx] = ""
      end
      row.xpath('td').each do |data_obj|
        data[idx] << '"' + data_obj.text.gsub("\n"," ").gsub('"','\"').gsub(/(\s){2,}/m, '\1') + "\", "
      end
    end
    data.collect{|ele|ele.sub(/, $/,"")}.join("\n")
  end

  def data2csv(report)
    # uses the view helpers just as the html templates would
    begin
      meta = report.dataset.find({:meta=>{:$exists=>true}}).first["meta"]
      raise "Report #{report.name} is missing meta component" unless meta
#     ex: [['name','Name'],['email','Email Address'],['role_requests','Pending Role Requests','to_rpt']]
      directives = meta["template_directives"]
      raise "Report #{report.name} is missing column directives" unless directives
    # setup supporting view
      helper_expected = directives.detect{|e| e.size > 2}
      if helper_expected
        view = ActionView::Base.new
        recipe = report.recipe.constantize
        helpers = recipe.respond_to?(:helpers) ? (recipe.helpers || []) : []
        helpers.each {|h| view.extend(h.constantize)}
      end
    # generate csv
      headers = directives.collect{|col| col.first}
      raise "Report #{report.name} has malformed the csv header" unless headers.kind_of? Array
      entries = report.dataset.find(:i=>{:$exists=>true})
      FasterCSV.generate(:force_quotes=>true,:headers=>headers,:write_headers=>true) do |row|
        entries.each do |entry|
          rr = directives.inject([]) do |memo,column|
            memo << ( (column.size > 2) ? view.send(column[2],entry[column[0]]) : entry[column[0]] )
          end
          row << rr
        end
      end
    rescue StandardError => error
      raise error
    end
  end

  # DEPRECATE
  def mimic_file
    file = StringIO.new(part.body) #mimic a real upload file
    file.class.class_eval { attr_accessor :original_filename, :content_type } #add attr's that paperclip needs
    file.original_filename = part.filename #assign filename in way that paperclip likes
    file.content_type = part.mime_type # you could set this manually as well if needed e.g 'application/pdf'

    # now just use the file object to save to the Paperclip association.

    a = Asset.new
    a.asset = file
    a.save!

  end

end
