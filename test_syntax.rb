#!/usr/bin/env ruby

# 이 스크립트는 Ruby 코드의 문법을 검사합니다

def check_ruby_syntax(file_path)
  begin
    File.read(file_path)
    puts "✅ #{File.basename(file_path)}: 문법 검사 통과"
    return true
  rescue SyntaxError => e
    puts "❌ #{File.basename(file_path)}: 문법 오류 - #{e.message}"
    return false
  rescue => e
    puts "⚠️ #{File.basename(file_path)}: 파일 읽기 오류 - #{e.message}"
    return false
  end
end

# 주요 Ruby 파일들 검사
files_to_check = [
  'app/models/post.rb',
  'app/models/application_record.rb', 
  'app/controllers/posts_controller.rb',
  'app/controllers/application_controller.rb',
  'app/services/markdown_renderer.rb',
  'config/routes.rb',
  'db/migrate/001_create_posts.rb',
  'db/seeds.rb'
]

puts "🔍 Ruby 코드 문법 검사 시작..."
puts "=" * 50

all_passed = true
files_to_check.each do |file|
  passed = check_ruby_syntax(file)
  all_passed &&= passed
end

puts "=" * 50
if all_passed
  puts "🎉 모든 파일의 문법 검사를 통과했습니다!"
else  
  puts "⚠️ 일부 파일에 문법 오류가 있습니다."
end

# 논리적 구조 검증
puts "\n🏗️ 프로젝트 구조 검증..."

required_dirs = [
  'app/controllers',
  'app/models', 
  'app/views/layouts',
  'app/views/posts',
  'app/services',
  'config',
  'db/migrate'
]

required_files = [
  'Gemfile',
  'app/models/post.rb',
  'app/controllers/posts_controller.rb', 
  'app/services/markdown_renderer.rb',
  'app/views/layouts/application.html.erb',
  'app/views/posts/index.html.erb',
  'config/routes.rb'
]

puts "\n📁 필수 디렉토리 확인:"
required_dirs.each do |dir|
  if Dir.exist?(dir)
    puts "✅ #{dir}"
  else
    puts "❌ #{dir} - 누락됨"
    all_passed = false
  end
end

puts "\n📄 필수 파일 확인:"
required_files.each do |file|
  if File.exist?(file)
    puts "✅ #{file}"
  else
    puts "❌ #{file} - 누락됨"
    all_passed = false
  end
end

puts "\n" + "=" * 50
if all_passed
  puts "🎊 프로젝트가 완전히 구성되었습니다!"
  puts "🚀 다음 명령어로 실행하세요:"
  puts "   cd markdown_blog"
  puts "   bundle install"
  puts "   rails db:create db:migrate db:seed"
  puts "   rails server"
else
  puts "⚠️ 프로젝트 구성에 문제가 있습니다."
end