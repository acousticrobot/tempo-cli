# Load these file utility functions before the FileRecord::Record class
# These functions manage the creation of storage directory and file names,
# and check for existing directories

# Base models are saved into a directory named after the parent Module
# example Tempo::Model::Project class instances are saved into:
# Users/usrname/tempo/tempo_projects.yaml
# if a directory is passed into the initializer, they will be saved into an
# alternate directory:
# FileRecord::Utility.new directory: "custom/directory"
# project file: Users/usrname/custom/directory/tempo/tempo_projects.yaml

# Logs are saved into a subdirectory containing time stamped files
# pass time into options on init
# example Tempo::Model::Logs class instances are saved into:
# Users/usrname/tempo/tempo_logs/
# The files are given filenames based on the Logs day id (11/12/2014 -> '20141112')
# See Tempo::Model::Logs for more information

module FileRecord
  class Utility

    def initialize(model, options={})
      @model = model
      @time = options.fetch(:time, nil)
      @directory = options.fetch(:directory, Dir.home)
    end

    # split Tempo::Model::Project into ["tempo", "model", "project"]
    def split_name
      @model.new.class.to_s.split("::").each {|n| n.downcase!}
    end

    # Tempo::Model::Project -> "tempo"
    def module_name
      split_name[0]
    end

    # Tempo::Model::Project -> "project"
    def model_name
      split_name[-1]
    end

    def filename
      # return Log file name
      return "#{model.day_id( time )}.yaml" if @time

      # return Tempo::Model::Project -> tempo_projects.yaml
      sn = split_name
      file = "#{sn[0]}_#{sn[-1]}s.yaml"
    end

    # ex. Tempo::Model::Log -> tempo_logs
    def log_subdir
      sn = split_name
      "#{sn[0]}_#{sn[-1]}s"
    end

    # Tempo::Model::Log -> Users/usrname/tempo/tempo_logs/
    # Will also creates directory if not found
    def log_dirpath
      dir = File.join(@directory, module_name, log_subdir)
      Dir.mkdir(dir, 0700) unless File.exists?(dir)
      dir
    end

    # returns full path and file for model
    # ex. Tempo::Model::Log 11/12/2014 -> Users/usrname/tempo/tempo_logs/20141112.yaml
    # ex. Tempo::Model::Base -> Users/usrname/tempo/tempo_bases.yaml
    # Will also creates directory if not found
    def filepath

      return File.join(log_dirpath, filename) if @time

      dir = File.join(@directory, module_name)
      Dir.mkdir(dir, 0700) unless File.exists?(dir)
      File.join(dir, filename)
    end
  end
end
