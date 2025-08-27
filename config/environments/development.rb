Rails.application.configure do
  # 개발 환경 설정
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true
  
  # 캐시 설정
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end
  
  # 정적 파일 서빙
  config.public_file_server.enabled = true
  
  # Active Storage 설정 (필요 시)
  # config.active_storage.variant_processor = :mini_magick
  
  # 로깅 설정
  config.log_level = :debug
  
  # Action Mailer 설정 (사용하지 않음)
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false
  
  # 자산 디버깅
  config.assets.debug = true
  config.assets.quiet = true
  
  # 파일 감시자
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
end