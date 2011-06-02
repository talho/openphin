class Dashboard::DashboardAudience < ActiveRecord::Base
  set_table_name "audiences_dashboards"
  ROLES={:viewer => 1, :reviewer => 2, :approver => 3, :assigner => 4, :publisher => 5, :editor => 6}
  
  belongs_to :dashboard
  belongs_to :audience
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  def role
    ROLES.index(read_attribute(:role)).to_s
  end

  def role=(r)
    write_attribute(:role, ROLES[r.class == Symbol ? r : r.to_sym])
  end
end