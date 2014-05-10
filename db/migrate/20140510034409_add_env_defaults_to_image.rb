class AddEnvDefaultsToImage < ActiveRecord::Migration
  def change
    add_column :images, :env_defaults, :text
  end
end
