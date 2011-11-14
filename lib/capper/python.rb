_cset(:python, "python")

after "deploy:finalize_update", "python:symlink_ns"

namespace :python do
  task :symlink_ns, :except => { :no_release => true } do
    run("ln -nfs #{latest_release}/#{application} #{latest_release}")
  end
end
