class Admin::UserBatchController < ApplicationController
  before_filter :admin_required
  app_toolbar "admin"

  def new
    @jurisdictions = current_user.jurisdictions.admin.find(:all, :select => "DISTINCT name", :order => "name")
  end
  
  def create
   if request.post?
      @user_batch = UserBatch.new params[:user_batch]
      @user_batch.email = current_user.email
      case @user_batch.valid
        when "bad-email"
          flash[:error] = "Authentication error, please contact your administrator."
        when "bad-jurisdiction"
          flash[:error] = "You do not have permission to add users to that jurisdiction."
        when "bad-file"
          flash[:error] = "Problem with file.  Please check that it is valid CSV."
        else        
          if @user_batch.save
            flash[:notice] = 'The user batch has been successfully submitted.' + 
            '<br /> You will receive an E-Mail if there is a problem processing your request.'
          else
            flash[:error] = 'There was an error. No users were created.'
          end
      end
      redirect_to new_user_batch_path
    end
  end

  def import
    fields = [ :lastname, :firstname, :displayname, :jurisdiction, :mobile, :fax, :phone, :email ]

    csvfile = params[:users][:csvfile]
    users = []
    error = nil
    begin
      FasterCSV.new(csvfile, :col_sep => ",", :headers => true).each { |record|
        new_user = Hash.new
        fields.each_with_index { |field,i| new_user[field] = record[field.to_s] }
        users.push(new_user)
      }
    rescue FasterCSV::MalformedCSVError => detail
      error = "CSV file was malformed or corrupted.<br/><br/>Error:<br/>#{detail.message}"
    rescue => e
      puts "#{e.class}: #{e.message}\n  #{e.backtrace[0..5].join("\n  ")}"
      error = "This does not appear to be a CSV file."
    end

    respond_to do |format|
      format.html do
        if error.nil?
          render :json => {:success => true, :users_attributes => users}.as_json, :content_type => 'text/html'
        else
          render :json => {:success => false, :error => error}.as_json, :content_type => 'text/html'
        end
      end

      format.json do
        if error.nil?
           render :json => {:success => true, :users_attributes => users}.as_json
         else
           render :json => {:success => false, :error => error}.as_json
         end
       end
    end
  end
end
