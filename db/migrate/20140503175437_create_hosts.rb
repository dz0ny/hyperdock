class CreateHosts < ActiveRecord::Migration
  def change
    create_table :hosts do |t|
      t.string :name
      t.string :ip_address
      t.integer :port

      t.timestamps
    end
  end
end
