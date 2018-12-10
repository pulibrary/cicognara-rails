class ContributingLibrariesController < ApplicationController
  load_and_authorize_resource param_method: :contributing_library_params

  # POST /contributing_libraries
  # POST /contributing_libraries.json
  def create
    respond_to do |format|
      if @contributing_library.save
        format.html { redirect_to @contributing_library, notice: 'Contributing Library was successfully created.' }
        format.json { render :show, status: :created, location: @contributing_library }
      else
        format.html { render :new }
        format.json { render json: @contributing_library.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contributing_libraries/1
  # PATCH/PUT /contributing_libraries/1.json
  def update
    respond_to do |format|
      if @contributing_library.update(contributing_library_params)
        format.html { redirect_to @contributing_library, notice: 'Contributing Library was successfully updated.' }
        format.json { render :show, status: :ok, location: @contributing_library }
      else
        format.html { render :edit }
        format.json { render json: @contributing_library.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contributing_libraries/1
  # DELETE /contributing_libraries/1.json
  def destroy
    @contributing_library.destroy
    respond_to do |format|
      format.html { redirect_to contributing_libraries_path, notice: 'Contributing Library was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def contributing_library_params
      params.require(:contributing_library).permit(:label, :uri)
    end
end
