class ChangeProductTypeName < ActiveRecord::Migration
  def change
    rename_column :products, :type, :variety
  end
end
