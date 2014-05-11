class ChangePortBindingsFromStringToText < ActiveRecord::Migration
  def change
    change_column :containers, :port_bindings, :text
    change_column :images, :port_bindings, :text
    change_column :images, :volumes, :text
  end
end
