class BooksController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource only: :manifest

  def manifest
    @book = Book.find(params[:id])
    respond_to do |format|
      format.json { render json: IIIF::BookCollection.new(@book) }
    end
  end
end
