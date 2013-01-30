#
# Generator for new rails apps.
#
# Created by payton.
#

module Thor::Actions
  def source_paths
    [File.dirname(__FILE__)]
  end
end

create_file ".ruby-version", "1.9.3@#{app_name}"

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

# create database
append_to_file "db/seeds.rb" do
  <<-eos
#User.find_or_create_by_email :email => ENV['ADMIN_EMAIL'].dup, :password => ENV['ADMIN_PASSWORD'].dup, :password_confirmation => Time.now
  eos
end
rake "db:create", :env => 'development'

generate 'simple_form:install --bootstrap'

# setup testing
generate 'rspec:install'
inject_into_file 'spec/spec_helper.rb', "\nrequire 'factory_girl'", :after => "require 'rspec/rails'"
inject_into_file 'config/application.rb', :after => "config.filter_parameters += [:password]" do
  <<-eos
    
    # Customize generators
    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.view_specs false
      g.helper_specs false
    end
  eos
end
remove_dir 'test'
run "echo '--format documentation' >> .rspec"

# bootstrap layout.
remove_dir 'app/views/layouts'
directory 'lib/templates/haml/layouts', 'app/views/layouts'
directory 'lib/assets/stylesheets', 'app/assets/stylesheets'

# bootstrap scaffolding.
remove_dir 'lib/templates/haml/scaffold'
directory 'lib/templates/haml/scaffold'
generate 'scaffold_controller', 'user', 'email:string', 'password:string'
route "resources :users"

# authentication and authorization setup
generate "devise:install"
generate "devise User"
rake "db:migrate"

# set up mailer
inject_into_file 'config/environments/development.rb', after: "config.assets.debug = true" do
  <<-eos


  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  ActionMailer::Base.smtp_settings = {
    :address  => "smtp.gmail.com",
    :port  => 587,
    :authentication  => :plain,
    :domain => ENV['GMAIL_SMTP_USER'],
    :user_name  => ENV['GMAIL_SMTP_USER'],
    :password  => ENV['GMAIL_SMTP_PASSWORD']
  }
  eos
end
inject_into_file 'config/environments/test.rb', after: "config.active_support.deprecation = :stderr" do
  <<-eos


  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  eos
end
inject_into_file 'config/environments/production.rb', after: "config.active_support.deprecation = :notify" do
  <<-eos

  # Configure mailer.
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  ActionMailer::Base.smtp_settings = {
    :address  => "smtp.gmail.com",
    :port  => 587,
    :authentication  => :plain,
    :domain => ENV['GMAIL_SMTP_USER'],
    :user_name  => ENV['GMAIL_SMTP_USER'],
    :password  => ENV['GMAIL_SMTP_PASSWORD']
  }
  eos
end
create_file "config/application.yml" do
  <<-eos
SITE_TITLE: 'My Site'
GMAIL_SMTP_USER:
GMAIL_SMTP_PASSWORD:
  eos
end
run 'cp config/application.yml config/application.example.yml'
run "echo 'config/application.yml' >> .gitignore"
say "Email is configured to use Gmail. Make sure to edit and configure config/application.yml"


# create home
generate "controller", "home", "index"
route "root to: 'home#index'"

# clean up rails defaults
remove_file 'public/index.html'
remove_file 'public/images/rails.png'
run 'cp config/database.yml config/database.example.yml'
run "echo 'config/database.yml' >> .gitignore"

# commit to git
git :init
git :add => "."
git :commit => "-a -m 'create initial application'"

say <<-eos
  ============================================================================
  Your new Rails application is ready to go.

  Make sure to edit and configure config/application.yml for your mailer.
eos
