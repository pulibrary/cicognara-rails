class CommentsController < ApplicationController
  before_action :set_comment, only: [:edit, :update, :destroy]
  authorize_resource only: [:edit, :update, :destroy]

  # GET /comments/1/edit
  def edit; end

  # POST /comments
  def create
    @comment = Comment.new(comment_params)

    respond_to do |format|
      if @comment.save
        format.html { redirect_to solr_document_path(@comment.entry_id), notice: 'Comment added.' }
      else
        format.html { redirect_to solr_document_path(@comment.entry_id), warning: 'Error adding comment.' }
      end
    end
  end

  # PATCH/PUT /comments/1
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to solr_document_path(@comment.entry_id), notice: 'Comment updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /comments/1
  def destroy
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to solr_document_path(@comment.entry_id), notice: 'Comment deleted.' }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:text, :entry_id).merge(user_id: current_user.id, timestamp: DateTime.now.in_time_zone)
    end
end
