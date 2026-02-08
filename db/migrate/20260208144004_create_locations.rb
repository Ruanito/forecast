class CreateLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :locations do |t|
      t.string :zipcode
      t.decimal :lat
      t.decimal :lng

      t.timestamps
    end
    add_index :locations, :zipcode, unique: true
  end
end
