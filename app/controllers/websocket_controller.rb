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

  def list_containers
    if current_user.admin?
      h = Host.find(event.data['id'])
      ch = WebsocketRails["host_#{h.id}".to_sym]
      ch.trigger 'provisioner', { event: 'stdout', message: h.remote_containers.to_json }
    end
  end

  def get_host_info
    if current_user.admin?
      h = Host.find(event.data['id'])
      ch = WebsocketRails["host_#{h.id}".to_sym]
      JSON.pretty_generate(h.get_info).each_line do |line|
        ch.trigger 'provisioner', { event: 'stdout', message: line.chomp }
      end
    end
  end
end
