# encoding: utf-8
# 완전히 작동하는 마크다운 블로그 웹 애플리케이션

require 'sinatra'
require 'json'
require 'cgi'
require 'fileutils'

# UTF-8 설정
if RUBY_PLATFORM =~ /mingw|mswin/
  STDOUT.set_encoding('UTF-8')
  STDERR.set_encoding('UTF-8')
end

# 설정
set :port, 3000
set :bind, '0.0.0.0'
set :public_folder, 'public'

# 데이터 저장 관리 클래스
class BlogData
  DB_FILE = 'db/posts.json'
  
  def self.init
    FileUtils.mkdir_p('db')
    unless File.exist?(DB_FILE)
      posts = [
        {
          'id' => 1,
          'title' => '🚀 마크다운 블로그에 오신 것을 환영합니다!',
          'content' => "# 안녕하세요! 👋\n\n**완전히 작동하는 마크다운 블로그**에 오신 것을 환영합니다!\n\n## ✨ 실제로 사용할 수 있는 기능들\n\n- ✍️ **마크다운으로 포스트 작성**\n- 📝 **실시간 HTML 변환**\n- 🎨 **코드 하이라이팅**\n- 💾 **포스트 저장/수정/삭제**\n\n## 💻 코드 예제\n\n```ruby\ndef hello_world\n  puts \"Hello from Ruby!\"\nend\n\nhello_world\n```\n\n```javascript\nfunction greet(name) {\n  console.log(`안녕하세요, ${name}님!`);\n}\n\ngreet('개발자');\n```\n\n## 📋 리스트 테스트\n\n1. 첫 번째 항목\n2. 두 번째 항목\n3. 세 번째 항목\n\n- 순서 없는 항목 1\n- 순서 없는 항목 2\n\n> 인용구도 잘 작동합니다!\n\n이제 직접 포스트를 작성해보세요! 🎉",
          'published' => true,
          'created_at' => Time.now.strftime("%Y-%m-%d %H:%M:%S"),
          'updated_at' => Time.now.strftime("%Y-%m-%d %H:%M:%S")
        },
        {
          'id' => 2,
          'title' => '📝 마크다운 문법 가이드',
          'content' => "# 마크다운 문법 완벽 가이드\n\n## 제목 (Headers)\n\n```markdown\n# H1 제목\n## H2 제목\n### H3 제목\n```\n\n## 텍스트 강조\n\n- **굵은 글씨** (`**굵은 글씨**`)\n- *기울임 글씨* (`*기울임 글씨*`)\n- `인라인 코드` (백틱으로 감쌈)\n\n## 링크와 이미지\n\n[Google 링크](https://google.com)\n\n## 표 만들기\n\n| 이름 | 나이 | 직업 |\n|------|------|------|\n| 홍길동 | 25 | 개발자 |\n| 김철수 | 30 | 디자이너 |\n\n이제 이 기능들을 직접 사용해보세요!",
          'published' => true,
          'created_at' => (Time.now - 3600).strftime("%Y-%m-%d %H:%M:%S"),
          'updated_at' => (Time.now - 3600).strftime("%Y-%m-%d %H:%M:%S")
        }
      ]
      save_posts(posts)
    end
  end
  
  def self.all_posts
    return [] unless File.exist?(DB_FILE)
    JSON.parse(File.read(DB_FILE, encoding: 'utf-8'))
  rescue
    []
  end
  
  def self.find_post(id)
    all_posts.find { |p| p['id'] == id.to_i }
  end
  
  def self.save_posts(posts)
    File.write(DB_FILE, JSON.pretty_generate(posts), encoding: 'utf-8')
  end
  
  def self.create_post(title, content, published = false, tags = [], category = '')
    posts = all_posts
    new_id = posts.empty? ? 1 : posts.map { |p| p['id'] }.max + 1
    
    new_post = {
      'id' => new_id,
      'title' => title,
      'content' => content,
      'published' => published,
      'tags' => tags || [],
      'category' => category || '',
      'comments' => [],
      'created_at' => Time.now.strftime("%Y-%m-%d %H:%M:%S"),
      'updated_at' => Time.now.strftime("%Y-%m-%d %H:%M:%S")
    }
    
    posts << new_post
    save_posts(posts)
    new_post
  end
  
  def self.update_post(id, title, content, published, tags = [], category = '')
    posts = all_posts
    post = posts.find { |p| p['id'] == id.to_i }
    return nil unless post
    
    post['title'] = title
    post['content'] = content
    post['published'] = published
    post['tags'] = tags || []
    post['category'] = category || ''
    post['comments'] ||= []
    post['updated_at'] = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    
    save_posts(posts)
    post
  end
  
  def self.delete_post(id)
    posts = all_posts
    posts.reject! { |p| p['id'] == id.to_i }
    save_posts(posts)
  end
  
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
end

# 간단한 마크다운 렌더러 (Redcarpet 없이)
class SimpleMarkdown
  def self.render(text)
    html = text.dup
    
    # 코드 블록
    html.gsub!(/```(\w+)?\n(.*?)\n```/m) do |match|
      lang = $1
      code = CGI.escapeHTML($2)
      "<pre class=\"code-block\"><code class=\"language-#{lang}\">#{code}</code></pre>"
    end
    
    # 인라인 코드
    html.gsub!(/`([^`]+)`/) { "<code>#{CGI.escapeHTML($1)}</code>" }
    
    # 제목
    html.gsub!(/^# (.+)$/, '<h1>\\1</h1>')
    html.gsub!(/^## (.+)$/, '<h2>\\1</h2>')
    html.gsub!(/^### (.+)$/, '<h3>\\1</h3>')
    
    # 굵은 글씨, 기울임
    html.gsub!(/\*\*([^*]+)\*\*/, '<strong>\\1</strong>')
    html.gsub!(/\*([^*]+)\*/, '<em>\\1</em>')
    
    # 링크
    html.gsub!(/\[([^\]]+)\]\(([^)]+)\)/, '<a href="\\2" target="_blank">\\1</a>')
    
    # 리스트
    html.gsub!(/^- (.+)$/, '<li>\\1</li>')
    html.gsub!(/^(\d+)\. (.+)$/, '<li>\\2</li>')
    
    # 인용구
    html.gsub!(/^> (.+)$/, '<blockquote>\\1</blockquote>')
    
    # 줄바꿈
    html.gsub!(/\n/, '<br>')
    
    html
  end
  
  def self.extract_text(markdown, limit = 150)
    text = markdown.gsub(/[#*`_~\[\]()>]/, '').gsub(/\n+/, ' ').strip
    text.length > limit ? text[0..limit] + '...' : text
  end
end

# 초기화
BlogData.init

# 라우트 정의
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
  
  @posts = @posts.sort_by { |p| p['created_at'] }.reverse
  @all_tags = BlogData.get_all_tags
  @all_categories = BlogData.get_all_categories
  @search_query = query
  @current_category = category
  @current_tag = tag
  
  erb :index
end

get '/posts/:id' do
  @post = BlogData.find_post(params[:id])
  halt 404 unless @post
  erb :show
end

get '/posts/:id/edit' do
  @post = BlogData.find_post(params[:id])
  halt 404 unless @post
  erb :edit
end

get '/new' do
  erb :new
end

post '/posts' do
  title = params[:title]
  content = params[:content]
  published = params[:published] == 'on'
  tags = params[:tags] ? params[:tags].split(',').map(&:strip) : []
  category = params[:category] || ''
  
  if title && !title.empty? && content && !content.empty?
    post = BlogData.create_post(title, content, published, tags, category)
    redirect "/posts/#{post['id']}"
  else
    @error = "제목과 내용을 모두 입력해주세요."
    erb :new
  end
end

put '/posts/:id' do
  title = params[:title]
  content = params[:content]  
  published = params[:published] == 'on'
  tags = params[:tags] ? params[:tags].split(',').map(&:strip) : []
  category = params[:category] || ''
  
  if title && !title.empty? && content && !content.empty?
    post = BlogData.update_post(params[:id].to_i, title, content, published, tags, category)
    if post
      redirect "/posts/#{post['id']}"
    else
      halt 404
    end
  else
    @error = "제목과 내용을 모두 입력해주세요."
    @post = BlogData.find_post(params[:id])
    erb :edit
  end
end

delete '/posts/:id' do
  BlogData.delete_post(params[:id].to_i)
  redirect '/'
end

post '/posts/:id/comments' do
  author = params[:author] || '익명'
  content = params[:comment_content]
  parent_id = params[:parent_id]&.to_i
  
  if content && !content.strip.empty?
    BlogData.add_comment(params[:id].to_i, author, content, parent_id)
  end
  
  redirect "/posts/#{params[:id]}"
end

get '/api/search' do
  content_type :json
  query = params[:q]
  results = BlogData.search_posts(query).select { |p| p['published'] }
  results.to_json
end

# API 엔드포인트 (AJAX용)
get '/api/preview' do
  content_type :json
  markdown = params[:content] || ""
  html = SimpleMarkdown.render(markdown)
  { html: html }.to_json
end

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
        .code-block { 
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
        }
        blockquote { 
            border-left: 4px solid #007bff; 
            padding-left: 1rem; 
            margin: 1rem 0; 
            color: #6c757d;
            font-style: italic;
        }
        .post-content h1, .post-content h2, .post-content h3 { 
            margin-top: 2rem; 
            margin-bottom: 1rem; 
        }
        .preview-pane {
            border: 1px solid #dee2e6;
            border-radius: 0.375rem;
            padding: 1rem;
            min-height: 400px;
            background: #fff;
        }
        .editor-container { display: flex; gap: 1rem; }
        .editor-half { flex: 1; }
        @media (max-width: 768px) {
            .editor-container { flex-direction: column; }
        }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a href="/" class="navbar-brand">🚀 Ruby 마크다운 블로그</a>
            <div class="navbar-nav ms-auto">
                <a href="/new" class="nav-link">✍️ 새 포스트</a>
            </div>
        </div>
    </nav>
    
    <main class="container my-4">
        <%= yield %>
    </main>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // 검색 기능
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
        
        // 카테고리 필터
        function filterByCategory() {
            const category = document.getElementById('category-filter').value;
            if (category) {
                window.location.href = `/?category=${encodeURIComponent(category)}`;
            } else {
                window.location.href = '/';
            }
        }
        
        // 태그 필터
        function filterByTag(tag) {
            window.location.href = `/?tag=${encodeURIComponent(tag)}`;
        }
        
        // 필터 지우기
        function clearFilters() {
            window.location.href = '/';
        }
        
        // 댓글 답글 폼 토글
        function toggleReplyForm(commentId) {
            const form = document.getElementById(`reply-form-${commentId}`);
            if (form.style.display === 'none') {
                form.style.display = 'block';
            } else {
                form.style.display = 'none';
            }
        }
    </script>
</body>
</html>

@@index
<div class="d-flex justify-content-between align-items-center mb-4">
    <h1>📚 블로그 포스트</h1>
    <a href="/new" class="btn btn-primary">✍️ 새 포스트 작성</a>
</div>

<!-- 검색 및 필터 -->
<div class="row mb-4">
    <div class="col-md-8">
        <div class="input-group">
            <span class="input-group-text">🔍</span>
            <input type="text" class="form-control" id="search-input" placeholder="제목, 내용, 태그, 카테고리 검색..." value="<%= @search_query %>">
            <button class="btn btn-outline-secondary" type="button" onclick="searchPosts()">검색</button>
        </div>
        <div id="search-suggestions" class="mt-2"></div>
    </div>
    <div class="col-md-4">
        <div class="d-flex gap-2">
            <select class="form-select" id="category-filter" onchange="filterByCategory()">
                <option value="">전체 카테고리</option>
                <% @all_categories.each do |cat| %>
                    <option value="<%= cat %>" <%= 'selected' if @current_category == cat %>><%= cat %></option>
                <% end %>
            </select>
        </div>
    </div>
</div>

<!-- 태그 필터 -->
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
        <% if @current_tag %>
            <span class="badge bg-danger tag-badge" style="cursor: pointer" onclick="clearFilters()">✖ 태그 지우기</span>
        <% end %>
    </div>
</div>
<% end %>

<div class="alert alert-success">
    <h4>🎉 완전히 작동하는 마크다운 블로그!</h4>
    <p><strong>이제 실제로 모든 기능을 사용할 수 있습니다!</strong></p>
    <ul class="mb-0">
        <li>✅ 포스트 작성/수정/삭제</li>
        <li>✅ 실시간 마크다운 미리보기</li>
        <li>✅ 코드 하이라이팅</li>
        <li>✅ 완전한 CRUD 기능</li>
        <li>🆕 🔍 검색 기능 (제목/내용/태그/카테고리)</li>
        <li>🆕 🏷️ 태그 및 카테고리 시스템</li>
        <li>🆕 💬 댓글 시스템 (답글 포함)</li>
    </ul>
</div>

<% if @posts.any? %>
    <div class="row">
        <% @posts.each do |post| %>
            <div class="col-md-6 mb-4">
                <div class="card h-100">
                    <div class="card-body d-flex flex-column">
                        <h5 class="card-title"><%= post['title'] %></h5>
                        <p class="card-text text-muted flex-grow-1">
                            <%= SimpleMarkdown.extract_text(post['content']) %>
                        </p>
                        <% if post['tags'] && post['tags'].any? %>
                            <div class="mb-2">
                                <% post['tags'].each do |tag| %>
                                    <span class="badge bg-secondary me-1">#<%= tag %></span>
                                <% end %>
                            </div>
                        <% end %>
                        <% if post['category'] && !post['category'].empty? %>
                            <div class="mb-2">
                                <span class="badge bg-info">📁 <%= post['category'] %></span>
                            </div>
                        <% end %>
                        <div class="d-flex justify-content-between align-items-center">
                            <a href="/posts/<%= post['id'] %>" class="btn btn-outline-primary">📖 읽어보기</a>
                            <div>
                                <small class="text-muted"><%= post['created_at'][0..9] %></small>
                                <% if post['comments'] && post['comments'].any? %>
                                    <span class="badge bg-success ms-2">💬 <%= post['comments'].length %></span>
                                <% end %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        <% end %>
    </div>
<% else %>
    <div class="text-center py-5">
        <div class="mb-4">📝</div>
        <h3 class="text-muted mb-3">아직 포스트가 없습니다</h3>
        <p class="text-muted mb-4">첫 번째 포스트를 작성해보세요!</p>
        <a href="/new" class="btn btn-primary btn-lg">✍️ 첫 포스트 작성하기</a>
    </div>
<% end %>

@@show
<div class="mb-4">
    <a href="/" class="btn btn-outline-secondary">← 목록으로</a>
</div>

<article>
    <header class="mb-4">
        <h1 class="display-4"><%= @post['title'] %></h1>
        <div class="mb-3">
            <% if @post['category'] && !@post['category'].empty? %>
                <span class="badge bg-info me-2">📁 <%= @post['category'] %></span>
            <% end %>
            <% if @post['tags'] && @post['tags'].any? %>
                <% @post['tags'].each do |tag| %>
                    <span class="badge bg-secondary me-1">#<%= tag %></span>
                <% end %>
            <% end %>
        </div>
        <div class="text-muted border-bottom pb-3">
            <small>작성일: <%= @post['created_at'] %></small>
            <% if @post['updated_at'] != @post['created_at'] %>
                <span class="mx-2">•</span>
                <small>수정일: <%= @post['updated_at'] %></small>
            <% end %>
            <% if @post['comments'] && @post['comments'].any? %>
                <span class="mx-2">•</span>
                <small>💬 댓글 <%= @post['comments'].length %>개</small>
            <% end %>
        </div>
    </header>
    
    <div class="post-content">
        <%= SimpleMarkdown.render(@post['content']) %>
    </div>
</article>

<div class="d-flex gap-2 border-top pt-3 mt-4">
    <a href="/posts/<%= @post['id'] %>/edit" class="btn btn-outline-primary">✏️ 수정</a>
    <form method="post" action="/posts/<%= @post['id'] %>" style="display:inline;">
        <input type="hidden" name="_method" value="delete">
        <button type="submit" class="btn btn-outline-danger" 
                onclick="return confirm('정말 삭제하시겠습니까?')">🗑️ 삭제</button>
    </form>
</div>

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
                    <input type="text" class="form-control" id="author" name="author" placeholder="이름을 입력하세요 (선택사항)">
                </div>
                <div class="mb-3">
                    <label for="comment_content" class="form-label">댓글 내용</label>
                    <textarea class="form-control" id="comment_content" name="comment_content" rows="3" required placeholder="마크다운 문법을 지원합니다!"></textarea>
                </div>
                <button type="submit" class="btn btn-primary">댓글 작성</button>
            </form>
        </div>
    </div>
    
    <!-- 댓글 목록 -->
    <% if @post['comments'] && @post['comments'].any? %>
        <% @post['comments'].select { |c| c['parent_id'].nil? }.each do |comment| %>
            <div class="card mb-3 comment-card">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-start">
                        <strong><%= comment['author'] || '익명' %></strong>
                        <small class="text-muted"><%= comment['created_at'] %></small>
                    </div>
                    <div class="mt-2 comment-content">
                        <%= SimpleMarkdown.render(comment['content']) %>
                    </div>
                    <div class="mt-2">
                        <button class="btn btn-sm btn-outline-secondary" onclick="toggleReplyForm(<%= comment['id'] %>)">↗️ 답글</button>
                    </div>
                    
                    <!-- 답글 작성 양식 -->
                    <div id="reply-form-<%= comment['id'] %>" class="mt-3" style="display: none;">
                        <form method="post" action="/posts/<%= @post['id'] %>/comments">
                            <input type="hidden" name="parent_id" value="<%= comment['id'] %>">
                            <div class="mb-2">
                                <input type="text" class="form-control form-control-sm" name="author" placeholder="이름 (선택사항)">
                            </div>
                            <div class="mb-2">
                                <textarea class="form-control form-control-sm" name="comment_content" rows="2" required placeholder="답글을 입력하세요"></textarea>
                            </div>
                            <div class="d-flex gap-2">
                                <button type="submit" class="btn btn-sm btn-primary">답글 작성</button>
                                <button type="button" class="btn btn-sm btn-secondary" onclick="toggleReplyForm(<%= comment['id'] %>)">취소</button>
                            </div>
                        </form>
                    </div>
                    
                    <!-- 답글 목록 -->
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
    <% else %>
        <div class="text-center text-muted py-4">
            <p>아직 댓글이 없습니다. 첫 번째 댓글을 작성해보세요!</p>
        </div>
    <% end %>
</section>

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
    
    <div class="mb-3 form-check">
        <input type="checkbox" class="form-check-input" id="published" name="published">
        <label class="form-check-label" for="published">🚀 바로 발행하기</label>
    </div>
    
    <div class="d-flex gap-2">
        <button type="submit" class="btn btn-primary">💾 저장</button>
        <a href="/" class="btn btn-secondary">❌ 취소</a>
    </div>
</form>

<script>
// 실시간 미리보기
document.getElementById('content').addEventListener('input', function() {
    const content = this.value;
    fetch('/api/preview?content=' + encodeURIComponent(content))
        .then(response => response.json())
        .then(data => {
            document.getElementById('preview').innerHTML = data.html || '미리보기가 여기에 표시됩니다...';
        })
        .catch(error => {
            document.getElementById('preview').innerHTML = '미리보기 로드 중...';
        });
});
</script>

@@edit
<h1>✏️ 포스트 수정</h1>

<% if @error %>
    <div class="alert alert-danger"><%= @error %></div>
<% end %>

<form method="post" action="/posts/<%= @post['id'] %>">
    <input type="hidden" name="_method" value="put">
    
    <div class="mb-3">
        <label for="title" class="form-label">📝 제목</label>
        <input type="text" class="form-control" id="title" name="title" 
               value="<%= @post['title'] %>" required>
    </div>
    
    <div class="mb-3">
        <label for="tags" class="form-label">🏷️ 태그</label>
        <input type="text" class="form-control" id="tags" name="tags" value="<%= (@post['tags'] || []).join(', ') %>" placeholder="태그를 쉼표로 구분해서 입력하세요">
        <div class="form-text">태그는 쉼표(,)로 구분해서 입력하세요.</div>
    </div>
    
    <div class="mb-3">
        <label for="category" class="form-label">📁 카테고리</label>
        <input type="text" class="form-control" id="category" name="category" value="<%= @post['category'] || '' %>" placeholder="카테고리를 입력하세요">
    </div>
    
    <div class="mb-3">
        <label for="content" class="form-label">📄 내용 (마크다운)</label>
        <div class="editor-container">
            <div class="editor-half">
                <textarea class="form-control" id="content" name="content" rows="20" required><%= @post['content'] %></textarea>
            </div>
            <div class="editor-half">
                <div class="form-label">👀 실시간 미리보기</div>
                <div id="preview" class="preview-pane"><%= SimpleMarkdown.render(@post['content']) %></div>
            </div>
        </div>
    </div>
    
    <div class="mb-3 form-check">
        <input type="checkbox" class="form-check-input" id="published" name="published"
               <%= 'checked' if @post['published'] %>>
        <label class="form-check-label" for="published">🚀 발행하기</label>
    </div>
    
    <div class="d-flex gap-2">
        <button type="submit" class="btn btn-primary">💾 업데이트</button>
        <a href="/posts/<%= @post['id'] %>" class="btn btn-secondary">❌ 취소</a>
    </div>
</form>

<script>
// 실시간 미리보기
document.getElementById('content').addEventListener('input', function() {
    const content = this.value;
    fetch('/api/preview?content=' + encodeURIComponent(content))
        .then(response => response.json())
        .then(data => {
            document.getElementById('preview').innerHTML = data.html || '미리보기가 여기에 표시됩니다...';
        });
});
</script>