# frozen_string_literal: true

module MySQL
  module Search
    # Railtie for integrating MySQL::Search with Rails applications.
    class Railtie < Rails::Railtie
      railtie_name :mysql_search

      rake_tasks do
        path = File.expand_path(__dir__)
        Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
      end

      generators do
        require 'generators/mysql/search/install_generator'
      end
    end
  end
end
