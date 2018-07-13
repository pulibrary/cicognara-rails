class BooksController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource only: :manifest
end
