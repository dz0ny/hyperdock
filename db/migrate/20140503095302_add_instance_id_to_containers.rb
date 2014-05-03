class AddInstanceIdToContainers < ActiveRecord::Migration
  def change
    add_column :containers, :instance_id, :string
  end
end
