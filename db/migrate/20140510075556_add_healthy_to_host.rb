class AddHealthyToHost < ActiveRecord::Migration
  def change
    add_column :hosts, :healthy, :boolean, default: false, null: false
  end
end
