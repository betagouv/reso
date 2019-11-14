namespace :lint do
  desc 'run rubocop linter'
  task(:rubocop) { sh 'rubocop' }

  desc 'run haml linter'
  task(:haml) { sh 'haml-lint --report progress' }

  desc 'run i18n linter'
  task(:i18n) { sh 'i18n-tasks health' }

  desc 'run brakeman linter'
  task(:brakeman) { sh 'brakeman --quiet' }

  task all: %i[rubocop haml i18n brakeman]
end

desc 'run all linters'
task lint: %w[lint:all]
