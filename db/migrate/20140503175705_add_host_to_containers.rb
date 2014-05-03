class AddHostToContainers < ActiveRecord::Migration
  def change
    add_reference :containers, :host, index: true
  end
end
