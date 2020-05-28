class VersionsController < ApplicationController
  def manifest
    @version = Version.find(params[:id])
    respond_to do |format|
      format.json { render json: IIIF::VersionCollection.new(@version) }
    end
  end
end
