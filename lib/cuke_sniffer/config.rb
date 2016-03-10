require 'yaml'
module CukeSniffer
  ##
  # The Config class is used to control options for running cuke sniffer, these
  # options come from three sources, command line, yaml config file, or defaults.
  class Config

    # File locations, these are primarily used by CLI to build up the file sets
    # we're checking.
    attr_accessor :features_location, :step_definitions_location, :hooks_location, :project_location

    # Used by the CLI to determine if it should catalog steps to check for dead
    # steps.
    attr_accessor :cataloged

    # Used by bin/cuke_sniffer to determine what/how it should output results.
    attr_accessor :output_file, :output_format

    def initialize(parameters = {})
      raw_config = initialize_raw_config(parameters)
      initialize_source_paths(parameters, raw_config)
      initialize_cataloged(parameters, raw_config)
      initialize_output(parameters, raw_config)
    end

    private

    # Given cli parameters, initialize the raw config fiel from YAML either
    # from the default file or one provided by the cli.
    def initialize_raw_config(parameters)
      file = Dir.getwd + "/" + CukeSniffer::Constants::DEFAULT_CONFIG_FILE_NAME
      if parameters[:config_file]
        file = parameters[:config_file]
      elsif parameters[:project_location]
        file = parameters[:project_location] + File::Separator + CukeSniffer::Constants::DEFAULT_CONFIG_FILE_NAME
      end
      File.exists?(file) ? YAML.load_file(file) : {}
    end

    # Initialize source paths based on parameters and the raw config file,
    # then fall back to the working directory or the project location.
    def initialize_source_paths(parameters, raw_config)
      @project_location = get_final_path("", parameters[:project_location], raw_config["project_location"], Dir.getwd)
      @features_location = get_final_path(project_location,parameters[:features_location], raw_config["features_location"], project_location)
      @step_definitions_location = get_final_path(project_location,parameters[:step_definitions_location], raw_config["step_definitions_location"], project_location)
      @hooks_location = get_final_path(project_location,parameters[:hooks_location], raw_config["hooks_location"], project_location)
    end

    # Given the cli parameters and the raw config, determine if we should
    # catalog steps at completion.
    def initialize_cataloged(parameters, raw_config)
      if parameters[:no_catalog]
        @cataloged = !parameters[:no_catalog]
      else
        @cataloged = raw_config["cataloged"].nil? ? true : raw_config["cataloged"]
      end
    end

    # Given the cli provided parameters and a raw config yaml, initalize the
    # output file information
    def initialize_output(parameters, raw_config)
      if parameters[:output_format]
        @output_format = parameters[:output_format]
      elsif raw_config["output"] && raw_config["output"]["format"]
        @output_format = raw_config["output"]["format"]
      else
        @output_format = "stdout"
      end
      if @output_format.eql?("stdout")
        @output_file = nil
      elsif parameters[:output_file]
        @output_file = parameters[:output_file]
      elsif raw_config["output"] && raw_config["output"]["file"]
        @output_file = raw_config["output"]["file"]
      else
        @output_file = CukeSniffer::Constants::DEFAULT_OUTPUT_FILE_NAME
      end
    end

    # Given a project path, parameter path, config path, and default path, return
    # the best one found.
    def get_final_path(project_path, parameter_path, config_path, default_path)
      get_path(project_path,parameter_path) || get_path(project_path,config_path) ||get_path(project_path,default_path)
    end

    # Given a project path and a path, check if that path exists, and
    # if not, check if the path exists relative to the project. If it
    # still doesn't exist, return nil.
    def get_path(project_path, path)
      if path && File.exists?(path)
        path
      elsif project_path && path && File.exist?(project_path + File::Separator + path)
        project_path + File::Separator + path
      else
        nil
      end
    end
  end
end
