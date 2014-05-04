class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout :layout_by_controller

  protected

  def layout_by_controller
    if public_area?
      "site"
    else
      "application"
    end
  end

  def after_sign_in_path_for(resource)
    containers_path
  end

  def public_area?
    c = params["controller"]
    # Rails.logger.info "!!!!!!!!#{c}"
    return false if c =~ /invitations/
    c =~ /home/ || c =~ /devise/
  end
end
