class NewsItemsController < ApplicationController
  before_action :set_news_item, only: [:show, :edit, :update, :destroy]
  authorize_resource only: [:edit, :update, :destroy]

  # GET /news_items
  def index
    @news_items = NewsItem.all
  end

  # GET /news_items/1
  def show; end

  # GET /news_items/new
  def new
    @news_item = NewsItem.new
  end

  # GET /news_items/1/edit
  def edit; end

  # POST /news_items
  def create
    @news_item = NewsItem.new(news_item_params)

    respond_to do |format|
      if @news_item.save
        format.html { redirect_to news_items_url, notice: 'News item was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /news_items/1
  def update
    respond_to do |format|
      if @news_item.update(news_item_params)
        format.html { redirect_to news_items_url, notice: 'News item was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /news_items/1
  def destroy
    @news_item.destroy
    respond_to do |format|
      format.html { redirect_to news_items_url, notice: 'News item was successfully destroyed.' }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_news_item
    @news_item = NewsItem.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def news_item_params
    params.require(:news_item).permit(:body, :title).merge(user_id: current_user.id, timestamp: DateTime.now.in_time_zone)
  end
end
