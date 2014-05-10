class AddEnvSettingsToContainer < ActiveRecord::Migration
  def change
    add_column :containers, :env_settings, :text
  end
end
