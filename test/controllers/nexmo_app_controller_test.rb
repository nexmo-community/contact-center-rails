require 'test_helper'

class NexmoAppControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get nexmo_app_show_url
    assert_response :success
  end

end
