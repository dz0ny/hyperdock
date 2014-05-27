module SecureShellIdentity
  extend ActiveSupport::Concern

  def ssh_auth_files
    ident = { private_key: tmp.join("id_rsa"),
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
    self.ssh_private_key = ident[:private_key].read 
    self.ssh_public_key = ident[:public_key].read
    self.ssh_known_hosts = ident[:known_hosts].read
    self.save!
  end
end
