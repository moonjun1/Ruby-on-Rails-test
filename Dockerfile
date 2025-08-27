# Dockerfile - Docker로 마크다운 블로그 실행
FROM ruby:3.2

# 작업 디렉토리 설정
WORKDIR /app

# Gemfile 복사 및 의존성 설치
COPY Gemfile Gemfile.lock ./
RUN bundle install

# 애플리케이션 파일 복사
COPY . .

# 데이터베이스 설정
RUN rails db:create db:migrate db:seed

# 포트 노출
EXPOSE 3000

# 서버 실행
CMD ["rails", "server", "-b", "0.0.0.0"]