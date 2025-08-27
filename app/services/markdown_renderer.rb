class MarkdownRenderer
  def self.render(text)
    return '' if text.blank?
    
    renderer = Redcarpet::Render::HTML.new(
      filter_html: true,
      hard_wrap: true,
      link_attributes: { target: '_blank' },
      prettify: true
    )
    
    markdown = Redcarpet::Markdown.new(
      renderer,
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      strikethrough: true,
      superscript: true,
      highlight: true,
      footnotes: true
    )
    
    # Rouge 코드 하이라이팅 적용
    html = markdown.render(text)
    apply_syntax_highlighting(html)
  end

  def self.extract_plain_text(markdown_text, limit = 150)
    return '' if markdown_text.blank?
    
    # 마크다운 문법 제거하고 플레인 텍스트 추출
    plain_text = markdown_text
      .gsub(/[#*`_~\[\]()>]/, '') # 마크다운 기호 제거
      .gsub(/\n+/, ' ')           # 줄바꿈을 공백으로
      .strip
    
    plain_text.length > limit ? plain_text[0..limit] + '...' : plain_text
  end

  private

  def self.apply_syntax_highlighting(html)
    # Rouge를 사용한 코드 하이라이팅 (간단한 구현)
    html.gsub(/<pre><code class="language-(\w+)">(.*?)<\/code><\/pre>/m) do |match|
      language = $1
      code = $2
      
      begin
        lexer = Rouge::Lexer.find(language)
        if lexer
          formatter = Rouge::Formatters::HTML.new
          highlighted = formatter.format(lexer.lex(code))
          "<pre class=\"highlight\"><code>#{highlighted}</code></pre>"
        else
          match
        end
      rescue
        match
      end
    end.html_safe
  end
end