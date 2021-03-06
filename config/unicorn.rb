worker_processes Integer(ENV['WEB_CONCURRENCY'] || 1)
timeout 15
preload_app true

listen File.expand_path('tmp/sockets/unicorn.sock', ENV['RAILS_ROOT'])
pid File.expand_path('tmp/pids/unicorn.pid', ENV['RAILS_ROOT'])

before_fork do |_, _|
  Signal.trap 'TERM' do
    Rails.logger.info('Unicorn master intercepting TERM and sending myself QUIT instead')
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |_, _|
  Signal.trap 'TERM' do
    Rails.logger.info('Unicorn worker intercepting TERM and doing nothing. ' \
                      'Wait for master to send QUIT')
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end

stderr_path File.expand_path('log/unicorn.log', ENV['RAILS_ROOT'])
stdout_path File.expand_path('log/unicorn.log', ENV['RAILS_ROOT'])
