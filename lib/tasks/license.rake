begin
  desc 'Applies appropriate licenses to project'
  task :license => :environment do
    def excluded?(file)
      directoryExclusions = ['./vendor','./attachments','./doc','./externals','./doc','./message_recordings','./public/javascripts/FCBKcomplete','./public/javascripts/jquery-tooltip','./public/system']
      fileExclusions = ['schema.rb','all.js','jquery.js']

      file.sub!(Rails.root.to_s,'')

      directoryExclusions.each do |dir|
        return true if file.index(dir) == 0
      end

      fileExclusions.include?(file[(file.rindex('/')+1)..-1])
    end

    filetype = {"rb" => "ruby.txt", "erb" => "erb.txt", "js" => "javascript.txt", "css" => "css.txt", "example" => "yaml.txt", "feature" => "cucumber.txt"}

    if ARGV[1].nil?
      filetype.each do |key, value|
        Dir.glob("./**/*.#{key}") do |file|
          system("grep Affero #{file} 1> /dev/null || (cat #{Rails.root}/config/licenses/#{value} #{file} > /tmp/#{file.split('/').last} && mv /tmp/#{file.split('/').last} #{file})") unless excluded?(file)
        end
      end
    else
      file = ARGV[1]
      ext = file[(file.rindex('.')+1)..-1]
      system("grep Affero #{file} 1> /dev/null || (cat #{Rails.root}/config/licenses/#{filetype[ext]} #{file} > /tmp/#{file.split('/').last} && mv /tmp/#{file.split('/').last} #{file})")
    end
  end
end