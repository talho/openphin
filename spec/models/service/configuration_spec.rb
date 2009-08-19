require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Configuration" do
  context "sending phone and blackberry alerts" do
    it "should have separate configurations for each device service" do
      class Test1 < Service::Base
        load_configuration_file File.expand_path(File.dirname(__FILE__) + "/../../fixtures/test1.yml")
      end
      class Test2 < Service::Base
        load_configuration_file File.expand_path(File.dirname(__FILE__) + "/../../fixtures/test2.yml")
      end
      Test1.configuration.options.should_not == Test2.configuration.options
    end
  end
end