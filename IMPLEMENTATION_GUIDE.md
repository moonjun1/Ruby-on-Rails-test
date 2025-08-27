# 🛠️ 마크다운 블로그 구현 가이드

> **Ruby Sinatra로 완전한 기능의 마크다운 블로그를 구현하는 방법**

## 📚 목차

1. [기본 구조 설계](#-기본-구조-설계)
2. [검색 기능 구현](#-검색-기능-구현)
3. [태그/카테고리 시스템](#-태그카테고리-시스템)
4. [댓글 시스템](#-댓글-시스템)
5. [실시간 미리보기](#-실시간-미리보기)
6. [UI/UX 개선](#-uiux-개선)
7. [데이터베이스 설계](#-데이터베이스-설계)

---

## 🏗️ 기본 구조 설계

### 1. **프로젝트 초기 설정**

```ruby
# encoding: utf-8
require 'sinatra'
require 'json'
require 'cgi'
require 'fileutils'

# UTF-8 인코딩 설정 (한글 지원)
if RUBY_PLATFORM =~ /mingw|mswin/
  STDOUT.set_encoding('UTF-8')
  STDERR.set_encoding('UTF-8')
end

# 서버 설정
set :port, 3000
set :bind, '0.0.0.0'
```

**💡 핵심 포인트:**
- `encoding: utf-8`로 한글 완벽 지원
- Windows 환경에서 인코딩 문제 해결
- Sinatra의 간단함을 활용한 빠른 개발

### 2. **데이터 관리 클래스 설계**

```ruby
class BlogData
  DB_FILE = 'db/posts.json'
  
  def self.init
    FileUtils.mkdir_p('db')
    unless File.exist?(DB_FILE)
      # 초기 샘플 데이터 생성
      save_posts([])
    end
  end
  
  def self.all_posts
    return [] unless File.exist?(DB_FILE)
    JSON.parse(File.read(DB_FILE, encoding: 'utf-8'))
  rescue
    []
  end
end
```

**🎯 설계 철학:**
- 간단한 JSON 파일로 빠른 프로토타이핑
- 파일 기반이므로 별도 DB 설치 불필요
- 나중에 MySQL/PostgreSQL로 쉽게 마이그레이션 가능

---

## 🔍 검색 기능 구현

### 1. **검색 로직 설계**

```ruby
def self.search_posts(query)
  return [] if query.nil? || query.strip.empty?
  query = query.downcase
  
  all_posts.select do |post|
    post['title'].downcase.include?(query) ||
    post['content'].downcase.include?(query) ||
    (post['tags'] && post['tags'].any? { |tag| tag.downcase.include?(query) }) ||
    (post['category'] && post['category'].downcase.include?(query))
  end
end
```

**🔧 구현 단계:**

#### **Step 1: 기본 검색 기능**
```ruby
# GET 라우트에서 검색 처리
get '/' do
  query = params[:search]
  
  if query && !query.strip.empty?
    @posts = BlogData.search_posts(query).select { |p| p['published'] }
  else
    @posts = BlogData.all_posts.select { |p| p['published'] }
  end
  
  @search_query = query
  erb :index
end
```

#### **Step 2: 실시간 검색 API**
```ruby
get '/api/search' do
  content_type :json
  query = params[:q]
  results = BlogData.search_posts(query).select { |p| p['published'] }
  results.to_json
end
```

#### **Step 3: 프론트엔드 검색 UI**
```html
<div class="input-group">
    <span class="input-group-text">🔍</span>
    <input type="text" class="form-control" id="search-input" 
           placeholder="제목, 내용, 태그, 카테고리 검색..."
           value="<%= @search_query %>">
    <button class="btn btn-outline-secondary" onclick="searchPosts()">검색</button>
</div>
```

#### **Step 4: JavaScript 검색 핸들러**
```javascript
function searchPosts() {
    const query = document.getElementById('search-input').value;
    if (query.trim()) {
        window.location.href = `/?search=${encodeURIComponent(query)}`;
    } else {
        window.location.href = '/';
    }
}

// 엔터 키로 검색
document.getElementById('search-input')?.addEventListener('keypress', function(e) {
    if (e.key === 'Enter') {
        searchPosts();
    }
});
```

**💡 검색 최적화 팁:**
- `downcase`로 대소문자 구분 없는 검색
- 여러 필드 동시 검색 (제목, 내용, 태그, 카테고리)
- 빈 검색어 처리로 에러 방지

---

## 🏷️ 태그/카테고리 시스템

### 1. **데이터 구조 설계**

```ruby
# 포스트 데이터 구조
{
  'id' => 1,
  'title' => '포스트 제목',
  'content' => '내용...',
  'tags' => ['Ruby', 'Sinatra', '마크다운'],    # 배열로 저장
  'category' => '개발',                        # 문자열로 저장
  'published' => true,
  'created_at' => '2025-08-27 14:30:00'
}
```

### 2. **태그/카테고리 수집 함수**

```ruby
def self.get_all_tags
  all_posts.flat_map { |p| p['tags'] || [] }.uniq.sort
end

def self.get_all_categories
  all_posts.map { |p| p['category'] }.compact.reject(&:empty?).uniq.sort
end

def self.posts_by_tag(tag)
  all_posts.select { |p| p['tags'] && p['tags'].include?(tag) }
end

def self.posts_by_category(category)
  all_posts.select { |p| p['category'] == category }
end
```

**🎯 구현 순서:**

#### **Step 1: 포스트 생성/수정 시 태그 처리**
```ruby
post '/posts' do
  tags = params[:tags] ? params[:tags].split(',').map(&:strip) : []
  category = params[:category] || ''
  
  post = BlogData.create_post(title, content, published, tags, category)
  redirect "/posts/#{post['id']}"
end
```

#### **Step 2: 필터링 라우트**
```ruby
get '/' do
  query = params[:search]
  category = params[:category]
  tag = params[:tag]
  
  @posts = BlogData.all_posts.select { |p| p['published'] }
  
  if query && !query.strip.empty?
    @posts = BlogData.search_posts(query).select { |p| p['published'] }
  elsif category && !category.empty?
    @posts = BlogData.posts_by_category(category).select { |p| p['published'] }
  elsif tag && !tag.empty?
    @posts = BlogData.posts_by_tag(tag).select { |p| p['published'] }
  end
  
  @all_tags = BlogData.get_all_tags
  @all_categories = BlogData.get_all_categories
end
```

#### **Step 3: 프론트엔드 태그 입력**
```html
<!-- 태그 입력 필드 -->
<div class="mb-3">
    <label for="tags" class="form-label">🏷️ 태그</label>
    <input type="text" class="form-control" id="tags" name="tags" 
           placeholder="태그를 쉼표로 구분해서 입력하세요 (예: Ruby, Sinatra, 마크다운)">
    <div class="form-text">태그는 쉼표(,)로 구분해서 입력하세요.</div>
</div>

<!-- 카테고리 입력 필드 -->
<div class="mb-3">
    <label for="category" class="form-label">📁 카테고리</label>
    <input type="text" class="form-control" id="category" name="category" 
           placeholder="카테고리를 입력하세요 (예: 개발, 튜토리얼, 일기)">
</div>
```

#### **Step 4: 태그 클릭 필터링**
```html
<!-- 태그 표시 및 클릭 필터링 -->
<% if @all_tags.any? %>
<div class="mb-4">
    <h6>🏷️ 태그:</h6>
    <div class="d-flex flex-wrap gap-2">
        <% @all_tags.each do |tag| %>
            <span class="badge <%= @current_tag == tag ? 'bg-primary' : 'bg-secondary' %> tag-badge" 
                  style="cursor: pointer" onclick="filterByTag('<%= tag %>')">
                #<%= tag %>
            </span>
        <% end %>
    </div>
</div>
<% end %>
```

```javascript
function filterByTag(tag) {
    window.location.href = `/?tag=${encodeURIComponent(tag)}`;
}

function filterByCategory() {
    const category = document.getElementById('category-filter').value;
    if (category) {
        window.location.href = `/?category=${encodeURIComponent(category)}`;
    } else {
        window.location.href = '/';
    }
}
```

---

## 💬 댓글 시스템

### 1. **데이터 구조 설계**

```ruby
# 포스트에 댓글 배열 추가
{
  'id' => 1,
  'title' => '포스트 제목',
  'content' => '내용...',
  'comments' => [
    {
      'id' => 1,
      'author' => '홍길동',
      'content' => '좋은 글이네요!',
      'parent_id' => nil,  # 부모 댓글 ID (답글용)
      'created_at' => '2025-08-27 14:30:00'
    },
    {
      'id' => 2,
      'author' => '김철수',
      'content' => '저도 동감합니다.',
      'parent_id' => 1,  # 1번 댓글의 답글
      'created_at' => '2025-08-27 14:35:00'
    }
  ]
}
```

### 2. **댓글 추가 함수**

```ruby
def self.add_comment(post_id, author, content, parent_id = nil)
  posts = all_posts
  post = posts.find { |p| p['id'] == post_id.to_i }
  return nil unless post
  
  post['comments'] ||= []
  comment_id = post['comments'].empty? ? 1 : post['comments'].map { |c| c['id'] }.max + 1
  
  new_comment = {
    'id' => comment_id,
    'author' => author,
    'content' => content,
    'parent_id' => parent_id,
    'created_at' => Time.now.strftime("%Y-%m-%d %H:%M:%S")
  }
  
  post['comments'] << new_comment
  save_posts(posts)
  new_comment
end
```

**🔧 구현 단계:**

#### **Step 1: 댓글 작성 라우트**
```ruby
post '/posts/:id/comments' do
  author = params[:author] || '익명'
  content = params[:comment_content]
  parent_id = params[:parent_id]&.to_i
  
  if content && !content.strip.empty?
    BlogData.add_comment(params[:id].to_i, author, content, parent_id)
  end
  
  redirect "/posts/#{params[:id]}"
end
```

#### **Step 2: 댓글 작성 폼**
```html
<!-- 댓글 작성 폼 -->
<div class="card mb-4">
    <div class="card-body">
        <h5>댓글 작성</h5>
        <form method="post" action="/posts/<%= @post['id'] %>/comments">
            <div class="mb-3">
                <label for="author" class="form-label">이름</label>
                <input type="text" class="form-control" id="author" name="author" 
                       placeholder="이름을 입력하세요 (선택사항)">
            </div>
            <div class="mb-3">
                <label for="comment_content" class="form-label">댓글 내용</label>
                <textarea class="form-control" id="comment_content" name="comment_content" 
                         rows="3" required placeholder="마크다운 문법을 지원합니다!"></textarea>
            </div>
            <button type="submit" class="btn btn-primary">댓글 작성</button>
        </form>
    </div>
</div>
```

#### **Step 3: 댓글 표시 (중첩 구조)**
```html
<!-- 댓글 목록 표시 -->
<% if @post['comments'] && @post['comments'].any? %>
    <% @post['comments'].select { |c| c['parent_id'].nil? }.each do |comment| %>
        <div class="card mb-3 comment-card">
            <div class="card-body">
                <!-- 댓글 내용 -->
                <div class="d-flex justify-content-between align-items-start">
                    <strong><%= comment['author'] || '익명' %></strong>
                    <small class="text-muted"><%= comment['created_at'] %></small>
                </div>
                <div class="mt-2 comment-content">
                    <%= SimpleMarkdown.render(comment['content']) %>
                </div>
                
                <!-- 답글 버튼 -->
                <div class="mt-2">
                    <button class="btn btn-sm btn-outline-secondary" 
                            onclick="toggleReplyForm(<%= comment['id'] %>)">
                        ↗️ 답글
                    </button>
                </div>
                
                <!-- 답글 작성 폼 (숨겨진 상태) -->
                <div id="reply-form-<%= comment['id'] %>" class="mt-3" style="display: none;">
                    <form method="post" action="/posts/<%= @post['id'] %>/comments">
                        <input type="hidden" name="parent_id" value="<%= comment['id'] %>">
                        <div class="mb-2">
                            <input type="text" class="form-control form-control-sm" 
                                   name="author" placeholder="이름 (선택사항)">
                        </div>
                        <div class="mb-2">
                            <textarea class="form-control form-control-sm" 
                                     name="comment_content" rows="2" required 
                                     placeholder="답글을 입력하세요"></textarea>
                        </div>
                        <div class="d-flex gap-2">
                            <button type="submit" class="btn btn-sm btn-primary">답글 작성</button>
                            <button type="button" class="btn btn-sm btn-secondary" 
                                    onclick="toggleReplyForm(<%= comment['id'] %>)">취소</button>
                        </div>
                    </form>
                </div>
                
                <!-- 답글 목록 표시 -->
                <% replies = @post['comments'].select { |c| c['parent_id'] == comment['id'] } %>
                <% if replies.any? %>
                    <div class="mt-3 ms-4">
                        <% replies.each do |reply| %>
                            <div class="card card-body bg-light mb-2">
                                <div class="d-flex justify-content-between align-items-start">
                                    <strong><%= reply['author'] || '익명' %></strong>
                                    <small class="text-muted"><%= reply['created_at'] %></small>
                                </div>
                                <div class="mt-1 comment-content">
                                    <%= SimpleMarkdown.render(reply['content']) %>
                                </div>
                            </div>
                        <% end %>
                    </div>
                <% end %>
            </div>
        </div>
    <% end %>
<% end %>
```

#### **Step 4: 답글 토글 JavaScript**
```javascript
function toggleReplyForm(commentId) {
    const form = document.getElementById(`reply-form-${commentId}`);
    if (form.style.display === 'none') {
        form.style.display = 'block';
    } else {
        form.style.display = 'none';
    }
}
```

---

## 🎬 실시간 미리보기

### 1. **마크다운 렌더러 구현**

```ruby
class SimpleMarkdown
  def self.render(text)
    return "" if text.nil? || text.empty?
    
    html = text.dup
    
    # 코드 블록 (```로 감싸진 부분)
    html.gsub!(/```(\w+)?\n(.*?)\n```/m) do |match|
      language = $1
      code = CGI.escapeHTML($2)
      "<div class=\"code-block\"><code>#{code}</code></div>"
    end
    
    # 인라인 코드 (`로 감싸진 부분)
    html.gsub!(/`([^`]+)`/) { "<code>#{CGI.escapeHTML($1)}</code>" }
    
    # 헤더 (# ## ###)
    html.gsub!(/^### (.+)$/, '<h3>\1</h3>')
    html.gsub!(/^## (.+)$/, '<h2>\1</h2>')
    html.gsub!(/^# (.+)$/, '<h1>\1</h1>')
    
    # 굵은 글씨 (**텍스트**)
    html.gsub!(/\*\*(.+?)\*\*/, '<strong>\1</strong>')
    
    # 기울임 (*텍스트*)
    html.gsub!(/\*(.+?)\*/, '<em>\1</em>')
    
    # 링크 [텍스트](URL)
    html.gsub!(/\[([^\]]+)\]\(([^)]+)\)/, '<a href="\2" target="_blank">\1</a>')
    
    # 인용구 (> 텍스트)
    html.gsub!(/^> (.+)$/, '<blockquote>\1</blockquote>')
    
    # 순서 없는 목록 (- 항목)
    html.gsub!(/^- (.+)$/, '<li>\1</li>')
    html.gsub!(/<li>.*<\/li>/m) { |list| "<ul>#{list}</ul>" }
    
    # 줄바꿈
    html.gsub!(/\n/, '<br>')
    
    html
  end
  
  def self.extract_text(markdown)
    # 마크다운에서 텍스트만 추출 (미리보기용)
    text = markdown.gsub(/```.*?```/m, '[코드]')
    text = text.gsub(/`[^`]+`/, '[코드]')
    text = text.gsub(/[#*>-]/, '').strip
    text[0..150] + (text.length > 150 ? '...' : '')
  end
end
```

### 2. **실시간 미리보기 API**

```ruby
get '/api/preview' do
  content_type :json
  markdown = params[:content] || ""
  html = SimpleMarkdown.render(markdown)
  { html: html }.to_json
end
```

### 3. **프론트엔드 실시간 업데이트**

```javascript
// 실시간 미리보기
document.getElementById('content').addEventListener('input', function() {
    const content = this.value;
    
    // 디바운싱 (너무 자주 요청하지 않도록)
    clearTimeout(this.previewTimeout);
    this.previewTimeout = setTimeout(() => {
        fetch('/api/preview?content=' + encodeURIComponent(content))
            .then(response => response.json())
            .then(data => {
                document.getElementById('preview').innerHTML = 
                    data.html || '미리보기가 여기에 표시됩니다...';
            })
            .catch(error => {
                document.getElementById('preview').innerHTML = '미리보기 로드 중...';
            });
    }, 300); // 300ms 지연
});
```

---

## 🎨 UI/UX 개선

### 1. **반응형 에디터 레이아웃**

```css
.editor-container { 
    display: flex; 
    gap: 1rem; 
}

.editor-half { 
    flex: 1; 
}

.preview-pane {
    border: 1px solid #dee2e6;
    border-radius: 0.375rem;
    padding: 1rem;
    min-height: 400px;
    background: #fff;
    overflow-y: auto;
}

@media (max-width: 768px) {
    .editor-container { 
        flex-direction: column; 
    }
    
    .preview-pane {
        min-height: 200px;
    }
}
```

### 2. **한글 폰트 최적화**

```css
body { 
    font-family: 'Noto Sans KR', sans-serif; 
}

.code-block { 
    font-family: 'Cascadia Code', 'Fira Code', 'Consolas', monospace;
    background: #f8f9fa; 
    padding: 1rem; 
    border-radius: 0.375rem; 
    margin: 1rem 0;
    overflow-x: auto;
}

code:not(.code-block code) { 
    background: #f8f9fa; 
    padding: 0.2rem 0.4rem; 
    border-radius: 0.25rem;
    color: #e83e8c;
    font-family: 'Cascadia Code', 'Fira Code', 'Consolas', monospace;
}
```

### 3. **상태 표시 및 피드백**

```html
<!-- 댓글 수 배지 -->
<% if post['comments'] && post['comments'].any? %>
    <span class="badge bg-success ms-2">💬 <%= post['comments'].length %></span>
<% end %>

<!-- 태그 표시 -->
<% if post['tags'] && post['tags'].any? %>
    <div class="mb-2">
        <% post['tags'].each do |tag| %>
            <span class="badge bg-secondary me-1">#<%= tag %></span>
        <% end %>
    </div>
<% end %>

<!-- 카테고리 배지 -->
<% if post['category'] && !post['category'].empty? %>
    <span class="badge bg-info">📁 <%= post['category'] %></span>
<% end %>
```

---

## 💾 데이터베이스 설계

### 1. **JSON 파일 구조**

```json
[
  {
    "id": 1,
    "title": "첫 번째 포스트",
    "content": "# 안녕하세요\n\n**마크다운** 블로그입니다.",
    "published": true,
    "tags": ["Ruby", "Sinatra", "마크다운"],
    "category": "개발",
    "comments": [
      {
        "id": 1,
        "author": "홍길동",
        "content": "좋은 글이네요!",
        "parent_id": null,
        "created_at": "2025-08-27 14:30:00"
      }
    ],
    "created_at": "2025-08-27 14:00:00",
    "updated_at": "2025-08-27 14:00:00"
  }
]
```

### 2. **데이터 무결성 보장**

```ruby
def self.create_post(title, content, published = false, tags = [], category = '')
  posts = all_posts
  new_id = posts.empty? ? 1 : posts.map { |p| p['id'] }.max + 1
  
  new_post = {
    'id' => new_id,
    'title' => title.to_s.strip,
    'content' => content.to_s,
    'published' => !!published,
    'tags' => (tags || []).map(&:strip).reject(&:empty?),
    'category' => (category || '').strip,
    'comments' => [],
    'created_at' => Time.now.strftime("%Y-%m-%d %H:%M:%S"),
    'updated_at' => Time.now.strftime("%Y-%m-%d %H:%M:%S")
  }
  
  posts << new_post
  save_posts(posts)
  new_post
end

def self.save_posts(posts)
  # 원자적 쓰기 (임시 파일 사용)
  temp_file = "#{DB_FILE}.tmp"
  File.write(temp_file, JSON.pretty_generate(posts), encoding: 'utf-8')
  File.rename(temp_file, DB_FILE)
end
```

### 3. **마이그레이션 준비**

```ruby
# 나중에 MySQL/PostgreSQL로 마이그레이션할 때를 위한 구조
class Post
  def self.create(attributes)
    # ActiveRecord 스타일로 변환 가능
    BlogData.create_post(
      attributes[:title],
      attributes[:content],
      attributes[:published],
      attributes[:tags],
      attributes[:category]
    )
  end
end
```

---

## 🚀 배포 및 최적화

### 1. **성능 최적화**

```ruby
# 캐싱 추가
require 'digest'

class BlogData
  @cache = {}
  
  def self.all_posts_cached
    file_hash = Digest::MD5.hexdigest(File.read(DB_FILE)) if File.exist?(DB_FILE)
    
    if @cache[:posts_hash] != file_hash
      @cache[:posts] = all_posts
      @cache[:posts_hash] = file_hash
    end
    
    @cache[:posts] || []
  end
end
```

### 2. **에러 처리**

```ruby
# 전역 에러 핸들러
error do
  @error = env['sinatra.error']
  erb :error
end

# 404 처리
not_found do
  erb :not_found
end
```

### 3. **보안 강화**

```ruby
# HTML 이스케이프
helpers do
  def h(text)
    CGI.escapeHTML(text.to_s)
  end
end

# XSS 방지
def self.render(text)
  # 사용자 입력 sanitize
  text = CGI.escapeHTML(text) if text
  # 마크다운 렌더링...
end
```

---

## 📈 확장 아이디어

### 1. **이미지 업로드**
- 드래그&드롭 인터페이스
- 이미지 리사이징
- 클라우드 스토리지 연동

### 2. **사용자 인증**
- 세션 관리
- 관리자/일반 사용자 구분
- OAuth 연동

### 3. **SEO 최적화**
- 메타 태그 자동 생성
- 사이트맵 생성
- RSS 피드

### 4. **분석 도구**
- 방문자 통계
- 인기 포스트 분석
- 검색 키워드 분석

---

**🎉 이 가이드를 따라하면 완전한 기능의 마크다운 블로그를 구현할 수 있습니다!**

각 단계별로 코드를 작성하고 테스트하면서 점진적으로 기능을 추가해나가세요. 🚀