class AddRegionToContainers < ActiveRecord::Migration
  def change
    add_reference :containers, :region, index: true
  end
end
