class API::V1::BaseController < ActionController::API
  require "net/http"
  include ActionController::MimeResponds
  include ActionController::StrongParameters
  include ActionController::ImplicitRender
  include ActionController::RequestForgeryProtection

  protect_from_forgery with: :null_session
  respond_to :json
  before_filter :restrict_access_by_token
  skip_before_filter :verify_authenticity_token

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found


  def record_not_found(exception)
    render json: {errors: ["That record does not exist"]}, status: 401
  end

  private

  def retrieve_url_protocol_host
    request.protocol + request.host_with_port
  end

  def restrict_access_by_token
    # @current_user = User.find_by_authentication_token(params[:token]).first
    # if @current_user.blank?
    #   render json: {errors: ['No user with that authentication token exists']}, status: 401
    # end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(user:[:email, :password]) }
  end

end