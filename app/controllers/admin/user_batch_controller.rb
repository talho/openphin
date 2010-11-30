class Admin::UserBatchController < ApplicationController
  before_filter :admin_required
  app_toolbar "admin"

  def new
    @jurisdictions = current_user.jurisdictions.admin.find(:all, :select => "DISTINCT name", :order => "name")
  end

  def admin_jurisdictions
    jurisdictions = current_user.jurisdictions.admin.find(:all, :select => "DISTINCT name", :order => "name")
    render :json => jurisdictions
  end
  
  def create_from_json
    success = true
    error_messages = []

    user_list = ActiveSupport::JSON.decode(params[:user_batch][:users])
    user_list.each { |u|
      if User.find_by_email(u["email"]).nil?
        j = Jurisdiction.find_by_name(u["jurisdiction"])
        j = Jurisdiction.find_by_name(params[:user_batch][:jurisdiction]) if j.blank?
        u[:role_requests_attributes] = {0 => {:jurisdiction => j, :role => Role.public}}
        new_user = User.new(u)
        new_user.update_password("Password1", "Password1")

        if new_user.valid?
          new_user.save
          new_user.confirm_email!
        else
          success = false
          error_messages.concat(new_user.errors.full_messages)
        end
      end
    }

    respond_to do |format|
      format.json {
        if success
          render :json => {:flash => "Users created.", :type => :completed, :success => true}
        else
          render :json => {:flash => nil, :type => :error, :errors => error_messages}
        end
      }
    end
  end

  def create
    if request.post?
      if request.xhr?
        user_list = ActiveSupport::JSON.decode(params[:user_batch][:users])
        params[:user_batch].delete(:users)
        if !user_list.empty?
          csv_str = StringIO.new
          csv_str << user_list[0].keys.join(",") << "\n"
          user_list.each { |u| csv_str << u.values.join(",") << "\n" }
          csv_str.rewind
          params[:user_batch][:file_data] = csv_str
        end
      end
      @user_batch = UserBatch.new params[:user_batch]
      @user_batch.email = current_user.email
      success = false
      case @user_batch.valid
        when "bad-email"
          flash[:error] = "Authentication error, please contact your administrator."
        when "bad-jurisdiction"
          flash[:error] = "You do not have permission to add users to that jurisdiction."
        when "bad-file"
          flash[:error] = "Problem with file.  Please check that it is valid CSV."
        else        
          if @user_batch.save
            success = true
            flash[:notice] = 'The user batch has been successfully submitted.' + 
            '<br /> You will receive an E-Mail if there is a problem processing your request.'
          else
            flash[:error] = 'There was an error. No users were created.'
          end
      end

      respond_to do |format|
        format.html { redirect_to new_user_batch_path }
        format.json {
          if success
            render :json => {:flash => flash[:notice], :type => :completed, :success => true}
          else
            render :json => {:flash => flash[:error], :type => :error, :errors => nil}
          end
        }
      end
    end
  end

  def import
    fields = [ :last_name, :first_name, :display_name, :jurisdiction, :mobile, :fax, :phone, :email ]

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
