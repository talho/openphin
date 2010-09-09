class AudiencesController < ApplicationController

  def index
    # this will at some point possibly return all of the audience data that we need
  end

  def jurisdictions
    render :json => [build_jurisdiction_hash(Jurisdiction.root)]
  end

  def jurisdictions_flat
    render :json => Jurisdiction.root.self_and_descendants.map {|node| {:name => node.name, :id => node.id, :leaf => node.leaf?, :left => node.left, :right => node.right, :level => node.level, :parent_id => node.parent_id} }
  end

  def roles
    render :json => current_user.is_admin? ? Role.all : Role.user_roles
  end

  def groups
    render :json => (current_user.visible_groups | Organization.non_foreign.map(&:group)).flatten.compact
  end

  def determine_recipients
    recipients = []
    params[:group_ids].compact.each do |id|
      recipients << Group.find(id).prepare_recipients(:include_public => true, :recreate => true).find(:all) unless id.blank?
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

  private

  def build_jurisdiction_hash(jurisdiction, level = 0)
    jur_hash = {:text => jurisdiction.name, :id => jurisdiction.id, :leaf => jurisdiction.leaf?}

    unless jurisdiction.leaf? || level == 1
      jur_hash[:children] = jurisdiction.children.map{|child| build_jurisdiction_hash(child, level == 0 ? 0 : level - 1)}
    end

    jur_hash
  end
end
