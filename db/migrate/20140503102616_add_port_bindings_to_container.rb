class AddPortBindingsToContainer < ActiveRecord::Migration
  def change
    add_column :containers, :port_bindings, :string
  end
end
