class AddSshKeyCloudIdToHost < ActiveRecord::Migration
  def change
    add_column :hosts, :digitalocean_ssh_key_id, :integer
  end
end
