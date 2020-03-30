Sidekiq::Extensions.enable_delay!

require 'sidekiq'
require 'sidekiq/web'
Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == [Rails.application.credentials[:sidekiq_username], Rails.application.credentials[:sidekiq_password]]
end
