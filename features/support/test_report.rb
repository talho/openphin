class TestReport < Report
  self.view = 'reports/test_report'
  self.run_detached = true

  def self.build_report(user_id)
    r = self.new user_id: user_id
    r.params = {test: 'success'}
    r
  end
end
