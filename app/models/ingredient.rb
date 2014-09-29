class Ingredient < ActiveRecord::Base
  validates :name, presence: true
  validates_uniqueness_of :name

  has_many :product_ingredients
  has_many :products, through: :product_ingredients

end