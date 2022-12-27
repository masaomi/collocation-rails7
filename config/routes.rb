Rails.application.routes.draw do
  resources :jobs
  post 'jobs/run', to: 'jobs#run'

  get 'home/index'
  get 'job/result/:id', to: 'jobs#result'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "home#index"
end
