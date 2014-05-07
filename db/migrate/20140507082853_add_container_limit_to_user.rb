class AddContainerLimitToUser < ActiveRecord::Migration
  def change
    add_column :users, :container_limit, :integer, default: 2
  end
end
