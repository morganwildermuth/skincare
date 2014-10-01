require '../../../rails_helper'

describe "API V1 Product", :type => :request do

  before(:all) do
    @product_not_in_search = "Frankenstein"
    @product_not_in_database = "Cerave"
    @product_not_in_database_two = "Cerave Foaming Cleanser"
  end

  before(:each) do
    @product = FactoryGirl.create(:product)
    @product_two = FactoryGirl.create(:product)
    @product_two.update_attribute("name", Faker::Lorem.word.capitalize)
  end

  it 'returns indidual product in database with one word name and correct type' do
    get "/api/v1/products?cleanser=" + @product_two.name
    @response = JSON.parse(response.body)
    expect(@response["data"]["products"].length).to eq(1)
  end

  it 'returns indidual product in database with two word name and correct type' do
    get "/api/v1/products?cleanser=" + @product.name.split(" ").join("+")
    @response = JSON.parse(response.body)
    expect(@response["data"]["products"].length).to eq(1)
  end

  it 'does not return indidual product in database with one word name and incorrect type' do
    get "/api/v1/products?toner=" + @product.name.split(" ").join("+")
    @response = JSON.parse(response.body)
    expect(@response["data"]["suggestions"].length).to eq(1)
    expect(@response["data"]["suggestions"][0]["record"]["name"]).to eq(@product.name)
  end

  it 'does not return indidual product in database with two word name and incorrect type' do
    get "/api/v1/products?toner=" + @product_two.name
    @response = JSON.parse(response.body)
    expect(@response["data"]["suggestions"].length).to eq(1)
    expect(@response["data"]["suggestions"][0]["record"]["name"]).to eq(@product_two.name)
  end

  it 'specifies correct issues when issue is incorrect type of product in database' do
    get "/api/v1/products?toner=" + @product.name.split(" ").join("+")
    @response = JSON.parse(response.body)
    expect(@response["data"]["suggestions"][0]["issue"]).to eq("type")
  end

  it 'returns individual product not in database with one word name' do
    get "/api/v1/products?cleanser=" + @product_not_in_database
    @response = JSON.parse(response.body)
    expect(@response["data"]["suggestions"].length).to eq(1)
  end

  it 'returns indidual product not in database with two word name' do
    get "/api/v1/products?cleanser=" + @product_not_in_database_two.split(" ").join("+")
    @response = JSON.parse(response.body)
    expect(@response["data"]["suggestions"].length).to eq(1)
  end

  it 'specifies correct issues when issue is product was not in database' do
    get "/api/v1/products?toner=" + @product_not_in_database
    @response = JSON.parse(response.body)
    expect(@response["data"]["suggestions"][0]["issue"]).to eq("db")
  end

  it 'returns correct error when product is neither in database or in the search outside the database' do
    get "/api/v1/products?cleanser=" + @product_not_in_search
    @response = JSON.parse(response.body)
    expect(@response["errors"].length).to eq(1)
  end

  # it 'returns several products in database with correct types' do
  #   get "/api/v1/products?cleanser=" + @product.name.split(" ").join("+") + "&cleanser=" + @product_two.name
  #   @response = JSON.parse(response.body)
  #   expect(@response["data"]["products"].length).to eq(2)
  # end

  # it 'returns several products in database with mix of correct and incorrect types' do
  #   get "/api/v1/products?cleanser=" + @product.name.split(" ").join("+") + "&toner=" + @product_two.name
  #   @response = JSON.parse(response.body)
  #   expect(@response["data"]["products"].length).to eq(1)
  #   expect(@response["data"]["suggestions"].length).to eq(1)
  # end

  # it 'returns several products not in database' do
  #   get "/api/v1/products?cleanser=" + @product_not_in_database_two.split(" ").join("+") + "&toner=" + @product_not_in_database
  #   @response = JSON.parse(response.body)
  #   expect(@response["data"]["suggestions"].length).to eq(2)
  # end

  # it 'returns mix of products, both in (with correct type) and not in database' do
  #   get "/api/v1/products?cleanser=" + @product_not_in_database_two.split(" ").join("+") + "&cleanser=" + @product_two.name
  #   @response = JSON.parse(response.body)
  #   expect(@response["data"]["products"].length).to eq(1)
  #   expect(@response["data"]["suggestions"].length).to eq(1)
  # end

  # it 'returns mix of products, both in and not in database and of correct and incorrect types' do
  #   get "/api/v1/products?cleanser=" + @product.name.split(" ").join("+") + "&toner=" + @product_two.name + "&cleanser=" + @product_not_in_database_two.split(" ").join("+") + "&toner=" + @product_not_in_database
  #   @response = JSON.parse(response.body)
  #   expect(@response["data"]["products"].length).to eq(1)
  #   expect(@response["data"]["suggestions"].length).to eq(3)
  # end
end