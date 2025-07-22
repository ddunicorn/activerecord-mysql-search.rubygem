# frozen_string_literal: true

ActiveRecord::Migration.suppress_messages do
  ActiveRecord::Migration.create_table :articles, force: true do |t|
    t.string :title, null: false
    t.text :content, null: false
    t.references :news_digest

    t.timestamps
  end

  ActiveRecord::Migration.create_table :news_digests, force: true do |t|
    t.string :title, null: false
    t.string :summary, null: false
    t.datetime :published_at

    t.timestamps
  end

  ActiveRecord::Migration.create_table :search_indices, force: true do |t|
    t.text :content, null: false
    t.references :searchable, polymorphic: true, null: false

    t.index :content, type: :fulltext
  end
end
