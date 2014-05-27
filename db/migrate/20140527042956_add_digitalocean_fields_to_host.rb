class AddDigitaloceanFieldsToHost < ActiveRecord::Migration
  def change
    add_column :hosts, :digitalocean_region_id, :integer
    add_column :hosts, :digitalocean_size_id, :integer
  end
end
