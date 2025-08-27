# 샘플 데이터 생성
puts "🌱 샘플 데이터를 생성하고 있습니다..."

# 기존 데이터 삭제 (개발 환경에서만)
if Rails.env.development?
  Post.destroy_all
  puts "기존 데이터를 삭제했습니다."
end

# 샘플 포스트들 생성
posts_data = [
  {
    title: "🚀 마크다운 블로그에 오신 것을 환영합니다!",
    content: <<~MARKDOWN,
      # 안녕하세요! 👋

      **마크다운 블로그**에 오신 것을 환영합니다. 이 블로그는 Ruby on Rails로 만들어졌으며, 마크다운 문법을 완벽하게 지원합니다.

      ## 🎯 주요 기능들

      ### ✍️ 마크다운 지원
      - **굵은 글씨**와 *기울임 글씨*
      - `인라인 코드` 지원
      - 코드 블록 문법 하이라이팅

      ### 📝 콘텐츠 관리
      - 포스트 작성, 수정, 삭제
      - 초안/발행 상태 관리  
      - 자동 읽기 시간 계산

      ## 💻 코드 예제

      Ruby 코드도 아름답게 표시됩니다:

      ```ruby
      class Post < ApplicationRecord
        validates :title, presence: true
        validates :content, presence: true

        scope :published, -> { where(published: true) }
        
        def markdown_content
          MarkdownRenderer.render(content)
        end
      end
      ```

      JavaScript도 물론 지원합니다:

      ```javascript
      function greetUser(name) {
        console.log(`안녕하세요, ${name}님!`);
        return `환영합니다! 🎉`;
      }

      greetUser("개발자");
      ```

      ## 📋 리스트와 테이블

      ### 할 일 목록
      - [x] 프로젝트 설정 완료
      - [x] 마크다운 렌더링 구현
      - [x] UI/UX 디자인 완성
      - [ ] 테스트 코드 작성
      - [ ] 배포 환경 설정

      ### 기술 스택

      | 구분 | 기술 |
      |------|------|
      | 백엔드 | Ruby on Rails 7.0 |
      | 데이터베이스 | PostgreSQL |
      | 프론트엔드 | Bootstrap 5 |
      | 마크다운 | Redcarpet + Rouge |

      ## 💡 인용구와 팁

      > "좋은 코드는 그 자체로 최고의 문서다."  
      > — 로버트 C. 마틴

      ## 🎨 이미지와 링크

      더 많은 정보는 [GitHub](https://github.com)에서 확인하실 수 있습니다.

      ## 🎉 마무리

      이제 여러분만의 멋진 포스트를 작성해보세요! 마크다운의 모든 기능을 활용하여 아름다운 콘텐츠를 만들어보세요.

      해피 블로깅! 🚀✨
    MARKDOWN
    published: true
  },
  
  {
    title: "📚 마크다운 문법 완벽 가이드",
    content: <<~MARKDOWN,
      # 마크다운 문법 가이드 📖

      마크다운은 간단한 텍스트 기반 마크업 언어입니다. 이 가이드에서는 이 블로그에서 사용할 수 있는 모든 마크다운 문법을 소개합니다.

      ## 1. 제목 (Headers)

      ```markdown
      # H1 제목
      ## H2 제목  
      ### H3 제목
      #### H4 제목
      ##### H5 제목
      ###### H6 제목
      ```

      ## 2. 텍스트 스타일링

      ### 기본 스타일
      - **굵은 글씨** (`**굵은 글씨**`)
      - *기울임 글씨* (`*기울임 글씨*`)
      - ***굵고 기울임*** (`***굵고 기울임***`)
      - ~~취소선~~ (`~~취소선~~`)

      ### 코드
      - `인라인 코드` (백틱으로 감쌈)
      - 코드 블록은 3개의 백틱으로 감쌉니다

      ## 3. 리스트

      ### 순서 없는 리스트
      ```markdown
      - 항목 1
      - 항목 2
        - 하위 항목 1
        - 하위 항목 2
      - 항목 3
      ```

      결과:
      - 항목 1
      - 항목 2
        - 하위 항목 1
        - 하위 항목 2
      - 항목 3

      ### 순서 있는 리스트
      ```markdown
      1. 첫 번째
      2. 두 번째
      3. 세 번째
      ```

      결과:
      1. 첫 번째
      2. 두 번째  
      3. 세 번째

      ### 체크리스트
      ```markdown
      - [x] 완료된 작업
      - [ ] 미완료 작업
      - [x] 또 다른 완료된 작업
      ```

      결과:
      - [x] 완료된 작업
      - [ ] 미완료 작업
      - [x] 또 다른 완료된 작업

      ## 4. 링크와 이미지

      ### 링크
      ```markdown
      [링크 텍스트](URL)
      [Google](https://google.com)
      ```

      결과: [Google](https://google.com)

      ### 이미지  
      ```markdown
      ![대체 텍스트](이미지 URL)
      ```

      ## 5. 인용구

      ```markdown
      > 이것은 인용구입니다.
      > 여러 줄로 작성할 수 있습니다.
      >
      > > 중첩된 인용구도 가능합니다.
      ```

      결과:
      > 이것은 인용구입니다.
      > 여러 줄로 작성할 수 있습니다.
      >
      > > 중첩된 인용구도 가능합니다.

      ## 6. 코드 블록

      ### 언어 지정 없음
      ```
      일반 코드 블록
      여러 줄 코드
      ```

      ### Ruby 코드
      ```ruby
      def hello_world
        puts "안녕하세요, 세상!"
      end

      hello_world
      ```

      ### Python 코드
      ```python
      def fibonacci(n):
          if n <= 1:
              return n
          return fibonacci(n-1) + fibonacci(n-2)

      print(fibonacci(10))
      ```

      ### JavaScript 코드
      ```javascript
      const posts = await fetch('/api/posts')
        .then(response => response.json())
        .catch(error => console.error('Error:', error));

      console.log(posts);
      ```

      ## 7. 테이블

      ```markdown
      | 항목 | 설명 | 가격 |
      |------|------|------|
      | 사과 | 빨간 과일 | 1,000원 |
      | 바나나 | 노란 과일 | 800원 |
      | 포도 | 보라 과일 | 2,000원 |
      ```

      결과:

      | 항목 | 설명 | 가격 |
      |------|------|------|
      | 사과 | 빨간 과일 | 1,000원 |
      | 바나나 | 노란 과일 | 800원 |
      | 포도 | 보라 과일 | 2,000원 |

      ### 테이블 정렬
      ```markdown
      | 왼쪽 정렬 | 중앙 정렬 | 오른쪽 정렬 |
      |:----------|:---------:|-----------:|
      | 왼쪽      |   중앙    |      오른쪽 |
      ```

      | 왼쪽 정렬 | 중앙 정렬 | 오른쪽 정렬 |
      |:----------|:---------:|-----------:|
      | 왼쪽      |   중앙    |      오른쪽 |

      ## 8. 수평선

      ```markdown
      ---
      ```

      결과:

      ---

      ## 9. 이스케이프

      특수 문자를 표시하려면 백슬래시를 사용합니다:

      ```markdown
      \\*이것은 기울임이 아닙니다\\*
      \\`이것은 코드가 아닙니다\\`
      ```

      ## 10. HTML 태그

      마크다운 안에서 HTML 태그도 사용할 수 있습니다:

      ```html
      <div style="color: red;">빨간 글씨</div>
      <details>
        <summary>클릭해서 펼치기</summary>
        숨겨진 내용입니다!
      </details>
      ```

      ## 🎯 팁과 권장사항

      1. **일관성**: 하나의 문서에서는 일관된 스타일을 유지하세요
      2. **가독성**: 적절한 공백과 줄바꿈을 활용하세요  
      3. **구조화**: 제목을 이용해 문서를 체계적으로 구성하세요
      4. **코드 블록**: 언어를 명시하면 더 예쁜 하이라이팅을 볼 수 있습니다

      이제 마크다운으로 아름다운 포스트를 작성해보세요! 🚀
    MARKDOWN
    published: true
  },

  {
    title: "🛠️ Rails 개발 환경 설정하기",
    content: <<~MARKDOWN,
      # Ruby on Rails 개발 환경 설정

      이 포스트에서는 Ruby on Rails 개발 환경을 처음부터 설정하는 방법을 알아보겠습니다.

      ## 1. Ruby 설치

      ### macOS (Homebrew 사용)
      ```bash
      # Homebrew 설치 (이미 설치되어 있다면 생략)
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

      # Ruby 설치
      brew install ruby
      ```

      ### Windows (RubyInstaller 사용)
      1. [RubyInstaller](https://rubyinstaller.org/) 사이트 방문
      2. Ruby+Devkit 버전 다운로드
      3. 설치 프로그램 실행

      ### Linux (Ubuntu/Debian)
      ```bash
      sudo apt update
      sudo apt install ruby-full
      ```

      ## 2. Rails 설치

      ```bash
      gem install rails
      rails --version
      ```

      ## 3. 데이터베이스 설정

      ### PostgreSQL 설치
      ```bash
      # macOS
      brew install postgresql
      
      # Ubuntu/Debian  
      sudo apt install postgresql postgresql-contrib
      
      # Windows
      # PostgreSQL 공식 사이트에서 설치 프로그램 다운로드
      ```

      ## 4. 새 Rails 프로젝트 생성

      ```bash
      rails new my_blog --database=postgresql
      cd my_blog
      ```

      ## 5. 필수 Gem 추가

      `Gemfile`에 다음 gem들을 추가합니다:

      ```ruby
      # 마크다운 처리
      gem 'redcarpet'
      gem 'rouge'

      # UI 프레임워크
      gem 'bootstrap', '~> 5.2'

      # 개발 도구
      group :development, :test do
        gem 'rspec-rails'
        gem 'factory_bot_rails'
      end
      ```

      ## 6. Bundle 설치 및 설정

      ```bash
      bundle install
      rails generate rspec:install
      ```

      ## 7. 데이터베이스 생성

      ```bash
      rails db:create
      rails db:migrate
      ```

      ## 8. 개발 서버 실행

      ```bash
      rails server
      ```

      브라우저에서 `http://localhost:3000`에 접속하여 확인하세요!

      ## 추천 개발 도구

      - **에디터**: VS Code, RubyMine
      - **터미널**: iTerm2 (macOS), Windows Terminal
      - **Git 클라이언트**: GitHub Desktop, SourceTree
      - **데이터베이스 툴**: TablePlus, pgAdmin

      Happy coding! 🚀
    MARKDOWN
    published: false  # 초안으로 저장
  },

  {
    title: "🎨 CSS와 Bootstrap으로 블로그 디자인하기",
    content: <<~MARKDOWN,
      # 아름다운 블로그 디자인 만들기

      좋은 디자인은 사용자 경험을 크게 좌우합니다. 이 포스트에서는 CSS와 Bootstrap을 활용해 아름다운 블로그를 만드는 방법을 알아보겠습니다.

      ## 🎯 디자인 원칙

      ### 1. 가독성 우선
      - 적절한 줄 간격 (line-height: 1.6 이상)
      - 충분한 여백 사용
      - 명확한 대비색 사용

      ### 2. 일관성
      - 통일된 컬러 팔레트
      - 일관된 타이포그래피
      - 규칙적인 간격 체계

      ### 3. 반응형 디자인
      - 모바일 우선 접근법
      - 유연한 그리드 시스템
      - 터치 친화적 인터페이스

      ## 🎨 컬러 팔레트

      ```css
      :root {
        --primary-color: #007bff;
        --secondary-color: #6c757d;
        --success-color: #28a745;
        --warning-color: #ffc107;
        --danger-color: #dc3545;
        --light-color: #f8f9fa;
        --dark-color: #343a40;
      }
      ```

      ## 📝 타이포그래피

      ### 폰트 선택
      ```css
      body {
        font-family: -apple-system, BlinkMacSystemFont, 
                     'Segoe UI', 'Roboto', 'Oxygen',
                     'Ubuntu', 'Cantarell', 'Fira Sans',
                     'Droid Sans', 'Helvetica Neue', sans-serif;
        font-size: 16px;
        line-height: 1.6;
      }
      ```

      ### 제목 스타일
      ```css
      h1, h2, h3, h4, h5, h6 {
        font-weight: 600;
        margin-bottom: 0.5rem;
        color: var(--dark-color);
      }

      h1 { font-size: 2.5rem; }
      h2 { font-size: 2rem; }
      h3 { font-size: 1.75rem; }
      ```

      ## 🖼️ 레이아웃 구성

      ### Bootstrap 그리드 활용
      ```html
      <div class="container">
        <div class="row">
          <div class="col-md-8">
            <!-- 메인 콘텐츠 -->
          </div>
          <div class="col-md-4">
            <!-- 사이드바 -->
          </div>
        </div>
      </div>
      ```

      ### 카드 컴포넌트
      ```html
      <div class="card">
        <div class="card-body">
          <h5 class="card-title">포스트 제목</h5>
          <p class="card-text">포스트 요약...</p>
          <a href="#" class="btn btn-primary">읽어보기</a>
        </div>
      </div>
      ```

      ## ✨ 인터랙션과 애니메이션

      ### 호버 효과
      ```css
      .card {
        transition: transform 0.2s ease-in-out;
      }

      .card:hover {
        transform: translateY(-5px);
        box-shadow: 0 4px 8px rgba(0,0,0,0.1);
      }
      ```

      ### 버튼 스타일링
      ```css
      .btn-custom {
        background: linear-gradient(45deg, #007bff, #0056b3);
        border: none;
        border-radius: 25px;
        padding: 10px 20px;
        color: white;
        font-weight: 500;
        transition: all 0.3s ease;
      }

      .btn-custom:hover {
        transform: scale(1.05);
        box-shadow: 0 4px 15px rgba(0,123,255,0.3);
      }
      ```

      ## 📱 반응형 디자인

      ### 미디어 쿼리 활용
      ```css
      /* 태블릿 */
      @media (max-width: 768px) {
        .container {
          padding: 0 15px;
        }
        
        h1 {
          font-size: 2rem;
        }
      }

      /* 모바일 */
      @media (max-width: 576px) {
        .card {
          margin-bottom: 1rem;
        }
        
        .btn {
          width: 100%;
        }
      }
      ```

      ## 🎨 마크다운 콘텐츠 스타일링

      ```css
      .post-content {
        font-size: 1.1rem;
        line-height: 1.8;
      }

      .post-content h2 {
        border-bottom: 2px solid #eee;
        padding-bottom: 0.5rem;
        margin-top: 2rem;
      }

      .post-content blockquote {
        border-left: 4px solid #007bff;
        padding-left: 1rem;
        margin: 1.5rem 0;
        font-style: italic;
        color: #6c757d;
      }

      .post-content code {
        background-color: #f8f9fa;
        padding: 0.2rem 0.4rem;
        border-radius: 0.25rem;
        font-size: 0.9em;
        color: #e83e8c;
      }
      ```

      ## 🚀 성능 최적화 팁

      1. **CSS 최소화**: 불필요한 스타일 제거
      2. **이미지 최적화**: WebP 포맷 사용 고려
      3. **폰트 로딩**: `font-display: swap` 사용
      4. **CDN 활용**: Bootstrap CDN 사용

      ## 접근성 고려사항

      - 적절한 색상 대비 (4.5:1 이상)
      - 키보드 네비게이션 지원
      - 스크린 리더 호환성
      - 초점 표시기 제공

      아름답고 사용자 친화적인 블로그를 만들어보세요! 🎨✨
    MARKDOWN
    published: true
  }
]

# 포스트 생성
created_count = 0
posts_data.each_with_index do |post_data, index|
  post = Post.create!(
    title: post_data[:title],
    content: post_data[:content],
    published: post_data[:published]
  )
  created_count += 1
  puts "#{index + 1}. 📝 '#{post.title}' 생성 완료 (#{post.published? ? '발행됨' : '초안'})"
end

puts "\n✅ 총 #{created_count}개의 샘플 포스트가 생성되었습니다!"
puts "🚀 rails server를 실행하고 http://localhost:3000 에서 확인해보세요!"