require_relative '../../../app/modules/sync.rb'
require_relative '../../rails_helper'
require_relative '../../spec_helper'

describe Sync::Cosdna::Database do
  before(:each) do
    folder_path = "/Users/WEF6/desktop/skincare-app/spec/sync_test/cosdna/"
    files_to_sync = Dir.entries("/Users/WEF6/desktop/skincare-app/spec/sync_test/cosdna").select{|file| file[/^cosmetic/]}
    @cosdna = Sync::Cosdna::Database.new(folder_path, files_to_sync)
    FactoryGirl.create(:product)
    FactoryGirl.create(:ingredient)
  end

  before(:all) do
    @ingredient_attributes = {
        name: Faker::Company.catch_phrase,
        acne: 2,
        irritant: 2,
        safety: Faker::Lorem.word,
        uv: {uba: Faker::Lorem.word, uva: Faker::Lorem.word},
        functions: [Faker::Lorem.word, Faker::Lorem.word]
      }
    @file_1 = Sync::Cosdna::File.new("/Users/WEF6/desktop/skincare-app/spec/sync_test/cosdna/cosmetic_1.html")
  end

  context "insertProduct" do
    it 'when products is not in database inserts it' do
      @cosdna.insertProduct(@file_1)
      expect(Product.all.length).to eq(2)
    end

    it 'inserts product with correct fields' do
      product = @cosdna.insertProduct(@file_1)
      expect(product.name).to eq("Shuhada Amazing Emollient Cream 30g")
      expect(product.image_cosdna).to eq(("../images/cos/5aaf145400.jpg"))
    end

    it 'when products is in database does not insert it' do
      @file_1.name = Product.first.name
      @cosdna.insertProduct(@file_1)
      expect(Product.all.length).to eq(1)
    end
  end

  context 'insertIngredient' do
    it "when ingredient is not in database inserts it" do
      @cosdna.insertIngredient(@ingredient_attributes, Product.first)
      expect(Ingredient.all.length).to eq(2)
    end

    it "when ingredient is in database does not insert it" do
      ingredient_attributes = @ingredient_attributes.dup
      ingredient_attributes[:name] = Ingredient.first.name
      @cosdna.insertIngredient(ingredient_attributes, Product.first)
      expect(Ingredient.all.length).to eq(1)
    end
  end
end

describe Sync::Cosdna::File do
  before(:all) do
    @files_to_sync = Dir.entries("/Users/WEF6/desktop/skincare-app/spec/sync_test/cosdna").select{|file| file[/^cosmetic/]}
    @file = Sync::Cosdna::File.new("/Users/WEF6/desktop/skincare-app/spec/sync_test/cosdna/" + @files_to_sync[0])
  end

  context "File" do
    it 'sets ingredient list' do
      p @file.class
      p a = File.new
      p a.class
      expect(@file.ingredient_list.length).to eq(7)
    end

    it 'sets name' do
      expect(@file.name).to eq("SHUHADA AMAZING EMOLLIENT CREAM 30g")
    end

    it 'sets image location' do
      expect(@file.image_location).to eq("../images/cos/5aaf145400.jpg")
    end
  end
end