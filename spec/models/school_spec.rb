# == Schema Information
#
# Table name: schools
#
#  id            :integer(4)      not null, primary key
#  name          :string(255)
#  display_name  :string(255)
#  level         :string(255)
#  address       :string(255)
#  postal_code   :string(255)
#  school_number :integer(4)
#  district_id   :integer(4)
#  created_at    :datetime
#  updated_at    :datetime
#  region        :string(255)
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe School do

  describe "validations" do
    before(:each) do
      @school=Factory(:school)
    end

    it "should be valid" do
      @school.should be_valid
    end
  end

  describe "named scope" do
    describe "with_alerts" do
      before(:each) do
        @school=Factory(:school)
        @school.absentee_reports.create(:enrolled => 100, :absent => 20, :report_date => Date.today-1.days)
        @school.absentee_reports.create(:enrolled => 100, :absent => 10, :report_date => Date.today-2.days)
        Factory(:school)

      end
      it "should return schools with an alert" do
        School.with_alerts.should include(@school)
        School.with_alerts.size.should == 1
      end
      it "should not return schools that only have alerts older than 30 days" do
        oldschool=Factory(:school)
        oldschool.absentee_reports.create(:enrolled => 100, :absent => 20, :report_date => Date.today-31.days)

      end
    end
  end
end
