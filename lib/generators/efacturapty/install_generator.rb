require "rails/generators"

module Efacturapty
  module Generators
    # Copies an initializer template to config/initializers/efacturapty.rb.
    #
    #   rails generate efacturapty:install
    #
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Creates an Efacturapty initializer in config/initializers."

      def copy_initializer
        template "efacturapty.rb", "config/initializers/efacturapty.rb"
      end
    end
  end
end
