class CreateIngredients < ActiveRecord::Migration
  def change
    create_table :ingredients do |t|
      t.string :name
      t.integer :acne
      t.integer :irritant
      t.integer :safety
      t.string :uva
      t.string :uvb
      t.string :functions
      t.timestamps
    end
  end
end