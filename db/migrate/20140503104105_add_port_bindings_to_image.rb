class AddPortBindingsToImage < ActiveRecord::Migration
  def change
    add_column :images, :port_bindings, :string
  end
end
