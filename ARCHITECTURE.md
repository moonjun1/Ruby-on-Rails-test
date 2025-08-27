# 🏗️ 마크다운 블로그 아키텍처 문서

> **시스템 설계와 구현 아키텍처에 대한 상세 설명**

## 📐 시스템 아키텍처 개요

```
┌─────────────────────────────────────────────────────────┐
│                    웹 브라우저                            │
│                   (사용자 인터페이스)                      │
└─────────────────────────────────────────────────────────┘
                              │ HTTP 요청/응답
                              ▼
┌─────────────────────────────────────────────────────────┐
│                  Sinatra 웹 서버                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │   라우팅    │  │   ERB 템플릿  │  │ JavaScript  │    │
│  │  (GET/POST) │  │   (HTML)    │  │   (AJAX)    │    │
│  └─────────────┘  └─────────────┘  └─────────────┘    │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────┐
│                   비즈니스 로직 계층                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │   BlogData  │  │ SimpleMarkdown│ │  검색/필터링  │    │
│  │  (데이터 관리)│  │ (마크다운 변환)│  │   (태그/검색) │    │
│  └─────────────┘  └─────────────┘  └─────────────┘    │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────┐
│                    데이터 저장소                         │
│              db/posts.json (JSON 파일)                 │
│      포스트, 댓글, 태그, 메타데이터 저장                  │
└─────────────────────────────────────────────────────────┘
```

## 🧩 주요 컴포넌트 분석

### 1. **웹 서버 계층 (Sinatra)**

```ruby
# 서버 설정
set :port, 3000
set :bind, '0.0.0.0'
```

**역할:**
- HTTP 요청/응답 처리
- 라우팅 관리
- 템플릿 렌더링
- 정적 파일 제공

**장점:**
- 간단하고 빠른 설정
- Rails보다 가벼움
- Ruby 생태계 활용 가능

### 2. **데이터 관리 계층 (BlogData)**

```ruby
class BlogData
  DB_FILE = 'db/posts.json'
  
  def self.all_posts
    # JSON 파일에서 데이터 읽기
  end
  
  def self.save_posts(posts)
    # JSON 파일에 데이터 쓰기
  end
end
```

**설계 원칙:**
- **싱글톤 패턴**: 클래스 메서드로 데이터 접근 통일
- **파일 기반**: 별도 DB 서버 불필요
- **JSON 형식**: 가독성 높고 구조화된 데이터
- **원자적 쓰기**: 임시 파일 사용으로 데이터 무결성 보장

### 3. **마크다운 처리 계층 (SimpleMarkdown)**

```ruby
class SimpleMarkdown
  def self.render(text)
    # 정규표현식 기반 마크다운 → HTML 변환
  end
end
```

**변환 순서:**
1. 코드 블록 (``` 처리)
2. 인라인 코드 (` 처리)
3. 헤더 (# ## ### 처리)
4. 텍스트 스타일 (**, * 처리)
5. 링크 ([텍스트](URL) 처리)
6. 목록 (- 처리)
7. 줄바꿈 (\n → <br> 처리)

## 📊 데이터 구조 설계

### **포스트 데이터 스키마**

```json
{
  "id": 1,
  "title": "포스트 제목",
  "content": "마크다운 내용...",
  "published": true,
  "tags": ["Ruby", "Sinatra", "마크다운"],
  "category": "개발",
  "comments": [
    {
      "id": 1,
      "author": "작성자",
      "content": "댓글 내용",
      "parent_id": null,
      "created_at": "2025-08-27 14:30:00"
    }
  ],
  "created_at": "2025-08-27 14:00:00",
  "updated_at": "2025-08-27 14:05:00"
}
```

### **데이터 관계도**

```
포스트 (Post)
├── 기본 정보 (id, title, content, published)
├── 메타데이터 (created_at, updated_at)
├── 분류 시스템
│   ├── tags[] (다대다 관계)
│   └── category (일대다 관계)
└── 댓글 시스템
    └── comments[]
        ├── 기본 댓글 (parent_id: null)
        └── 답글 (parent_id: 존재)
```

## 🚦 HTTP 라우팅 구조

```ruby
# RESTful API 설계
GET    /              # 포스트 목록 (+ 검색/필터링)
GET    /new           # 새 포스트 작성 폼
POST   /posts         # 포스트 생성
GET    /posts/:id     # 포스트 상세 보기
GET    /posts/:id/edit # 포스트 수정 폼
PUT    /posts/:id     # 포스트 업데이트
DELETE /posts/:id     # 포스트 삭제
POST   /posts/:id/comments # 댓글 작성

# API 엔드포인트
GET    /api/preview   # 마크다운 미리보기
GET    /api/search    # 실시간 검색
```

## 🔄 요청 처리 플로우

### **포스트 작성 플로우**
```
1. 사용자: GET /new 요청
   ↓
2. 서버: new.erb 템플릿 렌더링
   ↓
3. 사용자: 폼 작성 후 POST /posts
   ↓
4. 서버: 
   - 입력 데이터 검증
   - BlogData.create_post() 호출
   - JSON 파일에 저장
   - /posts/:id로 리다이렉트
   ↓
5. 사용자: 새 포스트 상세 페이지 표시
```

### **검색 처리 플로우**
```
1. 사용자: 검색어 입력
   ↓
2. JavaScript: searchPosts() 함수 호출
   ↓
3. 브라우저: GET /?search=키워드 요청
   ↓
4. 서버: 
   - BlogData.search_posts() 호출
   - 제목/내용/태그/카테고리에서 검색
   - 필터링된 결과를 @posts에 할당
   ↓
5. ERB 템플릿: 검색 결과 렌더링
```

## ⚡ 성능 최적화 전략

### 1. **데이터 접근 최적화**

```ruby
# 캐싱 전략 (구현 예시)
class BlogData
  @cache = {}
  
  def self.all_posts_cached
    file_hash = Digest::MD5.hexdigest(File.read(DB_FILE))
    
    if @cache[:hash] != file_hash
      @cache[:posts] = all_posts
      @cache[:hash] = file_hash
    end
    
    @cache[:posts]
  end
end
```

### 2. **프론트엔드 최적화**

```javascript
// 디바운싱으로 API 호출 최소화
let previewTimeout;
document.getElementById('content').addEventListener('input', function() {
    clearTimeout(previewTimeout);
    previewTimeout = setTimeout(() => {
        // 미리보기 API 호출
    }, 300);
});
```

### 3. **메모리 사용 최적화**

- **지연 로딩**: 필요할 때만 데이터 로드
- **페이지네이션**: 대량 포스트 처리 시 구현
- **텍스트 압축**: 긴 내용 미리보기 시 truncate

## 🔒 보안 고려사항

### 1. **XSS 방지**

```ruby
# HTML 이스케이프 적용
def self.render(text)
  text = CGI.escapeHTML(text) if text
  # 마크다운 처리...
end

# ERB 템플릿에서도 자동 이스케이프
<%= h(user_input) %>
```

### 2. **입력 검증**

```ruby
# 포스트 생성 시 검증
if title && !title.empty? && content && !content.empty?
  # 처리 진행
else
  # 에러 처리
end

# 태그 입력 정규화
tags = params[:tags] ? params[:tags].split(',').map(&:strip).reject(&:empty?) : []
```

### 3. **파일 시스템 보안**

```ruby
# 경로 조작 방지
DB_FILE = 'db/posts.json'  # 고정된 경로 사용

# 원자적 쓰기로 데이터 무결성 보장
def self.save_posts(posts)
  temp_file = "#{DB_FILE}.tmp"
  File.write(temp_file, JSON.pretty_generate(posts), encoding: 'utf-8')
  File.rename(temp_file, DB_FILE)  # 원자적 이동
end
```

## 🌐 확장성 고려사항

### 1. **데이터베이스 마이그레이션 준비**

```ruby
# ActiveRecord 스타일로 쉽게 변환 가능한 구조
class Post < ActiveRecord::Base
  has_many :comments
  has_many :post_tags
  has_many :tags, through: :post_tags
end

class Comment < ActiveRecord::Base
  belongs_to :post
  belongs_to :parent, class_name: 'Comment', optional: true
  has_many :replies, class_name: 'Comment', foreign_key: 'parent_id'
end
```

### 2. **API 확장**

```ruby
# REST API 제공 준비
get '/api/posts' do
  content_type :json
  BlogData.all_posts.to_json
end

post '/api/posts' do
  content_type :json
  # JSON 데이터로 포스트 생성
end
```

### 3. **캐싱 시스템**

```ruby
# Redis 캐싱 준비
require 'redis'

class BlogData
  def self.cached_posts
    redis = Redis.new
    cached = redis.get('posts')
    
    if cached
      JSON.parse(cached)
    else
      posts = all_posts
      redis.setex('posts', 300, posts.to_json)  # 5분 캐시
      posts
    end
  end
end
```

## 🧪 테스트 전략

### 1. **단위 테스트**

```ruby
# RSpec 예시
describe BlogData do
  describe '.create_post' do
    it 'creates a new post with valid data' do
      post = BlogData.create_post('Test Title', 'Test Content')
      expect(post['id']).to be_present
      expect(post['title']).to eq('Test Title')
    end
  end
end
```

### 2. **통합 테스트**

```ruby
# Rack::Test를 사용한 HTTP 테스트
describe 'Blog App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it 'displays the home page' do
    get '/'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include('블로그 포스트')
  end
end
```

### 3. **E2E 테스트**

```ruby
# Capybara를 사용한 브라우저 테스트
feature 'Post creation' do
  scenario 'User creates a new post' do
    visit '/new'
    fill_in 'title', with: 'Test Post'
    fill_in 'content', with: '# Test Content'
    click_button '저장'
    
    expect(page).to have_content('Test Post')
  end
end
```

## 📈 모니터링 및 로깅

### 1. **로깅 전략**

```ruby
require 'logger'

class BlogData
  def self.logger
    @logger ||= Logger.new('log/blog.log')
  end
  
  def self.create_post(title, content, published = false)
    logger.info "Creating post: #{title}"
    # 포스트 생성 로직...
    logger.info "Post created with ID: #{new_post['id']}"
  end
end
```

### 2. **성능 모니터링**

```ruby
# 간단한 성능 측정
def self.search_posts(query)
  start_time = Time.now
  results = # 검색 로직
  duration = Time.now - start_time
  
  logger.info "Search completed in #{duration}s for query: #{query}"
  results
end
```

---

## 📚 참고 자료

### **사용 기술 스택**
- **백엔드**: Ruby 3.4.5 + Sinatra 4.1.1
- **프론트엔드**: Bootstrap 5.3.0 + Vanilla JavaScript
- **데이터**: JSON 파일 기반
- **템플릿**: ERB (Embedded Ruby)
- **폰트**: Noto Sans KR (한글 최적화)

### **개발 원칙**
- **KISS (Keep It Simple, Stupid)**: 간단하고 명확한 구조
- **DRY (Don't Repeat Yourself)**: 코드 중복 최소화
- **REST**: RESTful API 설계 원칙 준수
- **Progressive Enhancement**: 점진적 기능 향상

### **코드 품질**
- **가독성**: 명확한 변수명과 주석
- **유지보수성**: 모듈화된 구조
- **확장성**: 쉬운 기능 추가 구조
- **보안**: 입력 검증과 XSS 방지

---

**🏗️ 이 아키텍처는 간단하지만 확장 가능한 설계로, 작은 블로그부터 중간 규모 웹사이트까지 지원할 수 있습니다.**