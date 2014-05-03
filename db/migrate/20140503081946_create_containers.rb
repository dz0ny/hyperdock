class CreateContainers < ActiveRecord::Migration
  def change
    create_table :containers do |t|
      t.references :image, index: true
      t.string :status

      t.timestamps
    end
  end
end
