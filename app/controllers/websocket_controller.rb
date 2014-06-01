class WebsocketController < WebsocketRails::BaseController
  def provision_host
    if user.admin?
      Provisioner.perform_async('Host', event.data['id'], password: event.data['password'])
    end
  end

  def reset_known_hosts
    if user.admin?
      h = Host.find(event.data['id'])
      h.update_column(:ssh_known_hosts, '')
    end
  end

  def list_containers
    if user.admin?
      h = Host.find(event.data['id'])
      ch = WebsocketRails["host_#{h.id}".to_sym]
      ch.trigger 'provisioner', { event: 'stdout', message: h.remote_containers.to_json }
    end
  end

  def get_host_info
    if user.admin?
      h = Host.find(event.data['id'])
      ch = WebsocketRails["host_#{h.id}".to_sym]
      JSON.pretty_generate(h.get_info).each_line do |line|
        ch.trigger 'provisioner', { event: 'stdout', message: line.chomp }
      end
    end
  end

  def list_sensu_checks
    h = Host.find(event.data['id'])
    # not implemented 
    # http://sensuapp.org/docs/0.11/api
  end

  private
  def user
    @user ||= current_user || User.find_by_auth_token(event.data['user_token'])
  end
end
