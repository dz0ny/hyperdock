module SecureShellIdentity
  extend ActiveSupport::Concern

  def generate_ssh_identity
    ssh_auth_files.values {|file| FileUtils.rm(file) if file.exist? }
    `yes | ssh-keygen -t rsa -f #{ssh_auth_files[:private_key]} -N ""`
    self.ssh_identity = ssh_auth_files
    self.save!
  end

  def ssh_auth_files
    @ssh_auth_files ||= { private_key: tmp.join("id_rsa"),
                          public_key: tmp.join("id_rsa.pub"),
                          known_hosts: tmp.join("known_hosts") }
  end

  def ssh_identity
    ident = ssh_auth_files
    ident.keys.each do |key|
      ident[key].write self.send("ssh_#{key}".to_sym)
      ident[key].chmod 0600
    end
    ident
  end

  def ssh_identity= ident
    self.ssh_private_key = ident[:private_key].read.strip
    self.ssh_public_key = ident[:public_key].read.strip
    self.ssh_known_hosts = ident[:known_hosts].read rescue ""
    self.save!
  end
end
