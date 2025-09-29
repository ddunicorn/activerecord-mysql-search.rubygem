# ActiveRecord MySQL Search

[![Checks](https://github.com/ddunicorn/activerecord-mysql-search.rubygem/actions/workflows/main.yml/badge.svg)](https://github.com/ddunicorn/activerecord-mysql-search.rubygem/actions/workflows/main.yml)

A Ruby gem that provides efficient full-text search capabilities for ActiveRecord models using MySQL's native full-text search features. This gem simplifies the process of making your models searchable by automatically indexing specified fields and providing intuitive search methods.

## How It Works

The gem creates a dedicated `search_indices` table that stores denormalized, searchable content extracted from your ActiveRecord models. When you define a search schema, the gem automatically copies and transforms data from your source models (e.g., `articles`, `products`) into optimized text columns with MySQL FULLTEXT indexes. This design delivers **fast search performance** by avoiding complex JOINs across multiple tables during queries, while **automatic synchronization** keeps the search index current when your source data changes. The gem handles the complexity of data extraction, formatting, and index maintenance, so you get scalable full-text search without manual SQL or external search services.

## Features

- 🚀 **Native MySQL Full-Text Search**: Fast, relevant searches using MySQL `FULLTEXT` indexes.
- 🔄 **Automatic & Background Indexing**: Keeps search data up-to-date with synchronous or ActiveJob-powered background updates.
- 📝 **Declarative Search Schema**: Easily specify indexed fields, including nested associations, dates, calendar weeks, or custom logic via `Proc` in dedicated source classes.
- 👥 **Multi-Role & Context-Aware Search**: Define separate search columns for different user roles (e.g., buyer, seller, admin) to support multi-tenant apps and data privacy.
- 🧹 **Separation of Concerns**: Move indexing logic and field formatting out of models for cleaner, more maintainable code.
- ⚡ **Easy Rails Integration**: Includes generators for setup, migrations, and rake tasks for bulk reindexing.
- 🧩 **Flexible Field Mapping**: Supports complex data structures and custom extraction for precise indexing.
- 🎯 **Customizable Search Scopes**: Search specific columns based on user context or application needs.

## Requirements

- Ruby >= 3.1.0
- Rails (supports versions 7.0+)
- MySQL database with FULLTEXT index support

## Implementing Full-Text Search in 5 Minutes

### Step 1: Install the Gem

Add to your `Gemfile`:

```ruby
gem 'activerecord-mysql-search'
```

And:

```bash
bundle install
```

### Step 2: Generate Configuration and Migrations

Run:

```bash
rails generate mysql:search:install
```

This creates:
- `config/initializers/mysql_search.rb`: Search configuration.
- `app/models/search_index.rb`: Search index model.
- A migration to create `search_indices` table.

### Step 3: Run the Migration

```bash
rails db:migrate
```

### Step 4: Enable Search in Your Model

Add to your model (e.g., `Article`):

```ruby
class Article < ApplicationRecord
  include MySQL::Search::Searchable
  belongs_to :news_digest
end
```

### Step 5: Define the Indexing Schema (Source Class)

Create `app/search_sources/article_source.rb`:

```ruby
class ArticleSource < MySQL::Search::Source
  schema content: {
    title: :text,
    content: :text,
    type: ->(value) { I18n.t("article.types.#{value}") },
    news_digest: {
      title: :text,
      published_at: [:date, :calendar_week]
    }
  }
end
```

#### Available Formatters

- **`:text`** - Extracts text content from the field
- **`:date`** - Formats dates using the configured date format (e.g., "12.01.2025", format is configurable)
- **`:calendar_week`** - Extracts calendar week information (e.g., "week 42", format is configurable)
- **`Proc`** - Custom extraction logic with access to the attribute value
- **Nested Associations** - Supports nested associations

#### Registering new formatters

You can register new formatters using the `register_format` method:

```ruby
MySQL::Search.configure do |config|
  config.register_format(:upcase) { |value| value.to_s.upcase }
end
```

### Step 6: Index Existing Data

```bash
rails mysql:search:reindex
```

This command populates the `search_indices` table with existing data from your model(s), using the schema defined in your source class.

### Step 7: Use Search in Controllers or Services

```ruby
results = Article.full_text_search("Ruby on Rails")
```

**That’s it!** Users now get fast, scalable, and relevant search—no complex SQL, external services, or maintenance headaches.

## Advanced Scenarios: Multi-Column Search for Roles and Contexts

Real projects rarely need "single-column search." Business logic often requires showing different data to different users, supporting flexible filters, and ensuring privacy. `activerecord-mysql-search` supports this out of the box. For example, clients, sellers, and admins each need their own "view of the world." The gem lets you create separate indexes per role:

```ruby
class ProductSource < MySQL::Search::Source
  schema content: {
    name: :text,
    description: :text,
    brand: :text,
    reviews: { content: :text, rating: :text }
  },
  # Extra information for seller's search
  seller_extra: {
    sku: :text,
    internal_notes: :text,
    supplier: { name: :text, contact_info: :text },
  },
  # Even more detailed information for admin's search
  admin_extra: {
    created_by: { name: :text, email: :text }
  }
end
```

Add columns and indexes to `SearchIndex`:

```ruby
class ExtraContentForSearchIndices < ActiveRecord::Migration[7.1]
  def change
    add_column :search_indices, :seller_extra, :text
    add_column :search_indices, :admin_extra, :text

    add_index :search_indices, [:content, :seller_extra], type: :fulltext
    add_index :search_indices, [:content, :seller_extra, :admin_extra], type: :fulltext
  end
end
```

Now, sellers search with:

```ruby
results = Product.full_text_search("Ruby on Rails", search_column: [:content, :seller_extra])
```

Admins use:

```ruby
results = Product.full_text_search("Ruby on Rails", search_column: [:content, :seller_extra, :admin_extra])
```

You can completely separate search contexts for different roles. In this case, there is no need to create combined indexes, just use different columns and separate indexes for each role.

### What if I use methods that don't trigger ActiveRecord callbacks?

Using `#update_column` and other methods that don't trigger ActiveRecord callbacks can lead to search index desynchronization. Solution: use `#update` or `#save` to update records to ensure indexes remain current. If you don't have this option, the gem provides the following tool to maintain index consistency.

In this case, the gem relies on the `updated_at` column. You can delegate keeping this column up-to-date to the database itself using a trigger. Create a migration using the generator:

```bash
rails generate mysql:search:create_triggers
```

This migration will create a trigger in each table that will update the `updated_at` column when records are modified, and will also add a monkey-patch to ActiveRecord's `#timestamps` method in migrations (to automatically add this trigger to future tables). This allows maintaining search index relevance using one or more of the following tools:

- Rake task `rails mysql:search:actualize[1.hour]` - periodically checks and updates indexes, syncing them with the current database state. You can configure it to run via cron.
- `MySQL::Search::Jobs::ScheduledUpdaterJob` - a background job that periodically checks and updates indexes. Example for Solid Queue:

```ruby
  # config/recurring.yml
  actualize_search_indices:
    class: MySQL::Search::Jobs::ScheduledUpdaterJob
    args: [:daily]
    schedule: every day at noon
```

- Full reindexing via rake task `mysql:search:reindex` - if you want to completely refresh index content, for example after migrations or schema changes. In this case, adding SQL triggers isn't required. You can also use this task to reindex specific models by passing their names as arguments, e.g., `rails mysql:search:reindex[Article]`.

## Configuration

Configure the gem in `config/initializers/mysql_search.rb`:

```ruby
MySQL::Search.configure do |config|
  # Model class name for search indices (default: 'SearchIndex')
  config.search_index_class_name = 'SearchIndex'

  # Path to search source classes (default: 'app/search_sources')
  config.sources_path = 'app/search_sources'

  # Automatically load source classes on Rails startup (default: true)
  # Loading of source classes assigns callbacks to the target models
  # to keep the search index updated. In case of loading issue you can load
  # the source classes manually with `MySQL::Search.load_source_classes!`
  # and disable automatic initialization.
  config.autoload_sources = true

  # Automatically update search index when models change (default: true)
  config.automatic_update = true

  # Process index updates asynchronously (default: false)
  config.update_asyncronously = false

  # Date format for date fields (default: '%d.%m.%Y')
  config.date_format = '%d.%m.%Y'

  # Calendar week format (default: 'week %V')
  config.calendar_week_format = 'week %V'

  # Register custom formatters
  config.register_format(:upcase) { |value| value.to_s.upcase }
end
```

### MySQL FULLTEXT Limitations

- **Minimum word length**: MySQL ignores words shorter than 4 characters by default (`ft_min_word_len`)
- **Stop words**: Common words like "the", "and", "or" are ignored
- **Memory usage**: FULLTEXT indexes can be memory-intensive for large datasets

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ddunicorn/activerecord-mysql-search.rubygem
