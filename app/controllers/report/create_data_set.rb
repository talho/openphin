module Report
  module CreateDataSet

    def create_data_set(recipe_name,criteria={})
      # capture the resultset and generate the html rendering in delayed-job
      # assure that the recipe exist in this Rails environment before sending to delayed job
      report = current_user.reports.create!(:recipe=>recipe_name,:criteria=>criteria,:incomplete=>true)
      unless Rails.env == 'development'
        Delayed::Job.enqueue( Reporters::Reporter.new(:report_id=>report[:id]) )
      else
        Reporters::Reporter.new(:report_id=>report[:id]).perform  # for development
      end
      report
    end

  end
end