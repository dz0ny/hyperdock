class WebsocketController < WebsocketRails::BaseController
  def provision_host
    if current_user.admin?
      Provisioner.perform_async('Host', event.data['id'], password: event.data['password'])
    end
  end
end
