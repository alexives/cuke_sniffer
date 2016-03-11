require 'spec_helper'
require 'cuke_sniffer/config'
require 'cuke_sniffer/cuke_sniffer_helper'

describe CukeSniffer::Config do

  describe "empty config" do
    let(:config) {CukeSniffer::Config.new({config_file: ""})}
    it "should use the current workin directory for feature locations" do
      expect(config.features_location).to eql(Dir.getwd)
    end
    it "should use the current workin directory for step_definitions locations" do
      expect(config.step_definitions_location).to eql(Dir.getwd)
    end
    it "should use the current workin directory for hooks locations" do
      expect(config.hooks_location).to eql(Dir.getwd)
    end
    it "should use the current working directory for the project root" do
      expect(config.project_location).to eql(Dir.getwd)
    end
    it "should set cataloged => true" do
      expect(config.cataloged).to be_true
    end
    it "should output to stdout" do
      expect(config.output_format).to eql("stdout")
      expect(config.output_file).to be_nil
    end
    it "should ues the default rules set" do
      expect_same_rules(config.rules, CukeSniffer::RuleConfig::RULES)
    end
  end

  describe "project location speficied" do
    let(:config) {CukeSniffer::Config.new({config_file: "examples/simple_project/.cuke_sniffer.yml"})}
    let(:raw_config) {YAML.load_file("examples/simple_project/.cuke_sniffer.yml")}
    it "should use the specified project directory for feature locations" do
      expect(config.features_location).to eql(raw_config["project_location"])
    end
    it "should use the specified project directory for step_definitions locations" do
      expect(config.step_definitions_location).to eql(raw_config["project_location"])
    end
    it "should use the specified project directory for hooks locations" do
      expect(config.hooks_location).to eql(raw_config["project_location"])
    end
    it "should use the specified project directory for the project root" do
      expect(config.project_location).to eql(raw_config["project_location"])
    end
    it "should set cataloged => false" do
      expect(config.cataloged).to be_true
    end
    it "should output html to cs_results.xml" do
      expect(config.output_format).to eql(raw_config["output"]["format"])
      expect(config.output_file).to eql(raw_config["output"]["file"])
    end
    it "should ues the default rules set" do
      expect_same_rules(config.rules, CukeSniffer::RuleConfig::RULES)
    end
  end

  describe "complete config" do
    let(:config) {CukeSniffer::Config.new({config_file: "examples/complex_project/.cuke_sniffer.yml"})}
    let(:raw_config) {YAML.load_file("examples/complex_project/.cuke_sniffer.yml")}
    let(:config_rules) {raw_config["rules"]}
    it "should use the specified directory for feature locations" do
      expect(config.features_location).to eql(raw_config["project_location"] + File::Separator + raw_config["features_location"])
    end
    it "should use the specified directory for step_definitions locations" do
      expect(config.step_definitions_location).to eql(raw_config["project_location"] + File::Separator + raw_config["step_definitions_location"])
    end
    it "should use the specified directory for hooks locations" do
      expect(config.hooks_location).to eql(raw_config["project_location"] + File::Separator + raw_config["hooks_location"])
    end
    it "should use the specified directory for the project root" do
      expect(config.project_location).to eql(raw_config["project_location"])
    end
    it "should set cataloged => false" do
      expect(config.cataloged).to be_true
    end
    it "should output xml to cs_results.xml" do
      expect(config.output_format).to eql(raw_config["output"]["format"])
      expect(config.output_file).to eql(raw_config["output"]["file"])
    end
    it "should ues the default rules set" do
      expect_same_rules(config.rules, CukeSniffer::CukeSnifferHelper.merge_rules(CukeSniffer::RuleConfig::RULES,config_rules))
      expect(config.rules[:commas_in_description][:enabled]).to be_false
    end
  end

  describe "config overridden with parameters" do
    let(:parameters) do
      {
        :features_location => "examples/simple_project/features/scenarios",
        :step_definitions_location => "examples/simple_project/features/step_definitions",
        :hooks_location => "examples/simple_project/features/support",
        :project_location => "examples/simple_project/",
        :no_catalog => false,
        :config_file => "examples/complex_project/.cuke_sniffer.yml",
        :file_format => "html",
        :file_name => "output.html",
        :use_default_rules => true
      }
    end
    let(:config) {CukeSniffer::Config.new(parameters)}
    it "should use the specified directory for feature locations" do
      expect(config.features_location).to eql(parameters[:features_location])
    end
    it "should use the specified directory for step_definitions locations" do
      expect(config.step_definitions_location).to eql(parameters[:step_definitions_location])
    end
    it "should use the specified directory for hooks locations" do
      expect(config.hooks_location).to eql(parameters[:hooks_location])
    end
    it "should use the specified directory for hooks locations" do
      expect(config.project_location).to eql(parameters[:project_location])
    end
    it "should set cataloged => true" do
      expect(config.cataloged).to be_true
    end
    it "should output html to output.html" do
      expect(config.output_format).to eql("html")
      expect(config.output_file).to eql("output.html")
    end
    it "should ues the default rules set" do
      expect_same_rules(config.rules, CukeSniffer::RuleConfig::RULES)
    end
  end

  describe "config with only child folder paths" do
    let(:config_file) {"examples/config_examples/only_child_paths.yml"}
    let(:config) {CukeSniffer::Config.new({config_file: config_file})}
    let(:raw_config) {YAML.load_file(config_file)}
    it "should use the child paths" do
      expect(config.project_location).to eql(Dir.getwd)
      expect(config.hooks_location).to eql(raw_config["hooks_location"])
      expect(config.step_definitions_location).to eql(raw_config["step_definitions_location"])
      expect(config.features_location).to eql(raw_config["features_location"])
    end
  end

  describe "config with project and child folder paths" do
    let(:config_file) {"examples/config_examples/project_and_child_paths.yml"}
    let(:config) {CukeSniffer::Config.new({config_file: config_file})}
    let(:raw_config) {YAML.load_file(config_file)}
    it "should use the full child paths" do
      expect(config.project_location).to eql(raw_config["project_location"])
      expect(config.hooks_location).to eql(raw_config["hooks_location"])
      expect(config.step_definitions_location).to eql(raw_config["step_definitions_location"])
      expect(config.features_location).to eql(raw_config["features_location"])
    end
  end

  describe "config with only project location" do
    let(:config_file) {"examples/config_examples/only_project_location.yml"}
    let(:config) {CukeSniffer::Config.new({config_file: config_file})}
    let(:raw_config) {YAML.load_file(config_file)}
    it "should use the project path" do
      expect(config.project_location).to eql(raw_config["project_location"])
      expect(config.hooks_location).to eql(raw_config["project_location"])
      expect(config.step_definitions_location).to eql(raw_config["project_location"])
      expect(config.features_location).to eql(raw_config["project_location"])
    end
  end

  describe "config with project and relative child paths" do
    let(:config_file) {"examples/config_examples/project_with_relative_children.yml"}
    let(:config) {CukeSniffer::Config.new({config_file: config_file})}
    let(:raw_config) {YAML.load_file(config_file)}
    it "should use the project path" do
      expect(config.project_location).to eql(raw_config["project_location"])
      expect(config.hooks_location).to eql(raw_config["project_location"] + File::Separator + raw_config["hooks_location"])
      expect(config.step_definitions_location).to eql(raw_config["project_location"] + File::Separator + raw_config["step_definitions_location"])
      expect(config.features_location).to eql(raw_config["project_location"] + File::Separator + raw_config["features_location"])
    end
  end

  describe "config with project and children in different trees" do
    let(:config_file) {"examples/config_examples/project_and_children_in_different_trees.yml"}
    let(:config) {CukeSniffer::Config.new({config_file: config_file})}
    let(:raw_config) {YAML.load_file(config_file)}
    it "should use the full child paths" do
      expect(config.project_location).to eql(raw_config["project_location"])
      expect(config.hooks_location).to eql(raw_config["hooks_location"])
      expect(config.step_definitions_location).to eql(raw_config["step_definitions_location"])
      expect(config.features_location).to eql(raw_config["features_location"])
    end
  end

  describe "config with only format in the output" do
    let(:config_file) {"examples/config_examples/output_only_format.yml"}
    let(:config) {CukeSniffer::Config.new({config_file: config_file})}
    let(:raw_config) {YAML.load_file(config_file)}
    it "should output to the default file name with the specified output" do
      expect(config.output_file).to eql(CukeSniffer::Constants::DEFAULT_OUTPUT_FILE_NAME)
      expect(config.output_format).to eql("xml")
    end
  end

  describe "config with only file in the output" do
    let(:config_file) {"examples/config_examples/output_only_file.yml"}
    let(:config) {CukeSniffer::Config.new({config_file: config_file})}
    let(:raw_config) {YAML.load_file(config_file)}
    it "should output to the default file name with the specified output" do
      expect(config.output_file).to be_nil
      expect(config.output_format).to eql("stdout")
    end
  end

  def expect_same_rules(hash_1,hash_2)
    expect(difference_between_arrays(hash_1,hash_2)).to eql([])
  end

  def difference_between_arrays(hash_1, hash_2)
    difference = hash_1.dup.values
    hash_2.each_value do |element|
      hash_1.each_value do |matches|
        if element["phrase"].eql?(matches["phrase"]) &&
          element["score"].eql?(matches["score"]) &&
          element["targets"].eql?(matches["targets"]) &&
          element["words"].eql?(matches["words"]) &&
          element["max"].eql?(matches["max"]) &&
          element["min"].eql?(matches["min"]) &&
          element["file"].eql?(matches["file"])
          difference.delete(matches)
        end
      end
    end
    difference
  end
end