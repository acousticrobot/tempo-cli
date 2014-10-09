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
# The files are given filenames based on the Logs day id (11/12/2014 -> '20141112.yaml')
# See Tempo::Model::Logs for more information

module FileRecord
  class FileUtility

    def initialize(model, options={})
      @model = model
      @time = options.fetch(:time, nil)
      @directory = options.fetch(:directory, Dir.home)

      # options to allow for file creation and destruction,
      # default to false so that file path enquiries can't
      # change the directory structure
      @create = options.fetch( :create, false )
      @destroy = options.fetch( :destroy, false )
    end

    def save_instances_to_file(instances)

      File.open( file_path,'a' ) do |f|
        instances.each do |i|
          f.puts YAML::dump( i.freeze_dry )
        end
      end
    end

    # split Tempo::Model::Project into ["tempo", "model", "project"]
    # split Tempo::Model::TimeRecord into ["tempo", "model", "time_record"]
    def split_name
      @model.name.to_s.split("::").each {|n| n.gsub!(/([a-z])([A-Z])/, '\1_\2'); n.downcase!}
    end

    # Tempo::Model::Project -> "tempo"
    def module_name
      split_name[0]
    end

    # Tempo::Model::Project -> "project"
    def model_name
      split_name[-1]
    end

    # Tempo::Model::Log on 12/1/2015 -> 20151201.yaml
    # Tempo::Model::Base -> tempo_bases.yaml
    def filename
      # return Log file name
      return "#{@model.day_id( @time )}.yaml" if @time

      sn = split_name
      file = "#{sn[0]}_#{sn[-1]}s.yaml"
    end

    # ex. Tempo::Model::Log -> tempo_logs
    def log_directory
      sn = split_name
      "#{sn[0]}_#{sn[-1]}s"
    end


    def log_year_directory
      if @time.kind_of? Time
        @time.strftime("%Y")
      else
        @time[0..3]
      end
    end

    # Tempo::Model::Log -> Users/usrname/(alternate_directory/)tempo/tempo_logs'
    # Will also create the directory if not found
    def log_main_directory_path
      dir = File.join(@directory, module_name, log_directory)
    end

    # Tempo::Model::Log -> Users/usrname/(alternate_directory/)tempo/tempo_logs/20XX
    # Will also create the directory if not found
    def log_directory_path
      dir = File.join(log_main_directory_path, log_year_directory)

      if @create and !File.exists?(dir)
        FileUtils.mkdir_p dir
      end

      dir
    end

    # returns full path and file for model
    # Tempo::Model::Log on 11/12/2014 -> Users/usrname/tempo/tempo_logs/20141112.yaml
    # Tempo::Model::Base -> Users/usrname/tempo/tempo_bases.yaml
    # Will also create directory if not found and passed create:true in options
    # Will destroy file if passed destroy:true in options
    def file_path

      return clean_path(File.join(log_directory_path, filename)) if @time

      dir = File.join(@directory, module_name)

      if @create and !File.exists?(dir)
        Dir.mkdir(dir, 0700)
      end

      clean_path File.join(dir, filename)
    end

    # Returns the list of log records from a log directory
    def log_records
      records = []
      return records if !File.exists?(log_main_directory_path)
      years = Pathname.new(log_main_directory_path).children.select { |c| c.directory? }
      years.each do |dir|
        records = records | Dir[dir.to_s + "/*.yaml"]
      end
      records.sort!
    end

    # remove existing file when passed destroy:true in options
    def clean_path(file_path)

      if @destroy and File.exists?(file_path)
        File.delete(file_path)
      end

      file_path
    end
  end
end
