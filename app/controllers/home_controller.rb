class HomeController < ApplicationController
  layout "site"

  def index
  end

  def status
    @regions = Region.all
  end
end
