require File.dirname(__FILE__) + '/../spec_helper'

describe RoleRequestsController do
  should_require_login_on_all_actions
end
