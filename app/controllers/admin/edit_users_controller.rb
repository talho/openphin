class Admin::EditUsersController < ApplicationController
  before_filter :admin_required
  app_toolbar "admin"

  def admin_users
    jurs = current_user.jurisdictions.admin
    users = jurs.collect { |j| j.users }.flatten.uniq
    render :json => users
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
