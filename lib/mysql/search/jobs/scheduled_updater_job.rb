# frozen_string_literal: true

require 'active_job'

module MySQL
  module Search
    module Jobs
      # Periodically updates search indices
      class ScheduledUpdaterJob < ::ActiveJob::Base
        PERIODS = {
          daily: ->(searchable) { searchable.where(updated_at: 1.day.ago..) },
          weekly: ->(searchable) { searchable.where(updated_at: 1.week.ago..) },
          monthly: ->(searchable) { searchable.where(updated_at: 1.month.ago..) },
          all: ->(searchable) { searchable.all }
        }.with_indifferent_access

        def perform(period)
          searchable_classes.each do |searchable_class|
            seachables(searchable_class, period).find_in_batches do |searchables|
              searchable_class.transaction do
                searchables.each { |searchable| update(searchable_class, searchable) }
              end
            end
          end
        end

        private

        def searchable_classes
          ::MySQL::Search.source_classes.map(&:model)
        end

        def seachables(searchable_class, period)
          PERIODS[period].call(searchable_class)
        end

        def update(searchable_class, searchable)
          ::MySQL::Search::Updater.new(full_text_searchable: searchable_class, associated_model: searchable).update
        end
      end
    end
  end
end
