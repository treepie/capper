load "capper/python"

after 'deploy:update_code', 'django:setup', 'django:local_settings'

before 'deploy:migrate', 'django:migrate'

namespace :django do
  desc "Generate django configuration and helpers"
  task :setup, :roles => :app, :except => { :no_release => true } do
    upload_template_file("manage.py",
                         File.join(bin_path, "manage.py"),
                         :mode => "0755")
  end

  desc <<-DESC
    Run the syncdb and migratedb task. By default, it runs this in most recently \
    deployed version of the app. However, you can specify a different release \
    via the migrate_target variable, which must be one of :latest (for the \
    default behavior), or :current (for the release indicated by the \
    `current' symlink). Strings will work for those values instead of symbols, \
    too.
  DESC
  task :migrate, :roles => :db, :only => { :primary => true } do
    migrate_target = fetch(:migrate_target, :latest)

    directory = case migrate_target.to_sym
      when :current then current_path
      when :latest  then latest_release
      else raise ArgumentError, "unknown migration target #{migrate_target.inspect}"
      end

    run "cd #{directory} && #{python} manage.py syncdb --migrate --noinput"
  end
  
  task "local_settings", :role => :web do
    config_file = "config/deploy/local_settings.py.erb"
    unless File.exists?(config_file)
      config_file = File.join(File.dirname(__FILE__), "../../generators/capistrano/django/templates/_local_settings.py.erb")
    end
    config = ERB.new(File.read(config_file)).result(binding)
    set :user, sudo_user
    put config, "/tmp/local_settings.py"
    run "#{sudo} mv /tmp/local_settings.py #{latest_release}"
  end
end
