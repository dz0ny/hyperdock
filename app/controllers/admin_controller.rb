class AdminController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorize_admin!
  layout 'application'

  private
    def authorize_admin!
      if not current_user.admin?
        redirect_to '/'
      end
    end
end
