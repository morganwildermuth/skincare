class AddCosdnaImageToProduct < ActiveRecord::Migration
  def change
    add_column(:products, :image_cosdna, :string)
  end
end
