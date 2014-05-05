class AddVolumesAndSharedVolumesToImage < ActiveRecord::Migration
  def change
    add_column :images, :volumes, :string
    add_column :images, :shared_volumes, :boolean
  end
end
