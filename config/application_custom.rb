module Consul
  class Application < Rails::Application
    config.i18n.default_locale = 'es-PE'
    config.i18n.available_locales = ['es-PE']
  end
end
