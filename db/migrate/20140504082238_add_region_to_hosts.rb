class AddRegionToHosts < ActiveRecord::Migration
  def change
    add_reference :hosts, :region, index: true
  end
end
