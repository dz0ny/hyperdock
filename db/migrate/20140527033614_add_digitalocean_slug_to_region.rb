class AddDigitaloceanSlugToRegion < ActiveRecord::Migration
  def change
    add_column :regions, :digitalocean_slug, :string
  end
end
