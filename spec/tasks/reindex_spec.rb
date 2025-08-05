# frozen_string_literal: true

RSpec.describe 'rake mysql:search:reindex' do # rubocop:disable RSpec/DescribeClass
  let(:task_name) { 'mysql:search:reindex' }
  let(:task) { Rake::Task[task_name] }

  before do
    Rake.application.rake_require('tasks/mysql/search/reindex')
    Rake::Task.define_task(:environment)
  end

  after do
    task.reenable
  end

  it 'is defined' do
    expect(Rake::Task.task_defined?(task_name)).to be true
  end

  it 'executes without errors' do
    expect { task.invoke('Article') }.not_to raise_error
  end
end
