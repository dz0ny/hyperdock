class AddAvailableHostsCountToRegion < ActiveRecord::Migration
  def change
    add_column :regions, :available_hosts_count, :integer, default: 0, null: false
  end
end
