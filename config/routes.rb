# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

  namespace :api do
    resources :packages, only: [:index]
  end
end
