class VersionsController < ApplicationController
  load_and_authorize_resource param_method: :version_params
  # before_action :set_book, only: :new
  before_action :set_volume, only: :new
  # before_action :set_contributing_libraries, only: [:new, :edit]
  helper_method :contributing_libraries
  helper_method :version_iiif_manifest_link

  def index
    @versions = Version.where(book_id: params[:book_id])
  end

  # POST /versions
  # POST /versions.json
  def create
    @version.volume_id = volume.id
    respond_to do |format|
      if @version.save
        format.html { redirect_to book_volume_version_path(volume.book, volume, @version), notice: 'Version was successfully created.' }
        format.json { render :show, status: :created, location: @version }
      else
        format.html { render :new }
        format.json { render json: @version.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /versions/1
  # PATCH/PUT /versions/1.json
  def update
    respond_to do |format|
      if @version.update(version_params_with_volume)
        format.html { redirect_to book_volume_version_path(volume.book, volume, @version), notice: 'Version was successfully updated.' }
        format.json { render :show, status: :ok, location: @version }
      else
        format.html { render :edit }
        format.json { render json: @version.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /versions/1
  # DELETE /versions/1.json
  def destroy
    @version.destroy
    respond_to do |format|
      format.html { redirect_to book_path(volume.book), notice: 'Version was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def contributing_libraries
    @contributing_libraries ||= ContributingLibrary.all.to_a
  end

  def iiif_manifests
    @iiif_manifests ||= IIIF::Manifest.all.to_a
  end

  def version_iiif_manifest_link(options = nil, html_options = nil)
    return if version.iiif_manifest.nil?
    @version_iiif_manifest_link ||= link_to(nil, version.iiif_manifest.uri, options, html_options)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def volume
    @volume ||= Volume.find(params[:volume_id])
  end

  def set_volume
    @version.volume = volume
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def version_params
    params.require(:version).permit(
      :volume_id,
      :label,
      :iiif_manifest_id,
      :contributing_library_id,
      :owner_call_number,
      :owner_system_number,
      :other_number,
      :version_edition_statement,
      :version_publication_statement,
      :version_publication_date,
      :additional_responsibility,
      :provenance,
      :physical_characteristics,
      :rights,
      :based_on_original
    )
  end

  def version_params_with_volume
    version_params.merge(volume_id: volume.id)
  end
end
