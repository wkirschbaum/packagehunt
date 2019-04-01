class Api::PackagesController < ActionController::API
  def index
    render json: Package.includes(:project).all
  end
end
