class API::V1::ProductController < API::BaseController
  respond_to :json

  def index
    render json: {fact: "index"}, status: 200
  end

  private

  def permit_params
    params.permit(:user_id, :recording_id, :email, :state, :token) # Assuming we will get response without info wrapped in patient object
  end
end