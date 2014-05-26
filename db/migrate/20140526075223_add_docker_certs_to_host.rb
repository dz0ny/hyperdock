class AddDockerCertsToHost < ActiveRecord::Migration
  def change
    add_column :hosts, :docker_client_cert, :text
    add_column :hosts, :docker_client_key, :text
    add_column :hosts, :docker_ca_cert, :text
  end
end
