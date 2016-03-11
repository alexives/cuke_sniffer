require 'spec_helper'
require 'yaml'
require 'cuke_sniffer/cuke_sniffer_helper'

describe CukeSniffer::CLI do
  context "no specified options" do
    let(:config) {CukeSniffer::Config.new}
    let(:cli) {CukeSniffer::CLI.new(config)}
    it "should use the current workin directory for feature locations" do
      expect(cli.features_location).to eql(Dir.getwd)
    end
    it "should use the current workin directory for step_definitions locations" do
      expect(cli.step_definitions_location).to eql(Dir.getwd)
    end
    it "should use the current workin directory for hooks locations" do
      expect(cli.hooks_location).to eql(Dir.getwd)
    end
    it "should set cataloged => true" do
      expect(cli.cataloged).to be_true
    end
    it "should use the default set of rules" do
      expect_same_rules(cli.rules,CukeSniffer::CukeSnifferHelper.build_rules(CukeSniffer::RuleConfig::RULES))
    end
  end

  context "options specified on command line" do
    let(:parameters) do
      {
        :features_location => "examples/complex_project/features/features/scenarios",
        :step_definitions_location => "examples/complex_project/features/features/step_definitions",
        :hooks_location => "examples/complex_project/features/features/support",
        :no_catalog => true,
        :config => "",
        :use_default_rules => true
      }
    end
    let(:config) {CukeSniffer::Config.new(parameters)}
    let(:cli) {CukeSniffer::CLI.new(config)}
    it "should use the specified directory for feature locations" do
      expect(cli.features_location).to eql(parameters[:features_location])
    end
    it "should use the specified directory for step_definitions locations" do
      expect(cli.step_definitions_location).to eql(parameters[:step_definitions_location])
    end
    it "should use the specified directory for hooks locations" do
      expect(cli.hooks_location).to eql(parameters[:hooks_location])
    end
    it "should set cataloged => false" do
      expect(cli.cataloged).to be_false
    end
    it "should use the default set of rules" do
      expect_same_rules(cli.rules,CukeSniffer::CukeSnifferHelper.build_rules(CukeSniffer::RuleConfig::RULES))
    end
  end

  context "options specified on command line and config" do
    let(:parameters) do
      {
        :features_location => "examples/complex_project/features/features/scenarios",
        :step_definitions_location => "examples/complex_project/features/features/step_definitions",
        :hooks_location => "examples/complex_project/features/features/support",
        :no_catalog => false,
        :config => "examples/complex_project/.cuke_sniffer.yml"
      }
    end
    let(:config) {CukeSniffer::Config.new(parameters)}
    let(:cli) {CukeSniffer::CLI.new(config)}
    it "should use the specified directory for feature locations" do
      expect(cli.features_location).to eql(parameters[:features_location])
    end
    it "should use the specified directory for step_definitions locations" do
      expect(cli.step_definitions_location).to eql(parameters[:step_definitions_location])
    end
    it "should use the specified directory for hooks locations" do
      expect(cli.hooks_location).to eql(parameters[:hooks_location])
    end
    it "should set cataloged => true" do
      expect(cli.cataloged).to be_true
    end
  end

  context "options specified in a config" do
    let(:parameters) do
      {
        :config_file => "examples/complex_project/.cuke_sniffer.yml"
      }
    end
    let(:raw_config) {YAML.load_file(parameters[:config_file])}
    let(:config) {CukeSniffer::Config.new(parameters)}
    let(:cli) {CukeSniffer::CLI.new(config)}
    it "should use the config specified directory for feature locations" do
      expect(cli.features_location).to eql(raw_config["project_location"] + File::Separator + raw_config["features_location"])
    end
    it "should use the config specified directory for step_definitions locations" do
      expect(cli.step_definitions_location).to eql(raw_config["project_location"] + File::Separator + raw_config["step_definitions_location"])
    end
    it "should use the config specified directory for hooks locations" do
      expect(cli.hooks_location).to eql(raw_config["project_location"] + File::Separator + raw_config["hooks_location"])
    end
    it "should set cataloged => true" do
      expect(cli.cataloged).to eql(raw_config["cataloged"])
    end
  end

  def expect_same_rules(array_1,array_2)
    expect(difference_between_arrays(array_1,array_2)).to eql([])
  end

  def difference_between_arrays(array_1, array_2)
    difference = array_1.to_ary.dup
    array_2.to_ary.each do |element|
      array_1.to_ary.each do |matches|
        if element.phrase.eql?(matches.phrase) &&
            element.score.eql?(matches.score) &&
            element.targets.eql?(matches.targets)
          difference.delete(matches)
        end
      end
    end
    difference
  end
end