_cset(:python, "python")

after "deploy:finalize_update" do
  run("ln -nfs #{latest_release}/#{application} #{latest_release}")
end
