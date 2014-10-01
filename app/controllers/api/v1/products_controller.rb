class Api::V1::ProductsController < API::V1::BaseController
  respond_to :json

  def index
    product_objects  = create_product_objects(params)

    product_objects = product_objects.partition{|product| product[:record] == nil || product[:record].variety != product[:variety]}
    suggestions = set_suggestions(product_objects)
    product_objects = product_objects[1]

    product_objects = product_objects.partition{|product| product[:record].variety == product[:variety]}
    products = product_objects[0]
    product_objects = product_objects[1]

    render json: {data: {products: products, suggestions: suggestions}}
  end

  private

  def permit_params
    params.permit(:user_id, :recording_id, :email, :state, :token) # Assuming we will get response without info wrapped in patient object
  end

  def create_product_objects(params)
    product_objects = []
    params = params.select{|key, value| key != "action" && key != "controller" && key != "format"}
    params.each do |key, value|
      product_objects << {variety: key, record: Product.find_by(name: value)}
    end
    product_objects
  end

  def set_suggestions(product_objects)
    suggestions = product_objects[0]
    suggestions.map!{|product| product[:record].nil? ? product = set_db_suggestion(product) : product = set_type_suggestion(product); product} if suggestions
  end

  def set_db_suggestion(product)
    product["issue"] = "db"
    product
  end

  def set_type_suggestion(product)
    product["issue"] = "type"
    product
  end
end