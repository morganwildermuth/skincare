class ChangeTypeToString < ActiveRecord::Migration
  def change
    change_column :ingredients, :acne, :string
    change_column :ingredients, :irritant, :string
  end
end