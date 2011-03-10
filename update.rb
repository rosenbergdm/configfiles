#!/usr/bin/env ruby
# encoding: utf-8
# update.rb
# 
# configfiles.git

$REPO_ROOT = File.dirname(__FILE__)
$MANIFEST_FILE = File.join([File.dirname(__FILE__), 'manifest.yaml'])
$HOME = ENV["HOME"]
$LOGFILE = File.join([File.dirname(__FILE__), 'updates.log'])


require 'yaml'
require 'diff/lcs'
require 'diff/lcs/string'

class ConfigUpdater

  def initialize(cfg)
    @config = cfg
  end

  def self.run_update
    cfg = YAML::load(File.open($MANIFEST_FILE))
    conf_updater = ConfigUpdater.new cfg
    conf_updater.update_all
    return conf_updater
  end

  def update_all
    @config["HOME"].each do |fname|
      local_file = File.join([$HOME, fname])
      repo_file = File.join([$REPO_ROOT, 'HOME', fname])
      update_file repo_file, local_file
    end

    @config["ETC"].each do |fname|
      local_file = File.join(['/etc', fname])
      repo_file = File.join([$REPO_ROOT, 'ETC', fname])
      update_file repo_file, local_file
    end
  end

  def update_file(repo_file, local_file)
    if File.directory? repo_file
      update_dir repo_file, local_file
    else
      f1 = File.read(repo_file)
      f2 = File.read(local_file)
      if f1 != f2
        diffs = Diff::LCS.diff(f1, f2)
        f1_new = Diff::LCS.patch!(f1, diffs)
        outfile = File.open(repo_file, 'w')
        outfile.puts f1_new
        outfile.close

        logfile = File.open($LOGFILE, 'a')
        logfile.puts "#{Date.today.to_s}: #{repo_file} : #{diffs.to_s}\n"
        logfile.close
      end
    end
  end
    
  def update_dir(repo_dir, local_dir)
    flist = Dir.entries(local_dir).find_all { |f| (f != '.') && (f != '..') }
    flist.each do |fname|
      repo_file = File.join([repo_dir, fname])
      local_file = File.join([local_dir, fname])
      if File.directory? local_file
        if !(File.exists?(repo_file))
          Dir.mkdir repo_file
        end
        update_dir repo_file, local_file
      elsif !(File.exists? repo_file)
        outfile = File.open(repo_file, 'w')
        outfile.print(File.read(local_file))
        outfile.close
        logfile = File.open($LOGFILE, 'a')
        logfile.puts "#{Date.today.to_s}: #{repo_file}: Added to repository"
        logfile.close
      else
        update_file(repo_file, local_file)
      end
    end
  end

end

if $0 == __FILE__
  ConfigUpdater.run_update
end
