class Product < ActiveRecord::Base
  validates :name, presence: true
  validates_uniqueness_of :name

  has_many :product_ingredients
  has_many :ingredients, through: :product_ingredients

end