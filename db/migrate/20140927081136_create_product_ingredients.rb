class CreateProductIngredients < ActiveRecord::Migration
  def change
    create_table :product_ingredients do |t|
      t.belongs_to :product
      t.belongs_to :ingredient
      t.timestamps
    end
  end
end