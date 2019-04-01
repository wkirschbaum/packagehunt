class Api::PackagesController < ActionController::API
  def index
    render json: Package.search_all(params[:q])
  end
end
