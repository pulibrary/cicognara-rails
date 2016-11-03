class BooksController < ApplicationController
  load_and_authorize_resource

  def manifest
    @book = Book.find(params[:id])
    respond_to do |format|
      format.json { render json: IIIF::BookCollection.new(@book) }
    end
  end
end
