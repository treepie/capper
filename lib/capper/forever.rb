after "deploy:restart", "forever:restart"
after "deploy:start", "forever:start"
after "deploy:stop", "forever:stop"

namespace :forever do
  desc <<-DESC
    Start the servers using the forever cmd If the forever cmd cannot \
    be found then you can override the forever_cmd variable to specify \
    which one it should use.
    By default index.js in the applications root folder will be used for startup.

    You can override any of these defaults by setting the variables shown below.

      set :forever_cmd,      "forever" # e.g. "./node_modules/.bin/forever"
      set :main_js,          "index.js" # e.g. "./build/main.js"
      set :node_env,         "production" # the NODE_ENV environment variable used to start the script
  DESC
  task :start, :roles => :app do
    forever_cmd     = fetch(:forever_cmd, "forever")
    main_js         = fetch(:main_js, "index.js")
    app_path        = fetch(:latest_release)
    node_env        = fetch(:node_env,'production')
    if app_path.to_s.empty?
      raise error_type.new("Cannot detect current release path - make sure you have deployed at least once.")
    end
    prefix  = fetch(:use_nave, false) ? "#{fetch(:nave_dir)}/nave.sh use #{fetch(:node_version, 'stable')}" :''
    run "cd #{app_path} && NODE_ENV=#{node_env} #{prefix} #{forever_cmd} start #{main_js}"
  end

  desc <<-DESC
    Stop the servers using the forever cmd If the forever cmd cannot \
    be found then you can override the forever_cmd variable to specify \
    which one it should use.
    By default index.js in the applications root folder will be used for startup.

    You can override any of these defaults by setting the variables shown below.

      set :forever_cmd,      "forever" # e.g. "./node_modules/.bin/forever"
      set :main_js,          "index.js" # e.g. "./build/main.js"
      set :node_env,         "production" # the NODE_ENV environment variable used to start the script
  DESC
  task :stop, :roles => :app  do
    forever_cmd     = fetch(:forever_cmd, "forever")
    main_js         = fetch(:main_js, "index.js")
    app_path        = fetch(:latest_release)
    node_env        = fetch(:node_env,'production')
    if app_path.to_s.empty?
      raise error_type.new("Cannot detect current release path - make sure you have deployed at least once.")
    end
    prefix  = fetch(:use_nave, false) ? "#{fetch(:nave_dir)}/nave.sh use #{fetch(:node_version, 'stable')}" :''
    begin
      run "cd #{app_path} && NODE_ENV=#{node_env} #{prefix} #{forever_cmd} stop #{main_js}"
    rescue Exception => error
      puts "Error stopping forever: #{error}"
    end
  end
  desc <<-DESC
    Restart the servers using the forever cmd If the forever cmd cannot \
    be found then you can override the forever_cmd variable to specify \
    which one it should use.
    By default index.js in the applications root folder will be used for startup.

    You can override any of these defaults by setting the variables shown below.

      set :forever_cmd,      "forever" # e.g. "./node_modules/.bin/forever"
      set :main_js,          "index.js" # e.g. "./build/main.js"
      set :node_env,         "production" # the NODE_ENV environment variable used to start the script
  DESC
  task  :restart  do
    transaction do
      stop
      start
    end
  end

  desc  <<-DESC
    tail the forever logfile using the forever cmd If the forever cmd cannot \
    be found then you can override the forever_cmd variable to specify \
    which one it should use.
    By default index.js in the applications root folder will be used for startup.

    You can override any of these defaults by setting the variables shown below.

      set :forever_cmd,      "forever" # e.g. "./node_modules/.bin/forever"
      set :main_js,          "index.js" # e.g. "./build/main.js"
  DESC
  task :tail do
    forever_cmd     = fetch(:forever_cmd, "forever")
    main_js         = fetch(:main_js, "index.js")
    app_path        = fetch(:latest_release)
    if app_path.to_s.empty?
      raise error_type.new("Cannot detect current release path - make sure you have deployed at least once.")
    end
    prefix  = fetch(:use_nave, false) ? "#{fetch(:nave_dir)}/nave.sh use #{fetch(:node_version, 'stable')}" :''
    resp = capture "cd #{app_path} && #{prefix} #{forever_cmd} logs | grep #{main_js}"
    #logs = resp.split("\n")[2..-1].map{|l| l.split(" " ).last.gsub(/.\[3[5,9]m/,'')}
    logs = resp.split("\n").map{|l| l.split(" " ).last.gsub(/.\[3[5,9]m/,'')}
    run "tail -n10 -f #{logs.join(" ")}"
  end
end

