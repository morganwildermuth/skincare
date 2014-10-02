class Api::V1::ProductsController < API::V1::BaseController
  respond_to :json

  def index
    search_object = SearchObjectFactory::SearchObject.new(params)

    render json: {data: {products: search_object.product_objects, suggestions: search_object.suggestion_objects}}
  end

  private

  def permit_params
    params.permit(:user_id, :recording_id, :email, :state, :token) # Assuming we will get response without info wrapped in patient object
  end
end