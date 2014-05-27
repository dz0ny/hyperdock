class AddDigitaloceanIdToRegion < ActiveRecord::Migration
  def change
    add_column :regions, :digitalocean_id, :integer
  end
end
