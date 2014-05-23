class AddIsMonitorToHost < ActiveRecord::Migration
  def change
    add_column :hosts, :is_monitor, :boolean, default: false, null: false
  end
end
