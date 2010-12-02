class Admin::EditUsersController < ApplicationController
  before_filter :admin_required, :change_include_root
  app_toolbar "admin"
  after_filter :change_include_root_back

  def admin_users
    start = (params[:start] || 0).to_i
    limit = (params[:limit] || 50).to_i
    page = (start / limit).floor + 1
    sort = params[:sort]
    asc = (params[:dir] != "DESC")
    jurs = current_user.jurisdictions.admin
    all_users = jurs.collect { |j| j.users }.flatten.uniq.sort { |a,b| (asc ? 1 : -1) * (a[sort] <=> b[sort]) }
    users = all_users.paginate(:per_page => limit, :page => page)
    rows = users.collect { |u|
      rm_list = u.is_admin? ? u.role_memberships.all_roles : u.role_memberships.user_roles
      role_desc = rm_list.collect { |rm|
        {:id => rm.id, :role_id => rm.role_id, :rname => Role.find(rm.role_id).to_s, :type => "role", :state => "unchanged",
        :jurisdiction_id => rm.jurisdiction_id, :jname => Jurisdiction.find(rm.jurisdiction_id).to_s }
      }
      u.role_requests.unapproved.each { |rq|
        rq = {:id => rq.id, :role_id => rq.role_id, :rname => Role.find(rq.role_id).to_s, :type => "req", :state => "pending",
              :jurisdiction_id => rq.jurisdiction_id, :jname => Jurisdiction.find(rq.jurisdiction_id).to_s }
        role_desc.push(rq)
      }
      { :user => u, :roles => role_desc }
    }
    render :json => {:total => all_users.length, :rows => rows }
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
