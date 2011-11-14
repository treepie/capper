load "capper/ruby"

_cset(:rails_env, "production")

_cset(:asset_pipeline, true)
_cset(:asset_env, "RAILS_GROUPS=assets")
_cset(:assets_prefix, "assets")

set(:shared_children) do
  fetch(:shared_children, []) | %w(assets)
end

set(:symlinks) do
  fetch(:symlinks, {}).merge({
    "assets" => "public/#{assets_prefix}",
    "log" => "log",
    "pids" => "tmp/pids",
    "system" => "public/system",
  })
end

after 'deploy:update_code', 'rails:setup'
after 'deploy:update_code', 'rails:assets:precompile'

before 'deploy:migrate', 'rails:migrate'

namespace :rails do
  desc "Generate rails configuration and helpers"
  task :setup, :roles => :app, :except => { :no_release => true } do
    upload_template_file("rails.console.sh",
                         File.join(bin_path, "con"),
                         :mode => "0755")
  end

  desc <<-DESC
    Run the migrate rake task. By default, it runs this in most recently \
    deployed version of the app. However, you can specify a different release \
    via the migrate_target variable, which must be one of :latest (for the \
    default behavior), or :current (for the release indicated by the \
    `current' symlink). Strings will work for those values instead of symbols, \
    too. You can also specify additional environment variables to pass to rake \
    via the migrate_env variable. Finally, you can specify the full path to the \
    rake executable by setting the rake variable. The defaults are:

      set :rake,           "rake"
      set :rails_env,      "production"
      set :migrate_env,    ""
      set :migrate_target, :latest
  DESC
  task :migrate, :roles => :db, :only => { :primary => true } do
    migrate_env = fetch(:migrate_env, "")
    migrate_target = fetch(:migrate_target, :latest)

    directory = case migrate_target.to_sym
      when :current then current_path
      when :latest  then latest_release
      else raise ArgumentError, "unknown migration target #{migrate_target.inspect}"
      end

    run "cd #{directory} && #{rake} RAILS_ENV=#{rails_env} #{migrate_env} db:migrate"
  end

  namespace :assets do
    desc <<-DESC
      Run the asset precompilation rake task. You can specify the full path \
      to the rake executable by setting the rake variable. You can also \
      specify additional environment variables to pass to rake via the \
      asset_env variable. The defaults are:

        set :rake,      "rake"
        set :rails_env, "production"
        set :asset_env, "RAILS_GROUPS=assets"
    DESC
    task :precompile, :roles => [:web, :asset], :except => { :no_release => true } do
      if asset_pipeline
        run "cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile"
      end
    end

    desc <<-DESC
      Run the asset clean rake task. Use with caution, this will delete \
      all of your compiled assets. You can specify the full path \
      to the rake executable by setting the rake variable. You can also \
      specify additional environment variables to pass to rake via the \
      asset_env variable. The defaults are:

        set :rake,      "rake"
        set :rails_env, "production"
        set :asset_env, "RAILS_GROUPS=assets"
    DESC
    task :clean, :roles => [:web, :asset], :except => { :no_release => true } do
      if asset_pipeline
        run "cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:clean"
      end
    end
  end
end
