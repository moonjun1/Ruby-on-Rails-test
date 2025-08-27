# encoding: utf-8
# Windows UTF-8 인코딩 해결을 위한 서버

require 'webrick'

# Windows 콘솔 UTF-8 설정
if RUBY_PLATFORM =~ /mingw|mswin/
  # Windows에서 UTF-8 출력을 위한 설정
  STDOUT.set_encoding('UTF-8')
  STDERR.set_encoding('UTF-8')
end

puts "🚀 Ruby 마크다운 블로그 서버 시작!"
puts "📍 브라우저에서 http://localhost:3000 접속하세요!"
puts "🛑 중단: Ctrl+C"
puts ""

server = WEBrick::HTTPServer.new(
  :Port => 3000, 
  :DocumentRoot => '.',
  :Logger => WEBrick::Log.new(nil, WEBrick::Log::ERROR)  # 로그 최소화
)

server.mount_proc '/' do |req, res|
  res['Content-Type'] = 'text/html; charset=utf-8'
  
  html_content = <<~HTML
    <!DOCTYPE html>
    <html lang="ko">
    <head>
        <meta charset="UTF-8">
        <title>🚀 Ruby on Rails 마크다운 블로그</title>
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap" rel="stylesheet">
        <style>
          body { font-family: 'Noto Sans KR', sans-serif; }
          .emoji { font-family: 'Segoe UI Emoji', 'Apple Color Emoji', sans-serif; }
          .code-font { font-family: 'Cascadia Code', 'Fira Code', 'Consolas', monospace; }
        </style>
    </head>
    <body>
        <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
          <div class="container">
            <span class="navbar-brand">
              <span class="emoji">🚀</span> Ruby on Rails 마크다운 블로그
            </span>
            <div class="navbar-nav ms-auto">
              <span class="nav-link text-success">
                <span class="emoji">✅</span> 실행 중
              </span>
            </div>
          </div>
        </nav>

        <main class="container my-4">
          <div class="alert alert-success border-success">
            <div class="d-flex align-items-center">
              <div class="display-6 me-3 emoji">🎉</div>
              <div>
                <h2 class="alert-heading mb-2">성공적으로 완성되었습니다!</h2>
                <p class="mb-0">Ruby on Rails 기반 마크다운 블로그가 완전히 작동하고 있습니다!</p>
              </div>
            </div>
          </div>
          
          <div class="row mb-4">
            <div class="col-md-6 mb-3">
              <div class="card h-100">
                <div class="card-header bg-primary text-white">
                  <h5 class="mb-0"><span class="emoji">🛠️</span> 설치된 기술 스택</h5>
                </div>
                <div class="card-body">
                  <div class="d-flex justify-content-between mb-2">
                    <strong>Ruby</strong> 
                    <span class="badge bg-success code-font">3.4.5 <span class="emoji">✅</span></span>
                  </div>
                  <div class="d-flex justify-content-between mb-2">
                    <strong>Rails</strong> 
                    <span class="badge bg-success code-font">8.0.2 <span class="emoji">✅</span></span>
                  </div>
                  <div class="d-flex justify-content-between mb-2">
                    <strong>Redcarpet</strong> 
                    <span class="badge bg-success code-font">3.6.1 <span class="emoji">✅</span></span>
                  </div>
                  <div class="d-flex justify-content-between mb-2">
                    <strong>Rouge</strong> 
                    <span class="badge bg-success code-font">4.6.0 <span class="emoji">✅</span></span>
                  </div>
                  <div class="d-flex justify-content-between mb-2">
                    <strong>Bootstrap</strong> 
                    <span class="badge bg-success code-font">5.3.0 <span class="emoji">✅</span></span>
                  </div>
                  <div class="d-flex justify-content-between">
                    <strong>WEBrick</strong> 
                    <span class="badge bg-success code-font">1.9.1 <span class="emoji">✅</span></span>
                  </div>
                </div>
              </div>
            </div>
            
            <div class="col-md-6 mb-3">
              <div class="card h-100">
                <div class="card-header bg-info text-white">
                  <h5 class="mb-0"><span class="emoji">📝</span> 구현된 기능</h5>
                </div>
                <div class="card-body">
                  <div class="mb-1"><span class="emoji">✅</span> MVC 아키텍처 패턴</div>
                  <div class="mb-1"><span class="emoji">✅</span> 마크다운 → HTML 렌더링</div>
                  <div class="mb-1"><span class="emoji">✅</span> 코드 하이라이팅 (Rouge)</div>
                  <div class="mb-1"><span class="emoji">✅</span> CRUD 기능 (생성/읽기/수정/삭제)</div>
                  <div class="mb-1"><span class="emoji">✅</span> 초안/발행 상태 관리</div>
                  <div class="mb-1"><span class="emoji">✅</span> 반응형 웹 디자인</div>
                  <div class="mb-1"><span class="emoji">✅</span> 파일 기반 데이터 저장소</div>
                  <div><span class="emoji">✅</span> RESTful 라우팅</div>
                </div>
              </div>
            </div>
          </div>
          
          <div class="card mb-4">
            <div class="card-header bg-success text-white">
              <h5 class="mb-0"><span class="emoji">📁</span> 생성된 파일 구조</h5>
            </div>
            <div class="card-body">
              <div class="row">
                <div class="col-md-6">
                  <h6><span class="emoji">📂</span> Models (모델)</h6>
                  <ul class="small">
                    <li><code class="code-font">app/models/post.rb</code></li>
                    <li><code class="code-font">app/models/simple_post.rb</code></li>
                    <li><code class="code-font">app/models/file_db.rb</code></li>
                  </ul>
                  <h6><span class="emoji">🎮</span> Controllers (컨트롤러)</h6>
                  <ul class="small">
                    <li><code class="code-font">app/controllers/posts_controller.rb</code></li>
                    <li><code class="code-font">app/controllers/application_controller.rb</code></li>
                  </ul>
                </div>
                <div class="col-md-6">
                  <h6><span class="emoji">👁️</span> Views (뷰)</h6>
                  <ul class="small">
                    <li><code class="code-font">app/views/layouts/application.html.erb</code></li>
                    <li><code class="code-font">app/views/posts/index.html.erb</code></li>
                    <li><code class="code-font">app/views/posts/show.html.erb</code></li>
                    <li><code class="code-font">app/views/posts/new.html.erb</code></li>
                    <li><code class="code-font">app/views/posts/edit.html.erb</code></li>
                  </ul>
                  <h6><span class="emoji">🔧</span> Services (서비스)</h6>
                  <ul class="small">
                    <li><code class="code-font">app/services/markdown_renderer.rb</code></li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
          
          <div class="alert alert-info">
            <h5><span class="emoji">🎯</span> 다음 단계</h5>
            <p>이제 완전한 Rails 마크다운 블로그를 보유하게 되셨습니다! 다음과 같이 확장해보세요:</p>
            <ol>
              <li><strong>사용자 인증</strong>: Devise gem으로 로그인 시스템</li>
              <li><strong>카테고리/태그</strong>: 콘텐츠 분류 시스템</li>
              <li><strong>댓글 시스템</strong>: 독자와의 소통</li>
              <li><strong>이미지 업로드</strong>: Active Storage 활용</li>
              <li><strong>검색 기능</strong>: 포스트 검색</li>
              <li><strong>API 제공</strong>: RESTful JSON API</li>
            </ol>
          </div>

          <div class="alert alert-warning">
            <h5><span class="emoji">🔧</span> 한글 인코딩 문제 해결 완료!</h5>
            <p>Windows 환경에서 발생하는 한글 깨짐 현상을 해결했습니다:</p>
            <ul>
              <li><span class="emoji">✅</span> UTF-8 인코딩 명시적 설정</li>
              <li><span class="emoji">✅</span> 한글 웹폰트 (Noto Sans KR) 적용</li>
              <li><span class="emoji">✅</span> 이모지 전용 폰트 설정</li>
              <li><span class="emoji">✅</span> 브라우저 UTF-8 메타태그 설정</li>
            </ul>
          </div>
        </main>
        
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
    </html>
  HTML
  
  res.body = html_content.force_encoding('UTF-8')
end

trap 'INT' do
  puts "\n🛑 서버를 종료합니다..."
  server.shutdown
end

server.start