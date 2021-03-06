class ArticlesController < ApplicationController

  before_action :redirect_to_login, :except => [:index, :show]

  def index
    @articles = Article.includes(:user).page(params[:page]).per(3)
  end

  def show
    @article = Article.includes(:user).find(params[:id])
  end

  def new
    @article = Article.new
    @name = current_user.name
  end

  def create
    @article = Article.new(user_id: current_user.id, title: create_params[:title], text: create_params[:text])
    if @article.save
      # create.html.erbの出力
    else
      render :new
    end
  end

  def edit
    @article = Article.find(params[:id])
    if current_user.id != @article.user_id
      redirect_to articles_path
    end

    @name = current_user.name
  end

  def update
    @article = Article.find(params[:id])
    if current_user.id != @article.user_id
      redirect_to articles_path
    end

    if @article.update(title: create_params[:title], text: create_params[:text])
      redirect_to articles_path
    else
      render :edit
    end
  end

  def destroy
    @article = Article.find(params[:id])
    if current_user.id != @article.user_id
      redirect_to articles_path
    end

    @article.destroy
    @articles = Article.page(1).per(3)
    # params[:page]に該当するパラメータの取得方法が不明かつ今回のテーマと逸れるため保留
    # destroyのルーティングに:pageを付加するのが一番早い？
  end

  def search
    @articles = Article.where('title like ?', "%#{params[:keyword]}%").order("created_at DESC").limit(20)
  end

  private
    def create_params
      params.require(:article).permit(:title, :text)
    end

    def redirect_to_login
      redirect_to new_user_session_path unless user_signed_in?
    end

end
