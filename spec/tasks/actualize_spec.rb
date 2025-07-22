# frozen_string_literal: true

RSpec.describe 'rake mysql:search:actualize' do # rubocop:disable RSpec/DescribeClass
  let(:task_name) { 'mysql:search:actualize' }
  let(:task) { Rake::Task[task_name] }

  before do
    Rake.application.rake_require('tasks/actualize')
    Rake::Task.define_task(:environment)
  end

  after do
    task.reenable
  end

  it 'is defined' do
    expect(Rake::Task.task_defined?(task_name)).to be true
  end

  it 'executes without errors' do
    expect { task.invoke('1.day') }.not_to raise_error
  end
end
