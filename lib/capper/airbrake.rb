# redefine the notify task without after hooks, so we can use them in
# specific stages only.
namespace :airbrake do
  desc "Notify airbrake of the deployment"
  task :notify, :except => { :no_release => true } do
    rails_env = fetch(:airbrake_env, fetch(:rails_env, "production"))
    local_user = ENV['USER'] || ENV['USERNAME']
    executable = fetch(:rake, 'rake')
    directory = configuration.current_release

    notify_command = "cd #{directory}; #{executable} RAILS_ENV=#{rails_env} airbrake:deploy TO=#{rails_env} REVISION=#{current_revision} REPO=#{repository} USER=#{local_user}"

    logger.info "Notifying Airbrake of Deploy (#{notify_command})"
    result = ""
    run(notify_command, :once => true) { |ch, stream, data| result << data }
    logger.info "Airbrake Notification Complete."
  end
end
