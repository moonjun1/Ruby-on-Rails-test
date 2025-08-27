#!/usr/bin/env ruby

require 'sqlite3'
require 'fileutils'

# db 디렉토리 생성
FileUtils.mkdir_p('db')

# SQLite 데이터베이스 생성
db = SQLite3::Database.new('db/development.sqlite3')

# posts 테이블 생성
db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS posts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    published BOOLEAN DEFAULT 0 NOT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL
  );
SQL

# 인덱스 생성
db.execute "CREATE INDEX IF NOT EXISTS index_posts_on_published ON posts(published);"
db.execute "CREATE INDEX IF NOT EXISTS index_posts_on_created_at ON posts(created_at);"
db.execute "CREATE INDEX IF NOT EXISTS index_posts_on_published_and_created_at ON posts(published, created_at);"

puts "✅ 데이터베이스 생성 완료!"

# 샘플 데이터 생성
sample_posts = [
  {
    title: "🚀 마크다운 블로그에 오신 것을 환영합니다!",
    content: "# 안녕하세요! 👋\n\n**마크다운 블로그**에 오신 것을 환영합니다. 이 블로그는 Ruby on Rails로 만들어졌으며, 마크다운 문법을 완벽하게 지원합니다.\n\n## 🎯 주요 기능들\n\n### ✍️ 마크다운 지원\n- **굵은 글씨**와 *기울임 글씨*\n- `인라인 코드` 지원\n- 코드 블록 문법 하이라이팅\n\n### 📝 콘텐츠 관리\n- 포스트 작성, 수정, 삭제\n- 초안/발행 상태 관리  \n- 자동 읽기 시간 계산\n\n## 💻 코드 예제\n\nRuby 코드도 아름답게 표시됩니다:\n\n```ruby\nclass Post < ApplicationRecord\n  validates :title, presence: true\n  validates :content, presence: true\n\n  scope :published, -> { where(published: true) }\n  \n  def markdown_content\n    MarkdownRenderer.render(content)\n  end\nend\n```",
    published: 1,
    created_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
    updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S")
  },
  {
    title: "📚 마크다운 문법 완벽 가이드",
    content: "# 마크다운 문법 가이드 📖\n\n마크다운은 간단한 텍스트 기반 마크업 언어입니다.\n\n## 텍스트 스타일링\n\n- **굵은 글씨** (`**굵은 글씨**`)\n- *기울임 글씨* (`*기울임 글씨*`)\n- `인라인 코드` (백틱으로 감쌈)\n\n## 리스트\n\n### 순서 없는 리스트\n- 항목 1\n- 항목 2\n  - 하위 항목 1\n  - 하위 항목 2\n\n### 순서 있는 리스트\n1. 첫 번째\n2. 두 번째  \n3. 세 번째\n\n## 코드 블록\n\n```javascript\nfunction greetUser(name) {\n  console.log(`안녕하세요, ${name}님!`);\n  return `환영합니다! 🎉`;\n}\n\ngreetUser(\"개발자\");\n```\n\n## 인용구\n\n> \"좋은 코드는 그 자체로 최고의 문서다.\"  \n> — 로버트 C. 마틴\n\n이제 마크다운으로 아름다운 포스트를 작성해보세요! 🚀",
    published: 1,
    created_at: (Time.now - 3600).strftime("%Y-%m-%d %H:%M:%S"),
    updated_at: (Time.now - 3600).strftime("%Y-%m-%d %H:%M:%S")
  },
  {
    title: "🛠️ Rails 개발 환경 설정하기",
    content: "# Ruby on Rails 개발 환경 설정\n\n이 포스트에서는 Ruby on Rails 개발 환경을 처음부터 설정하는 방법을 알아보겠습니다.\n\n## 1. Ruby 설치\n\n### Windows (RubyInstaller 사용)\n1. [RubyInstaller](https://rubyinstaller.org/) 사이트 방문\n2. Ruby+Devkit 버전 다운로드\n3. 설치 프로그램 실행\n\n## 2. Rails 설치\n\n```bash\ngem install rails\nrails --version\n```\n\n## 3. 새 Rails 프로젝트 생성\n\n```bash\nrails new my_blog --database=sqlite3\ncd my_blog\n```\n\nHappy coding! 🚀",
    published: 0,
    created_at: (Time.now - 7200).strftime("%Y-%m-%d %H:%M:%S"),
    updated_at: (Time.now - 7200).strftime("%Y-%m-%d %H:%M:%S")
  }
]

# 샘플 데이터 삽입
sample_posts.each_with_index do |post, index|
  db.execute(
    "INSERT INTO posts (title, content, published, created_at, updated_at) VALUES (?, ?, ?, ?, ?)",
    [post[:title], post[:content], post[:published], post[:created_at], post[:updated_at]]
  )
  puts "#{index + 1}. 📝 '#{post[:title]}' 생성 완료"
end

db.close
puts "\n🎉 샘플 데이터 생성 완료!"
puts "총 #{sample_posts.length}개의 포스트가 생성되었습니다."