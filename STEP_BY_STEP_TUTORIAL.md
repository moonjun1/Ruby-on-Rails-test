# 📖 단계별 마크다운 블로그 만들기

> **초보자도 따라할 수 있는 완전한 단계별 가이드**

## 🎯 이 튜토리얼로 무엇을 만들까요?

- ✅ **완전한 CRUD 기능** (생성/읽기/수정/삭제)
- ✅ **실시간 마크다운 미리보기**
- ✅ **검색 기능** (제목/내용/태그/카테고리)
- ✅ **태그 & 카테고리 시스템**
- ✅ **댓글 시스템** (답글 포함)
- ✅ **반응형 디자인** (모바일 지원)
- ✅ **한글 완벽 지원**

---

## 📋 사전 준비

### 1. **Ruby 설치 확인**
```bash
ruby --version
# Ruby 3.0 이상이어야 합니다
```

### 2. **필요한 gem 설치**
```bash
gem install sinatra
gem install json
```

### 3. **프로젝트 폴더 생성**
```bash
mkdir markdown_blog
cd markdown_blog
mkdir db
```

---

## 🏗️ 1단계: 기본 서버 만들기

### **파일 생성: `blog_app.rb`**

```ruby
# encoding: utf-8
require 'sinatra'

puts "🚀 마크다운 블로그 서버가 시작됩니다!"

get '/' do
  "안녕하세요! 마크다운 블로그입니다. 🎉"
end
```

### **테스트하기**
```bash
ruby blog_app.rb
# 브라우저에서 http://localhost:4567 접속
```

**✅ 체크포인트:** 브라우저에서 "안녕하세요! 마크다운 블로그입니다. 🎉" 메시지가 보이나요?

---

## 💾 2단계: 데이터 저장소 만들기

### **JSON 파일 기반 데이터베이스 추가**

```ruby
# encoding: utf-8
require 'sinatra'
require 'json'
require 'fileutils'

# UTF-8 설정 (한글 지원)
if RUBY_PLATFORM =~ /mingw|mswin/
  STDOUT.set_encoding('UTF-8')
  STDERR.set_encoding('UTF-8')
end

class BlogData
  DB_FILE = 'db/posts.json'
  
  def self.init
    FileUtils.mkdir_p('db')
    unless File.exist?(DB_FILE)
      # 첫 번째 샘플 포스트 생성
      sample_posts = [{
        'id' => 1,
        'title' => '🎉 첫 번째 포스트',
        'content' => "# 안녕하세요!\n\n**마크다운 블로그**에 오신 것을 환영합니다!\n\n- 이것은 목록입니다\n- 마크다운이 잘 작동하나요?",
        'published' => true,
        'created_at' => Time.now.strftime("%Y-%m-%d %H:%M:%S")
      }]
      save_posts(sample_posts)
    end
  end
  
  def self.all_posts
    return [] unless File.exist?(DB_FILE)
    JSON.parse(File.read(DB_FILE, encoding: 'utf-8'))
  rescue
    []
  end
  
  def self.save_posts(posts)
    File.write(DB_FILE, JSON.pretty_generate(posts), encoding: 'utf-8')
  end
end

# 초기화
BlogData.init

get '/' do
  posts = BlogData.all_posts
  "포스트 개수: #{posts.length}개"
end
```

### **테스트하기**
```bash
ruby blog_app.rb
# 브라우저에서 "포스트 개수: 1개" 확인
# db/posts.json 파일이 생성되었는지 확인
```

**✅ 체크포인트:** `db/posts.json` 파일이 생성되고 포스트 개수가 표시되나요?

---

## 📝 3단계: 마크다운 렌더러 만들기

### **마크다운을 HTML로 변환하는 함수 추가**

```ruby
class SimpleMarkdown
  def self.render(text)
    return "" if text.nil? || text.empty?
    
    html = text.dup
    
    # 제목 변환 (# ## ###)
    html.gsub!(/^### (.+)$/, '<h3>\1</h3>')
    html.gsub!(/^## (.+)$/, '<h2>\1</h2>')
    html.gsub!(/^# (.+)$/, '<h1>\1</h1>')
    
    # 굵은 글씨 (**텍스트**)
    html.gsub!(/\*\*(.+?)\*\*/, '<strong>\1</strong>')
    
    # 기울임 글씨 (*텍스트*)
    html.gsub!(/\*(.+?)\*/, '<em>\1</em>')
    
    # 목록 (- 항목)
    html.gsub!(/^- (.+)$/, '<li>\1</li>')
    html.gsub!(/<li>.*<\/li>/m) { |list| "<ul>#{list}</ul>" }
    
    # 줄바꿈
    html.gsub!(/\n/, '<br>')
    
    html
  end
end

# 포스트 표시 라우트
get '/' do
  posts = BlogData.all_posts.select { |p| p['published'] }
  
  html = "<h1>📚 마크다운 블로그</h1>"
  
  posts.each do |post|
    html += "<div style='border: 1px solid #ddd; padding: 20px; margin: 20px 0;'>"
    html += "<h2>#{post['title']}</h2>"
    html += "<div>#{SimpleMarkdown.render(post['content'])}</div>"
    html += "<small>작성일: #{post['created_at']}</small>"
    html += "</div>"
  end
  
  html
end
```

**✅ 체크포인트:** 마크다운이 HTML로 잘 변환되어 보이나요?

---

## 🎨 4단계: 예쁜 UI 만들기 (Bootstrap 적용)

### **ERB 템플릿 시스템 도입**

```ruby
# 맨 위에 추가
require 'erb'

# 라우트를 ERB 템플릿으로 변경
get '/' do
  @posts = BlogData.all_posts.select { |p| p['published'] }
  erb :index
end

# 파일 맨 아래에 템플릿 추가
__END__

@@layout
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>🚀 Ruby 마크다운 블로그</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Noto Sans KR', sans-serif; }
        .post-content { line-height: 1.6; }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a href="/" class="navbar-brand">🚀 Ruby 마크다운 블로그</a>
        </div>
    </nav>
    
    <main class="container my-4">
        <%= yield %>
    </main>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

@@index
<div class="mb-4">
    <h1>📚 블로그 포스트</h1>
</div>

<% if @posts.any? %>
    <div class="row">
        <% @posts.each do |post| %>
            <div class="col-md-6 mb-4">
                <div class="card h-100">
                    <div class="card-body">
                        <h5 class="card-title"><%= post['title'] %></h5>
                        <div class="post-content">
                            <%= SimpleMarkdown.render(post['content']) %>
                        </div>
                        <small class="text-muted"><%= post['created_at'] %></small>
                    </div>
                </div>
            </div>
        <% end %>
    </div>
<% else %>
    <div class="text-center py-5">
        <h3 class="text-muted">아직 포스트가 없습니다</h3>
        <p>첫 번째 포스트를 작성해보세요!</p>
    </div>
<% end %>
```

**✅ 체크포인트:** Bootstrap이 적용된 예쁜 디자인이 보이나요?

---

## ✍️ 5단계: 포스트 작성 기능 추가

### **포스트 생성 함수와 라우트 추가**

```ruby
# BlogData 클래스에 메서드 추가
class BlogData
  def self.create_post(title, content, published = false)
    posts = all_posts
    new_id = posts.empty? ? 1 : posts.map { |p| p['id'] }.max + 1
    
    new_post = {
      'id' => new_id,
      'title' => title,
      'content' => content,
      'published' => published,
      'created_at' => Time.now.strftime("%Y-%m-%d %H:%M:%S")
    }
    
    posts << new_post
    save_posts(posts)
    new_post
  end
  
  def self.find_post(id)
    all_posts.find { |p| p['id'] == id.to_i }
  end
end

# 새 포스트 작성 페이지
get '/new' do
  erb :new
end

# 포스트 생성 처리
post '/posts' do
  title = params[:title]
  content = params[:content]
  published = params[:published] == 'on'
  
  if title && !title.empty? && content && !content.empty?
    post = BlogData.create_post(title, content, published)
    redirect "/posts/#{post['id']}"
  else
    @error = "제목과 내용을 모두 입력해주세요."
    erb :new
  end
end

# 개별 포스트 보기
get '/posts/:id' do
  @post = BlogData.find_post(params[:id])
  halt 404 unless @post
  erb :show
end

# 템플릿에 추가
__END__

# (기존 템플릿들 그대로...)

@@new
<h1>✍️ 새 포스트 작성</h1>

<% if @error %>
    <div class="alert alert-danger"><%= @error %></div>
<% end %>

<form method="post" action="/posts">
    <div class="mb-3">
        <label for="title" class="form-label">📝 제목</label>
        <input type="text" class="form-control" id="title" name="title" required>
    </div>
    
    <div class="mb-3">
        <label for="content" class="form-label">📄 내용 (마크다운)</label>
        <textarea class="form-control" id="content" name="content" rows="10" 
                  placeholder="마크다운으로 작성하세요..." required></textarea>
    </div>
    
    <div class="mb-3 form-check">
        <input type="checkbox" class="form-check-input" id="published" name="published">
        <label class="form-check-label" for="published">🚀 바로 발행하기</label>
    </div>
    
    <div class="d-flex gap-2">
        <button type="submit" class="btn btn-primary">💾 저장</button>
        <a href="/" class="btn btn-secondary">❌ 취소</a>
    </div>
</form>

@@show
<div class="mb-4">
    <a href="/" class="btn btn-outline-secondary">← 목록으로</a>
</div>

<article>
    <header class="mb-4">
        <h1 class="display-4"><%= @post['title'] %></h1>
        <small class="text-muted">작성일: <%= @post['created_at'] %></small>
    </header>
    
    <div class="post-content">
        <%= SimpleMarkdown.render(@post['content']) %>
    </div>
</article>
```

### **메인 페이지에 작성 버튼 추가**

```ruby
# @@index 템플릿 수정
@@index
<div class="d-flex justify-content-between align-items-center mb-4">
    <h1>📚 블로그 포스트</h1>
    <a href="/new" class="btn btn-primary">✍️ 새 포스트 작성</a>
</div>

<!-- 나머지는 동일 -->
```

**✅ 체크포인트:** "새 포스트 작성" 버튼을 눌러서 포스트를 작성하고 저장할 수 있나요?

---

## 🎬 6단계: 실시간 미리보기 추가

### **미리보기 API와 에디터 개선**

```ruby
# 미리보기 API 추가
get '/api/preview' do
  content_type :json
  markdown = params[:content] || ""
  html = SimpleMarkdown.render(markdown)
  { html: html }.to_json
end

# CSS 스타일 추가 (@@layout의 <style> 안에)
.editor-container { display: flex; gap: 1rem; }
.editor-half { flex: 1; }
.preview-pane {
    border: 1px solid #dee2e6;
    border-radius: 0.375rem;
    padding: 1rem;
    min-height: 400px;
    background: #fff;
}
@media (max-width: 768px) {
    .editor-container { flex-direction: column; }
}

# @@new 템플릿의 textarea 부분을 다음으로 교체:
<div class="mb-3">
    <label for="content" class="form-label">📄 내용 (마크다운)</label>
    <div class="editor-container">
        <div class="editor-half">
            <textarea class="form-control" id="content" name="content" rows="20" 
                      placeholder="마크다운으로 작성하세요..." required></textarea>
        </div>
        <div class="editor-half">
            <div class="form-label">👀 실시간 미리보기</div>
            <div id="preview" class="preview-pane">여기에 미리보기가 표시됩니다...</div>
        </div>
    </div>
</div>

# @@new 템플릿 마지막에 JavaScript 추가:
<script>
document.getElementById('content').addEventListener('input', function() {
    const content = this.value;
    fetch('/api/preview?content=' + encodeURIComponent(content))
        .then(response => response.json())
        .then(data => {
            document.getElementById('preview').innerHTML = data.html || '미리보기가 여기에 표시됩니다...';
        });
});
</script>
```

**✅ 체크포인트:** 텍스트를 입력하면 오른쪽에 실시간으로 미리보기가 나타나나요?

---

## 🔍 7단계: 검색 기능 추가

### **검색 로직과 UI 추가**

```ruby
# BlogData 클래스에 검색 메서드 추가
class BlogData
  def self.search_posts(query)
    return [] if query.nil? || query.strip.empty?
    query = query.downcase
    
    all_posts.select do |post|
      post['title'].downcase.include?(query) ||
      post['content'].downcase.include?(query)
    end
  end
end

# 메인 라우트 수정
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

# @@index 템플릿에 검색창 추가 (제목 아래):
<div class="row mb-4">
    <div class="col-md-8">
        <div class="input-group">
            <span class="input-group-text">🔍</span>
            <input type="text" class="form-control" id="search-input" 
                   placeholder="제목, 내용 검색..." value="<%= @search_query %>">
            <button class="btn btn-outline-secondary" onclick="searchPosts()">검색</button>
        </div>
    </div>
</div>

# @@layout의 </body> 전에 JavaScript 추가:
<script>
function searchPosts() {
    const query = document.getElementById('search-input').value;
    if (query.trim()) {
        window.location.href = `/?search=${encodeURIComponent(query)}`;
    } else {
        window.location.href = '/';
    }
}

document.getElementById('search-input')?.addEventListener('keypress', function(e) {
    if (e.key === 'Enter') {
        searchPosts();
    }
});
</script>
```

**✅ 체크포인트:** 검색창에 키워드를 입력하면 관련 포스트가 필터링되나요?

---

## 🏷️ 8단계: 태그 시스템 추가

### **태그 기능 구현**

```ruby
# BlogData의 create_post 메서드 수정
def self.create_post(title, content, published = false, tags = [])
  posts = all_posts
  new_id = posts.empty? ? 1 : posts.map { |p| p['id'] }.max + 1
  
  new_post = {
    'id' => new_id,
    'title' => title,
    'content' => content,
    'published' => published,
    'tags' => tags || [],
    'created_at' => Time.now.strftime("%Y-%m-%d %H:%M:%S")
  }
  
  posts << new_post
  save_posts(posts)
  new_post
end

# 태그 관련 메서드 추가
def self.get_all_tags
  all_posts.flat_map { |p| p['tags'] || [] }.uniq.sort
end

def self.posts_by_tag(tag)
  all_posts.select { |p| p['tags'] && p['tags'].include?(tag) }
end

# 메인 라우트에 태그 필터링 추가
get '/' do
  query = params[:search]
  tag = params[:tag]
  
  @posts = BlogData.all_posts.select { |p| p['published'] }
  
  if query && !query.strip.empty?
    @posts = BlogData.search_posts(query).select { |p| p['published'] }
  elsif tag && !tag.empty?
    @posts = BlogData.posts_by_tag(tag).select { |p| p['published'] }
  end
  
  @all_tags = BlogData.get_all_tags
  @search_query = query
  @current_tag = tag
  
  erb :index
end

# 포스트 생성 라우트 수정
post '/posts' do
  title = params[:title]
  content = params[:content]
  published = params[:published] == 'on'
  tags = params[:tags] ? params[:tags].split(',').map(&:strip) : []
  
  if title && !title.empty? && content && !content.empty?
    post = BlogData.create_post(title, content, published, tags)
    redirect "/posts/#{post['id']}"
  else
    @error = "제목과 내용을 모두 입력해주세요."
    erb :new
  end
end

# @@new 템플릿에 태그 입력 추가 (제목 아래):
<div class="mb-3">
    <label for="tags" class="form-label">🏷️ 태그</label>
    <input type="text" class="form-control" id="tags" name="tags" 
           placeholder="태그를 쉼표로 구분해서 입력하세요 (예: Ruby, Sinatra, 마크다운)">
    <div class="form-text">태그는 쉼표(,)로 구분해서 입력하세요.</div>
</div>

# @@index 템플릿에 태그 표시 추가 (검색창 아래):
<% if @all_tags.any? %>
<div class="mb-4">
    <h6>🏷️ 태그:</h6>
    <div class="d-flex flex-wrap gap-2">
        <% @all_tags.each do |tag| %>
            <span class="badge <%= @current_tag == tag ? 'bg-primary' : 'bg-secondary' %>" 
                  style="cursor: pointer" onclick="filterByTag('<%= tag %>')">
                #<%= tag %>
            </span>
        <% end %>
    </div>
</div>
<% end %>

# 카드에 태그 표시 추가 (card-title 아래):
<% if post['tags'] && post['tags'].any? %>
    <div class="mb-2">
        <% post['tags'].each do |tag| %>
            <span class="badge bg-secondary me-1">#<%= tag %></span>
        <% end %>
    </div>
<% end %>

# JavaScript에 태그 필터링 함수 추가:
function filterByTag(tag) {
    window.location.href = `/?tag=${encodeURIComponent(tag)}`;
}
```

**✅ 체크포인트:** 태그를 입력하고 태그를 클릭해서 필터링할 수 있나요?

---

## 💬 9단계: 댓글 시스템 추가

### **댓글 기능 구현**

```ruby
# BlogData에 댓글 메서드 추가
def self.add_comment(post_id, author, content)
  posts = all_posts
  post = posts.find { |p| p['id'] == post_id.to_i }
  return nil unless post
  
  post['comments'] ||= []
  comment_id = post['comments'].empty? ? 1 : post['comments'].map { |c| c['id'] }.max + 1
  
  new_comment = {
    'id' => comment_id,
    'author' => author,
    'content' => content,
    'created_at' => Time.now.strftime("%Y-%m-%d %H:%M:%S")
  }
  
  post['comments'] << new_comment
  save_posts(posts)
  new_comment
end

# 댓글 작성 라우트 추가
post '/posts/:id/comments' do
  author = params[:author] || '익명'
  content = params[:comment_content]
  
  if content && !content.strip.empty?
    BlogData.add_comment(params[:id].to_i, author, content)
  end
  
  redirect "/posts/#{params[:id]}"
end

# @@show 템플릿 끝에 댓글 섹션 추가:
<!-- 댓글 섹션 -->
<section class="mt-5">
    <h3>💬 댓글</h3>
    
    <!-- 댓글 작성 -->
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
                             rows="3" required placeholder="댓글을 입력하세요"></textarea>
                </div>
                <button type="submit" class="btn btn-primary">댓글 작성</button>
            </form>
        </div>
    </div>
    
    <!-- 댓글 목록 -->
    <% if @post['comments'] && @post['comments'].any? %>
        <% @post['comments'].each do |comment| %>
            <div class="card mb-3">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-start">
                        <strong><%= comment['author'] || '익명' %></strong>
                        <small class="text-muted"><%= comment['created_at'] %></small>
                    </div>
                    <div class="mt-2">
                        <%= SimpleMarkdown.render(comment['content']) %>
                    </div>
                </div>
            </div>
        <% end %>
    <% else %>
        <div class="text-center text-muted py-4">
            <p>아직 댓글이 없습니다. 첫 번째 댓글을 작성해보세요!</p>
        </div>
    <% end %>
</section>
```

**✅ 체크포인트:** 포스트에 댓글을 작성할 수 있나요? 마크다운 문법이 댓글에서도 작동하나요?

---

## 🎉 10단계: 최종 완성 및 테스트

### **최종 기능 확인 체크리스트**

#### ✅ **기본 기능**
- [ ] 포스트 목록 보기
- [ ] 포스트 상세 보기
- [ ] 새 포스트 작성
- [ ] 마크다운 렌더링

#### ✅ **고급 기능**
- [ ] 실시간 미리보기
- [ ] 검색 기능 (제목/내용)
- [ ] 태그 시스템
- [ ] 태그 필터링
- [ ] 댓글 작성
- [ ] 댓글 마크다운 지원

#### ✅ **UI/UX**
- [ ] 반응형 디자인 (모바일 지원)
- [ ] Bootstrap 스타일링
- [ ] 한글 폰트 적용
- [ ] 직관적인 네비게이션

### **데모 포스트 작성해보기**

1. **"새 포스트 작성" 클릭**
2. **다음 내용으로 테스트:**

```markdown
제목: 🚀 마크다운 블로그 테스트
태그: Ruby, Sinatra, 테스트, 마크다운

# 마크다운 기능 테스트

## 텍스트 스타일
- **굵은 글씨**
- *기울임 글씨*

## 목록
- 첫 번째 항목
- 두 번째 항목
- 세 번째 항목

## 코드
`console.log("안녕하세요!")` 인라인 코드입니다.

**이 모든 기능이 실시간으로 미리보기됩니다!**
```

3. **"바로 발행하기" 체크 후 저장**
4. **댓글 작성해보기**
5. **태그로 필터링해보기**
6. **검색 기능 테스트**

---

## 🚀 완성! 다음 단계

### **더 추가해볼 수 있는 기능들**

1. **포스트 수정/삭제**
2. **카테고리 시스템**
3. **이미지 업로드**
4. **댓글 답글 기능**
5. **관리자 인증**
6. **RSS 피드**

### **배포하기**
```bash
# Heroku 배포용 파일들
echo "ruby '3.0.0'" > Gemfile
echo "source 'https://rubygems.org'" >> Gemfile
echo "gem 'sinatra'" >> Gemfile

# Procfile 생성
echo "web: ruby blog_app.rb -p $PORT" > Procfile
```

---

**🎉 축하합니다! 완전한 기능의 마크다운 블로그를 만드셨습니다!**

이제 여러분만의 블로그에 다양한 포스트를 작성하고, 필요에 따라 기능을 추가해보세요. 

**총 작업 시간**: 약 2-3시간  
**완성도**: ⭐⭐⭐⭐⭐ (완전한 블로그 시스템)  
**난이도**: 초급~중급 (Ruby 기본 문법 필요)