require_relative 'test_helper'

module Spec
  class InformedConsumer
    attr_accessor :logger
    include Informed

    def initialize(logger:)
      self.logger = logger
    end

    private def some_private_method
      "some private data that can be logged"
    end

    def some_public_method
      "some private data that can be logged"
    end

    def method_without_arguments
      "method without arguments output"
    end

    def method_with_arguments(arg1, arg2)
      "method with arguments output #{arg1} #{arg2}"
    end

    def method_with_keyword_arguments(a_named_kwarg:, arg2:)
      "method with named arguments output #{a_named_kwarg} #{arg2}"
    end

    def method_with_both_kinds_of_arguments(unnamed_arg, named_arg:)
      "method with both kinds of arguments output #{unnamed_arg} #{named_arg}"
    end
  end

  SUPPORTED_LEVELS = [:debug, :info, :warn, :error, :fatal, :unknown]
  class FakeLogger
    def log(level, message=nil, progname=nil)
      logs[level].push(message)
    end

    def logs
      @logs ||= SUPPORTED_LEVELS.each_with_object({}) { |level, logs| logs[level] = [] }
    end

    SUPPORTED_LEVELS.each do |level|
      define_method level do |message|
        log(level, message)
      end
    end
  end
end

describe Informed do
  let(:consumer_class) { a = args; k = kwargs; Class.new(Spec::InformedConsumer) { inform_on *a, **k } }
  let(:args) { [method_to_inform_on] }
  let(:kwargs) { { level: level, also_log: also_log } }
  let(:consumer) { consumer_class.new(logger: fake_logger) }
  let(:fake_logger) { Spec::FakeLogger.new }
  let(:logs) { fake_logger.logs[level] }
  let(:level) { :info }
  let(:also_log) { nil }
  let(:method_to_inform_on) { :method_without_arguments }

  describe ".inform_on" do
    before { consumer.method_without_arguments }
    describe "the also_log: keyword arg" do
      describe "when nil (default)" do
        it "includes the start" do
          assert_includes logs, { status: :starting, method: :method_without_arguments, class: consumer.class.name }
        end
        it "includes the end" do
          assert_includes logs, { status: :done, method: :method_without_arguments, class: consumer.class.name }
        end

        it "does not log the result" do
          refute logs.empty?, "logs were empty!"
          logs.each do |log|
            refute log.key?(:result), "log #{log} included the result"
          end
        end
      end

      describe "when :also_log has { result: true }" do
        let(:also_log) { { result: true } }
        it "logs the result with the rest of the data" do
          refute logs.empty?, "logs were empty!"
          closing_log = logs.find do |log|
            log[:status] == :done
          end
          assert closing_log.key?(:result), "log #{closing_log} did not include the result"
        end
      end

      describe "when :also_log has { values: [:some_private_method] }" do
        let(:also_log) { { values: [:some_private_method] } }
        it "logs the value of the other method" do
          refute logs.empty?, "logs were empty!"
          logs.each do |log|
            assert_equal consumer.send(:some_private_method), log[:values][:some_private_method]
          end
        end
      end

      describe "when :also_log has { values: [:some_public_method] }" do
        let(:also_log) { { values: [:some_public_method] } }
        it "logs the value of the other method" do
          refute logs.empty?, "logs were empty!"
          logs.each do |log|
            assert_equal consumer.some_public_method, log[:values][:some_public_method]
          end
        end
      end

      describe "when :also_log has { values: [:a_named_kwarg] }" do
        let(:method_to_inform_on) { :method_with_keyword_arguments }
        let(:also_log) { { values: [:a_named_kwarg] } }
        it "logs the value of the other method" do
          consumer.method_with_keyword_arguments(a_named_kwarg: "hey", arg2: "there")
          refute logs.empty?, "logs were empty!"
          logs.each do |log|
            assert_equal "hey", log[:values][:a_named_kwarg]
          end
        end
      end
    end

    it 'calls the underlying method' do
      assert_equal 'method without arguments output', consumer.method_without_arguments
    end

    Spec::SUPPORTED_LEVELS.each do |log_level|
      describe "(method_name, level: #{log_level})" do
        before { result }
        let(:level) { log_level }
        describe 'when the method takes no arguments' do
          let(:result) { consumer.method_without_arguments }
          let(:method_to_inform_on) { :method_without_arguments }

          it "calls the method and returns its result" do
            assert_equal("method without arguments output", result)
          end

          it "stores the call in the logs" do
            refute logs.empty?, "logs were empty"
          end
        end

        describe 'when the method takes arguments' do
          let(:method_to_inform_on) { :method_with_arguments }
          let(:result) { consumer.method_with_arguments("argument 1!", "Argument 2") }

          it 'passes those arguments on' do
            assert_equal("method with arguments output argument 1! Argument 2", result)
          end
          it "logs the call at #{log_level}" do
            refute logs.empty?, "#{level} logs were empty"
          end
        end

        describe 'when the method takes named arguments' do
          let(:result) { consumer.method_with_keyword_arguments(a_named_kwarg: "1!", arg2: "2") }
          let(:method_to_inform_on) { :method_with_keyword_arguments }

          it 'passes those arguments on' do
            assert_equal("method with named arguments output 1! 2", result)
          end

          it "logs the call at #{log_level}" do
            refute logs.empty?, "#{level} logs were empty"
          end
        end

        describe 'when the method takes both regular and named arguments' do
          let(:result) { consumer.method_with_both_kinds_of_arguments("1!", named_arg: "2") }
          let(:method_to_inform_on) { :method_with_both_kinds_of_arguments }

          it 'passes those arguments on' do
            assert_equal("method with both kinds of arguments output 1! 2", result)
          end

          it "logs the call at #{log_level}" do
            refute logs.empty?, "#{level} logs were empty"
          end
        end
      end
    end
  end
end
