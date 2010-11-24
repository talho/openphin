class Admin::EditUsersController < ApplicationController
  before_filter :admin_required
  app_toolbar "admin"

  def admin_users
    start = (params[:start] || 0).to_i
    limit = (params[:limit] || 50).to_i
    sort = params[:sort]
    asc = (params[:dir] != "DESC")
    jurs = current_user.jurisdictions.admin
    users = jurs.collect { |j| j.users }.flatten.uniq.sort { |a,b| (asc ? 1 : -1) * (a[sort] <=> b[sort]) }
    page = (start / limit).floor + 1
    render :json => {:total => users.length, :rows => users.paginate(:per_page => limit, :page => page) }
  end

  def update
    success = true
    error_messages = []

    user_list = ActiveSupport::JSON.decode(params[:batch][:users])
    user_list.find_all{|u| u["state"]=="deleted" && u["id"] > 0}.each { |u|
      puts "Deleting #{u["first_name"]} #{u["last_name"]} #{u["email"]}"
      user = User.find(u["id"])
      user.destroy
    }
    user_list.find_all{|u| u["state"]=="new"}.each { |u|
      puts "Adding #{u["first_name"]} #{u["last_name"]} #{u["email"]}"
    }
    user_list.find_all{|u| u["state"]=="changed"}.each { |u|
      puts "Modifying #{u["first_name"]} #{u["last_name"]} #{u["email"]}"
      user = User.find(u["id"])
      user.update_attributes(u)
      unless user.save && user.valid?
        success = false
        error_messages.concat(user.errors.full_messages)
      end
    }

    respond_to do |format|
      format.json {
        if success
          render :json => {:flash => "Changes saved.", :type => :completed, :success => true}
        else
          render :json => {:flash => nil, :type => :error, :errors => error_messages}
        end
      }
    end
  end
  
end
