#create_file ".rvmrc", "rvm gemset use #{app_name}"

gem 'rails', '3.2.11'
gem 'sqlite3', group: [:development, :test]
gem 'pg', group: :production
gem 'sass-rails',   '~> 3.2.3'
gem 'coffee-rails', '~> 3.2.1', group: :assets
gem 'uglifier', '>= 1.0.3', group: :assets
gem 'devise'
gem 'bootstrap-sass'
gem 'bootstrap-generators', '~> 2.1'
gem 'simple_form'
gem 'jquery-rails'
gem "thin", ">= 1.5.0"
gem "haml", ">= 3.1.7"
gem "haml-rails", ">= 0.3.5", :group => :development
gem "hpricot", ">= 0.8.6", :group => :development
gem "ruby_parser", ">= 3.1.1", :group => :development
gem "rspec-rails", ">= 2.11.4", :group => [:development, :test]
gem "capybara", ">= 2.0.1", :group => [:development, :test]
gem "database_cleaner", ">= 0.9.1", :group => :test
gem "email_spec", ">= 1.4.0", :group => :test
gem "factory_girl_rails", ">= 4.1.0", :group => [:development, :test]
gem "quiet_assets", ">= 1.0.1", :group => :development
gem "figaro", ">= 0.5.0"
gem "better_errors", ">= 0.3.2", :group => :development
gem "binding_of_caller", ">= 0.6.8", :group => :development

run 'bundle install --without production'

rake "db:create", :env => 'development'

generate 'simple_form:install --bootstrap'
generate 'rspec:install'
inject_into_file 'spec/spec_helper.rb', "\nrequire 'factory_girl'", :after => "require 'rspec/rails'"
inject_into_file 'config/application.rb', :after => "config.filter_parameters += [:password]" do
  <<-eos
    
    # Customize generators
    config.generators do |g|
      g.stylesheets false
      g.form_builder :simple_form
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    end
  eos
end
run "echo '--format documentation' >> .rspec"

# FIXME: this does not generate the form, complaining of simple_form error.
generate 'scaffold_controller', 'user'
route "resources :users"

# authentication and authorization setup
generate "devise:install"
generate "devise User"
rake "db:migrate"

# clean up rails defaults
remove_file 'public/index.html'
remove_file 'rm public/images/rails.png'
run 'cp config/database.yml config/database.example'
run "echo 'config/database.yml' >> .gitignore"

# commit to git
git :init
git :add => "."
git :commit => "-a -m 'create initial application'"

say <<-eos
  ============================================================================
  Your new Rails application is ready to go.
eos
