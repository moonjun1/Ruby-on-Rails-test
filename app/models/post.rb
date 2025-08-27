class Post < ApplicationRecord
  validates :title, presence: true, length: { minimum: 1, maximum: 200 }
  validates :content, presence: true, length: { minimum: 10 }

  scope :published, -> { where(published: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :draft, -> { where(published: false) }

  # 상태 관리
  def published?
    published
  end

  def draft?
    !published
  end

  # 콘텐츠 처리 (서비스 레이어 위임)
  def markdown_content
    MarkdownRenderer.render(content)
  end

  def excerpt(limit = 150)
    MarkdownRenderer.extract_plain_text(content, limit)
  end

  # 메타데이터
  def reading_time
    # 평균 읽기 속도: 분당 200단어
    word_count = content.split.size
    minutes = (word_count / 200.0).ceil
    "#{minutes}분"
  end

  def published_at
    published? ? created_at : nil
  end
end