=begin
    OpenPHIN is an opensource implementation of the CDC guidelines for 
    a public health information network.
    
    Copyright (C) 2009  Texas Association of Local Health Officials

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

=end
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "phin_application" do
  before(:all) do
    class TestRouteAppsController < ApplicationController
      include Phin::Application
      phin_application "HAN", :entry => true

      def index
        render :text => applications.size
      end

      protected
      def login_required
        true
      end
    end
    ActionController::Routing::Routes.draw do |map|
      map.testroute "/testroute", :controller => "test_route_apps", :action => "index"
    end

    module PhinAppTest
      class Base < ApplicationController
      end
    end

  end

  it "should raise an error if multiple entry points are defined" do

    lambda{
      module Test1
        class App1 < PhinAppTest::Base
          include Phin::Application
          phin_application "HAN", :entry => true
        end
        class App2 < PhinAppTest::Base
          include Phin::Application
          phin_application "HAN", :entry => true
        end
      end

    }.should raise_error("Cannot define multiple entry points for a PhinApplication")
  end

  it "should set route to the entry point" do
    user=Factory(:user)
    get(testroute_path)
    response.body.should == 1.to_s
  end
  it "should raise an error if no entry points are set"
end