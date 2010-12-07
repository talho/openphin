require 'fileutils'
class CreateThumbAndTinyProfileImages < ActiveRecord::Migration
  def self.up
    originals = Dir['public/system/photos/*/original/*']
    originals.each do |o|
      fullpath = o.split('/')
      basedir =  File.join(fullpath[0], fullpath[1], fullpath[2])
      thumbdir = File.join(basedir,fullpath[3],'thumb')
      thumbpath = File.join(thumbdir,fullpath[5])
      tinydir = File.join(basedir,fullpath[3],'tiny')
      tinypath = File.join(tinydir,fullpath[5])

       # make thumbs (100x100)
      unless File.exists?(thumbpath)
        # FILEUTILS MAKE THUMBS DIR
        unless FileTest::directory?(thumbdir)
          puts "making dir " + thumbdir
          Dir.mkdir(thumbdir)
        end
        puts   "creating   " + thumbpath
        %x( convert -thumbnail 100x100 #{o} #{thumbpath} )
      end

      # make tiny (50x50)
      unless File.exists?(tinypath)
        # FILEUTILS MAKE THUMBS DIR
        unless FileTest::directory?(tinydir)
          puts "making dir " + tinydir
          Dir.mkdir(tinydir)
        end
        puts   "creating   " + tinypath
        %x( convert -thumbnail 50x50 #{o} #{tinypath} )
      end
    end
  end

  def self.down
    thumbdirs = Dir['public/system/photos/*/thumb']
    thumbdirs.each do | d |
      puts "deleting " + d
      FileUtils.rm_rf(d)
    end
    tinydirs = Dir['public/system/photos/*/tiny']
    tinydirs.each do | d |
      puts "deleting " + d
      FileUtils.rm_rf(d)
    end
  end
end
