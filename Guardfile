scope(groups: %w(specs))

directories %w(spec lib)

group :specs, halt_on_fail: true do
  guard :rspec, cmd: 'bundle exec rspec', failed_mode: :keep do
    require 'guard/rspec/dsl'
    dsl = Guard::RSpec::Dsl.new(self)

    # RSpec files
    rspec = dsl.rspec
    watch(rspec.spec_helper) { rspec.spec_dir }
    watch(rspec.spec_support) { rspec.spec_dir }
    watch(rspec.spec_files)

    # Ruby files
    ruby = dsl.ruby
    dsl.watch_spec_files_for(ruby.lib_files)
  end

  guard :rubocop, all_on_start: false, cli: '--rails' do
    watch(%r{.+\.rb$}) { |m| m[0] }
    watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
  end
end

# vim: ft=ruby
