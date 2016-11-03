class EntriesController < ApplicationController
  def manifest
    @entry = Entry.where(n_value: params[:id]).first!
    respond_to do |format|
      format.json { render json: IIIF::EntryCollection.new(@entry) }
    end
  end
end
