# frozen_string_literal: true

namespace :mysql do
  namespace :search do
    desc 'Actualizes full text search since date. Usage: rails time_tracking:full_text_search:actualize[1.hour]'
    task :actualize, [:time_ago] => :environment do |_task, arg|
      time_ago = MySQL::Search::Utils::DurationParser.parse(arg[:time_ago], 1.hour).ago
      searchable_classes = MySQL::Search.source_classes.map(&:model)

      searchable_classes.each do |searchable_class|
        count = searchable_class.count
        print "\n#{searchable_class.name}"

        searchable_class.full_text_search_sources_updated(time_ago).find_each.with_index do |record, index|
          puts(" (#{index} / #{count})") if (index % 100).zero?
          MySQL::Search::Updater.new(full_text_searchable: record.class, associated_model: record).update
          putc '.'
        end

        puts '✅'
      end
    end
  end
end
