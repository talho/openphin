class AudiencesController < ApplicationController

  before_filter :change_include_root
  after_filter :change_include_root_back
  
  def index
    # this will at some point possibly return all of the audience data that we need
  end

  def jurisdictions
    render :json => [build_jurisdiction_hash(Jurisdiction.root)]
  end

  def jurisdictions_flat
    jurisdictions = Jurisdiction.root.self_and_descendants
    jurisdictions.delete_if { |j| j.foreign } if params[:ns] == "nonforeign"
    data = Array.new
    Jurisdiction.each_with_level(jurisdictions) { |j,level|
      data << {:name => j.name, :id => j.id, :leaf => j.leaf?, :left => j.left, :right => j.right, :level => level, :parent_id => j.parent_id}
    }
    render :json => data
  end

  def roles
    roles = current_user.is_admin? ? Role.all : Role.user_roles
    render :json => roles.collect {|r| {:id => r.id, :name => r.display_name}}
  end

  def groups
    render :json => (current_user.visible_groups | Organization.non_foreign.map(&:group)).flatten.compact
  end

  def determine_recipients
    recipients = []
    params[:group_ids].compact.reject{|x| x.empty?}.each do |id|
      recipients << Group.find(id).recipients(:force => true)
    end
    params[:jurisdiction_ids].compact.each do |id|
      recipients << Jurisdiction.find(id).users unless id.blank?
    end
    params[:role_ids].compact.each do |id|
      recipients << Role.find(id).users unless id.blank?
    end
    params[:user_ids].compact.each do |id|
      recipients << User.find(id) unless id.blank?
    end

    render :json => recipients.flatten.map {|user| {'name' => user.display_name, 'id' => user.id, 'profile_path' => user_profile_path(user)}}.uniq
  end

  def recipients
    audience = Audience.find(params[:audience_id])
    
    respond_to do |format|
      format.json {render :json => audience.recipients.with_no_hacc.map{ |u| {:caption => "#{u.name} #{u.email}", :name => u.name, :email => u.email, :id => u.id, :title => u.title,
                                      :tip => render_to_string(:partial => 'searches/extra.json', :locals => {:user => u})} } }
    end
  end

  private

  def build_jurisdiction_hash(jurisdiction, level = 0)
    jur_hash = {:text => jurisdiction.name, :id => jurisdiction.id, :leaf => jurisdiction.leaf?}

    unless jurisdiction.leaf? || level == 1
      jur_hash[:children] = jurisdiction.children.map{|child| build_jurisdiction_hash(child, level == 0 ? 0 : level - 1)}
    end

    jur_hash
  end
end
