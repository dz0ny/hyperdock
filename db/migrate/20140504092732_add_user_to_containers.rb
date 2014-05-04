class AddUserToContainers < ActiveRecord::Migration
  def change
    add_reference :containers, :user, index: true
  end
end
