class Dashboard::DashboardAudience < ActiveRecord::Base
  set_table_name "audiences_dashboards"
  ROLES={:viewer => 1, :reviewer => 2, :approver => 3, :assigner => 4, :publisher => 5, :editor => 6}
  
  belongs_to :dashboard
  belongs_to :audience, :dependent => :destroy
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  accepts_nested_attributes_for :audience #, :reject_if => Proc.new{|attributes| attributes["id"] != self.audience_id}

  def role
    ROLES.key(read_attribute(:role)).to_s
  end

  def role=(r)
    write_attribute(:role, r.class == Fixnum ? r : ROLES[r.class == Symbol ? r : r.to_sym])
  end
end