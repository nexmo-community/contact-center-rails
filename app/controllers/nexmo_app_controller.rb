class NexmoAppController < ApplicationController
  def show
    @nexmo_app = NexmoApp.new
  end
end
