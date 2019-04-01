class Api::PackagesController < ActionController::API
  def index
    render json: [{id: 1, name: 'one'}]
  end
end
