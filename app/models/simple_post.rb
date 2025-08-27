# 파일 기반 Post 모델 (ActiveRecord 대신)
require_relative 'file_db'
require_relative '../services/markdown_renderer'

class SimplePost
  attr_accessor :id, :title, :content, :published, :created_at, :updated_at
  
  def initialize(attributes = {})
    @id = attributes['id'] || attributes[:id]
    @title = attributes['title'] || attributes[:title]
    @content = attributes['content'] || attributes[:content]
    @published = attributes['published'] || attributes[:published] || false
    @created_at = attributes['created_at'] || attributes[:created_at]
    @updated_at = attributes['updated_at'] || attributes[:updated_at]
  end
  
  # 클래스 메서드들
  def self.all
    FileDB.all_posts.map { |post| new(post) }
  end
  
  def self.published
    FileDB.published_posts.map { |post| new(post) }
  end
  
  def self.recent
    all.sort_by { |post| Time.parse(post.created_at) }.reverse
  end
  
  def self.published_recent
    published.sort_by { |post| Time.parse(post.created_at) }.reverse
  end
  
  def self.draft
    all.select { |post| !post.published }
  end
  
  def self.find(id)
    post_data = FileDB.find_post(id)
    post_data ? new(post_data) : nil
  end
  
  def self.create(attributes)
    post_data = FileDB.create_post(attributes)
    new(post_data)
  end
  
  # 인스턴스 메서드들
  def save
    if @id
      FileDB.update_post(@id, {
        title: @title,
        content: @content,
        published: @published
      })
    else
      post_data = FileDB.create_post({
        title: @title,
        content: @content,
        published: @published
      })
      @id = post_data['id']
      @created_at = post_data['created_at']
      @updated_at = post_data['updated_at']
    end
    true
  end
  
  def update(attributes)
    @title = attributes[:title] if attributes[:title]
    @content = attributes[:content] if attributes[:content]
    @published = attributes[:published] if attributes.key?(:published)
    
    if @id
      FileDB.update_post(@id, attributes)
      @updated_at = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    end
    true
  end
  
  def destroy
    FileDB.delete_post(@id) if @id
    true
  end
  
  # 상태 관리
  def published?
    @published
  end

  def draft?
    !@published
  end

  # 콘텐츠 처리
  def markdown_content
    MarkdownRenderer.render(@content)
  end

  def excerpt(limit = 150)
    MarkdownRenderer.extract_plain_text(@content, limit)
  end

  # 메타데이터
  def reading_time
    word_count = @content.split.size
    minutes = (word_count / 200.0).ceil
    "#{minutes}분"
  end

  def published_at
    published? ? @created_at : nil
  end
  
  def to_param
    @id.to_s
  end
  
  # 검증
  def valid?
    errors.empty?
  end
  
  def errors
    @errors ||= {}
    @errors.clear
    
    @errors[:title] = ["can't be blank"] if @title.nil? || @title.empty?
    @errors[:title] = ["is too long (maximum 200 characters)"] if @title && @title.length > 200
    @errors[:content] = ["can't be blank"] if @content.nil? || @content.empty?
    @errors[:content] = ["is too short (minimum 10 characters)"] if @content && @content.length < 10
    
    @errors
  end
end