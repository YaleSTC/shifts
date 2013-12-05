class CustomLogger < Rails::Rack::Logger
  def initialize(app, opts = {})
    @app = app
    @opts = opts
    @opts[:silenced] ||= ["#{Rails.application.config.action_controller.relative_url_root}/status"]
    super(app)
  end

  def call(env)
    if env['X-SILENCE-LOGGER'] || @opts[:silenced].include?(env['PATH_INFO'])
      Rails.logger.silence do
        @app.call(env)
      end
    else
      super(env)
    end
  end
end