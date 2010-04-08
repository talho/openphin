namespace :js do
  desc "Minify javascript src for production environment"
  task :min => :environment do
    # list of files to minify
    lib = ENV['file']

    # paths to jsmin script and final minified file
    jsmin = 'script/javascript/jsmin.rb'
    final = "#{ENV['file'][0, ENV['file'].rindex('.')]}.min.js"

    # create single tmp js file
    tmp = Tempfile.open('all')
   
    open(lib) {|f| tmp.write(f.read) }
    tmp.rewind

    # minify file
    %x[ruby #{jsmin} < #{tmp.path} > #{final}]
    puts "\n#{final}"
  end
end
