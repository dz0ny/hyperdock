class WebsocketController < WebsocketRails::BaseController
  def provision_host
    if current_user.admin?
      Provisioner.perform_async('Host', event.data['id'], password: event.data['password'])
    end
  end
  def reset_known_hosts
    if current_user.admin?
      h = Host.find(event.data['id'])
      h.ssh_known_hosts = ""
      h.save
    end
  end
end
