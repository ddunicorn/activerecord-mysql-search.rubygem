# frozen_string_literal: true

namespace :mysql do
  namespace :search do
    desc 'Reindex Search Data for all or Single Model. Usage: rails time_tracking:full_text_search:reindex[TimeTracking::WorkingPeriod]'
    task :reindex, [:class_name] => :environment do |_task, arg|
      searchable_classes = if arg[:class_name].present?
                             [arg[:class_name].constantize]
                           else
                             print 'Are you sure you want to reindex all data? (y/n): '
                             exit unless $stdin.gets.chomp.include?('y')

                             MySQL::Search.source_classes.map(&:model)
                           end

      searchable_classes.each do |searchable_class|
        count = searchable_class.count
        print "\n#{searchable_class.name}"

        searchable_class.find_each.with_index do |record, index|
          puts(" (#{index} / #{count})") if (index % 100).zero?
          MySQL::Search::Updater.new(full_text_searchable: record.class, associated_model: record).update
          putc '.'
        end

        puts '✅'
      end
    end
  end
end
