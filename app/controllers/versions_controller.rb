class VersionsController < ApplicationController
  load_and_authorize_resource param_method: :version_params
  before_action :set_book
  before_action :set_contributing_libraries, only: [:new, :edit]

  # POST /versions
  # POST /versions.json
  def create
    respond_to do |format|
      if @version.save
        format.html { redirect_to book_version_path(@book, @version), notice: 'Version was successfully created.' }
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
      if @version.update(version_params)
        format.html { redirect_to book_version_path(@book, @version), notice: 'Version was successfully updated.' }
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
      format.html { redirect_to book_versions_path(@book), notice: 'Version was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_book
    @book = Book.find(params[:book_id])
  end

  def set_contributing_libraries
    @contributing_libraries = ContributingLibrary.all
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def version_params
    params.require(:version).permit(:book_id, :label, :manifest, :contributing_library_id,
                                    :owner_call_number, :owner_system_number, :other_number,
                                    :version_edition_statement, :version_publication_statement,
                                    :version_publication_date, :additional_responsibility,
                                    :provenance, :physical_characteristics, :rights,
                                    :based_on_original)
  end
end
