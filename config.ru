# Rack 설정 파일
require 'rack'
require 'erb'
require 'cgi'
require_relative 'app/models/file_db'
require_relative 'app/models/simple_post'
require_relative 'app/services/markdown_renderer'

# 샘플 데이터 생성
FileDB.seed_data

class MarkdownBlogApp
  def call(env)
    request = Rack::Request.new(env)
    
    case request.path_info
    when '/'
      index_page
    when '/posts'
      if request.get?
        index_page
      elsif request.post?
        create_post(request.params)
      end
    when %r{^/posts/(\d+)$}
      post_id = $1.to_i
      show_post(post_id)
    when %r{^/posts/(\d+)/edit$}
      post_id = $1.to_i
      edit_post(post_id)
    when '/posts/new'
      new_post_page
    else
      not_found
    end
  rescue => e
    error_page(e)
  end
  
  private
  
  def index_page
    posts = SimplePost.published_recent
    
    html = erb_template('index', {
      posts: posts,
      title: '🚀 마크다운 블로그'
    })
    
    success_response(html)
  end
  
  def show_post(id)
    post = SimplePost.find(id)
    return not_found unless post
    
    html = erb_template('show', {
      post: post,
      title: post.title
    })
    
    success_response(html)
  end
  
  def new_post_page
    html = erb_template('new', {
      post: SimplePost.new,
      title: '새 포스트 작성'
    })
    
    success_response(html)
  end
  
  def create_post(params)
    post_params = params['post'] || {}
    post = SimplePost.create({
      title: post_params['title'],
      content: post_params['content'],
      published: post_params['published'] == '1'
    })
    
    redirect_response("/posts/#{post.id}")
  end
  
  def success_response(html)
    [200, {'Content-Type' => 'text/html; charset=utf-8'}, [html]]
  end
  
  def redirect_response(location)
    [302, {'Location' => location}, ['Redirecting...']]
  end
  
  def not_found
    [404, {'Content-Type' => 'text/html'}, ['<h1>404 - Page Not Found</h1>']]
  end
  
  def error_page(error)
    [500, {'Content-Type' => 'text/html'}, ["<h1>Error</h1><p>#{CGI.escapeHTML(error.message)}</p>"]]
  end
  
  def erb_template(template_name, locals = {})
    layout = File.read('app/views/layouts/application.html.erb')
    content = File.read("app/views/posts/#{template_name}.html.erb")
    
    # 간단한 ERB 렌더링
    rendered_content = simple_erb_render(content, locals)
    simple_erb_render(layout, locals.merge(content: rendered_content))
  end
  
  def simple_erb_render(template, locals = {})
    # 매우 간단한 ERB 렌더링 (실제 ERB보다 제한적)
    result = template.dup
    
    # 변수 치환
    locals.each do |key, value|
      case value
      when String
        result.gsub!(/<%=\s*#{key}\s*%>/, CGI.escapeHTML(value.to_s))
        result.gsub!(/<%= #{key} %>/, CGI.escapeHTML(value.to_s))
      when Array
        # 배열 처리는 별도로...
      else
        result.gsub!(/<%=\s*#{key}\s*%>/, value.to_s)
      end
    end
    
    # 기본 Ruby 코드 실행 (매우 제한적)
    result.gsub!(/<% if .* %>.*?<% end %>/m, '')  # 조건문 제거 (간단화)
    result.gsub!(/<%.*?%>/, '')  # 나머지 Ruby 코드 제거
    
    result
  end
end

run MarkdownBlogApp.new