class Api::PackagesController < ActionController::API
  def index
    render json: ['one', 'two']
  end
end
