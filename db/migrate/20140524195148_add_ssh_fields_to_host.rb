class AddSshFieldsToHost < ActiveRecord::Migration
  def change
    add_column :hosts, :ssh_private_key, :text
    add_column :hosts, :ssh_public_key, :text
    add_column :hosts, :ssh_known_hosts, :text
  end
end
