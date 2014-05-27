class AddDigitaloceanIdToHost < ActiveRecord::Migration
  def change
    add_column :hosts, :digitalocean_id, :integer
  end
end
