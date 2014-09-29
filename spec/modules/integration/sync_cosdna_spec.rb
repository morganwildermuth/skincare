require_relative '../../../app/modules/sync.rb'
require_relative '../../rails_helper'
require_relative '../../spec_helper'

describe Sync::Cosdna do
  before(:all) do
    folder_path = "/Users/WEF6/desktop/skincare-app/spec/sync_test/cosdna/"
    files_to_sync = Dir.entries("/Users/WEF6/desktop/skincare-app/spec/sync_test/cosdna").select{|file| file[/^cosmetic/]}
    Sync::Cosdna::Database.new(folder_path, files_to_sync).syncFiles
    @ingredient = Ingredient.find_by(name: "Beeswax")
  end

  context "database with cosdna data" do
    it 'syncs with products' do
      expect(Product.all.length).to eq(3)
    end

    it 'syncs with ingredients' do
      expect(Ingredient.all.length).to eq(51)
    end

    it "creates associations for ingredient's products" do
      ingredient = Ingredient.find_by(name: "Water")
      expect(ingredient.products.length).to eq(2)
    end

    it "creates associations for product's ingredients" do
      product = Product.find_by(name: "Shuhada Amazing Emollient Cream 30g")
      expect(product.ingredients.length).to eq(7)
    end

    it "creates uv attributes for ingredients" do
      ingredient = Ingredient.find_by(name: "Ethylhexyl Methoxycinnamate")
      expect(ingredient.uva).to eq("1")
      expect(ingredient.uvb).to eq("3")
    end

    it "creates correct format for ingredient's functions" do
      expect(@ingredient.functions).to eq("Emollient, Emulsifier")
    end
  end
end