require_relative '../models/simple_post'

class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts
  def index
    @posts = SimplePost.published_recent
    @draft_posts = SimplePost.draft if show_drafts?
  end

  # GET /posts/:id
  def show
    unless @post.published? || show_drafts?
      redirect_to posts_path, alert: '존재하지 않는 포스트입니다.'
      return
    end
  end

  # GET /posts/new
  def new
    @post = SimplePost.new
  end

  # POST /posts
  def create
    @post = SimplePost.new(post_params)
    
    if @post.save
      redirect_to @post, notice: '포스트가 성공적으로 생성되었습니다.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /posts/:id/edit
  def edit
  end

  # PATCH/PUT /posts/:id
  def update
    if @post.update(post_params)
      redirect_to @post, notice: '포스트가 성공적으로 업데이트되었습니다.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /posts/:id
  def destroy
    @post.destroy
    redirect_to posts_path, notice: '포스트가 삭제되었습니다.'
  end

  # PATCH /posts/:id/publish
  def publish
    @post = SimplePost.find(params[:id])
    @post.update(published: !@post.published?)
    
    status = @post.published? ? '발행' : '비공개'
    redirect_to @post, notice: "포스트가 #{status}되었습니다."
  end

  private

  def set_post
    @post = SimplePost.find(params[:id])
    unless @post
      redirect_to posts_path, alert: '포스트를 찾을 수 없습니다.'
    end
  end

  def post_params
    params.require(:post).permit(:title, :content, :published)
  end

  def show_drafts?
    # 개발 환경에서는 초안도 볼 수 있도록 허용
    Rails.env.development? || params[:preview] == 'true'
  end
end