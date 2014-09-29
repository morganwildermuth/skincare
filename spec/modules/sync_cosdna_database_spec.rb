require_relative '../../app/modules/sync.rb'
require 'rails_helper'
require 'spec_helper'

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

  context "syncFiles" do
    it 'sets files correctly' do
      @cosdna.syncFiles
      expect(@cosdna.files.length).to eq(2)
    end
  end

  context "insertProduct" do
    it 'when products is not in database inserts it' do
      @cosdna.insertProduct(@file_1)
      expect(Product.all.length).to eq(2)
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
    end
  end
end