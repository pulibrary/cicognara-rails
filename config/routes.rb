Rails.application.routes.draw do
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  resources :books, only: [:index, :show] do
    resources :versions, except: :index
  end
  resources :contributing_libraries
  require 'sidekiq/web'
  if Rails.env.development?
    mount Sidekiq::Web => '/sidekiq'
  else
    authenticate :user do
      mount Sidekiq::Web => '/sidekiq'
    end
  end

  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'

  concern :marc_viewable, Blacklight::Marc::Routes::MarcViewable.new

  root to: 'high_voltage/pages#show', id: 'home'
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
  end

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    get 'users/auth/google_oauth2', to: 'users/omniauth_callbacks#passthru', as: :new_user_session
    get 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end
  resources :users
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns [:exportable, :marc_viewable]
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  resources :comments, only: [:create, :edit, :update, :destroy]
  resources :news_items

  get '/404', to: 'errors#not_found', via: :all
  get '/500', to: 'errors#internal_server_error', via: :all

  get '/catalogo' => 'high_voltage/pages#show', as: :browse_catalogo, id: 'catalogo/section_1.1'
  get '/*id' => 'high_voltage/pages#show', as: :static_page, format: false

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
