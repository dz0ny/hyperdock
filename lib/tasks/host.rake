namespace :host do
  desc %{Provision a new host in an existing region.}
  task provision: :environment do
    require 'net/ssh'

    Net::SSH.start(ENV['host'], 'root', password: ENV['password']) do |ssh|
      puts output = ssh.exec!("hostname")
    end
  end

end
