
begin
  task :phin_plugins do
    phin_plugins = YAML.load_file("config/phin_plugins.yml")
    phin_plugins.each do |pp|
      cmds = Array.new
      name = File.basename(pp["url"]).sub(/\.git$/, "")
      branch = pp["branch"] || "master"
      
      unless File.exists?("vendor/extensions/#{name}")
        cmds << "git clone #{pp["url"]} --branch #{branch} vendor/extensions/#{name}"
      end
      cmds << "cd vendor/plugins/#{name}"
      if pp.has_key?("commit")
        cmds << "git checkout #{pp["commit"]}"
      elsif File.exists?("vendor/extensions/#{name}")
        cmds << "git checkout #{branch}"
        cmds << "git pull"
      end
      sh cmds.join(" && ")
    end
  end
end