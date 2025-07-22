# frozen_string_literal: true

require 'active_job'

module MySQL
  module Search
    module Jobs
      # Updates the search index for a given full-text searchable model based on an associated model's changes.
      class UpdaterJob < ::ActiveJob::Base
        def perform(full_text_searchable_name, associated_name, associated_id, association_path)
          associated_model = associated_name.constantize.find_by(id: associated_id)

          return if associated_model.nil?

          ::MySQL::Search::Updater.new(
            full_text_searchable: full_text_searchable_name.constantize,
            associated_model: associated_model,
            association_path: association_path
          ).update
        end
      end
    end
  end
end
