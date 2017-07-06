require 'logger'
require "informed/version"

# {Informed}, when included, makes it easy to log method calls when they start
# and finish. It provides a means to log additional data, such as the result of
# said calls, keyword arguments, or other instance methods.
#
# @example
#   class FancyService
#     attr_accessor :fanciness
#     include Informed
#     def initialize(fanciness:)
#       self.fanciness = fanciness
#     end
#
#     def do_something(force: false)
#       if fancy? || force
#         do_it_fancy
#       else
#         do_it_plain
#       end
#     end
#     inform_on :do_something, level: :info,
#                              also_log: { result: true, values: [:fancy?, :force, :fanciness]}
#
#     def fancy?
#       fanciness > 10
#     end
#
#     def do_it_plain
#       "so plain"
#     end
#
#     def do_it_fancy
#       "so fancy"
#     end
#   end
#
#   FancyService.new(fanciness: 12).do_something
#   #  I, [2017-04-04T19:46:05.256753 #29957]  INFO -- : {:method=>:do_something, :values=>{:fancy?=>true, :fanciness=>12}, :status=>:starting}
#   #  I, [2017-04-04T19:46:05.256896 #29957]  INFO -- : {:method=>:do_something, :values=>{:fancy?=>true, :fanciness=>12}, :status=>:done, :result=>"so fancy"}
#   #  => "so fancy"
#   FancyService.new(fanciness: 12).do_something(force: true)
#   #  I, [2017-04-04T19:46:09.043051 #29957]  INFO -- : {:method=>:do_something, :values=>{:fancy?=>true, :force=>true, :fanciness=>12}, :status=>:starting}
#   #  I, [2017-04-04T19:46:09.043159 #29957]  INFO -- : {:method=>:do_something, :values=>{:fancy?=>true, :force=>true, :fanciness=>12}, :status=>:done, :result=>"so fancy"}
#   #  => "so fancy"
#   FancyService.new(fanciness: 8).do_something(force: true)
#   #  I, [2017-04-04T19:46:17.968960 #29957]  INFO -- : {:method=>:do_something, :values=>{:fancy?=>false, :force=>true, :fanciness=>8}, :status=>:starting}
#   #  I, [2017-04-04T19:46:17.969066 #29957]  INFO -- : {:method=>:do_something, :values=>{:fancy?=>false, :force=>true, :fanciness=>8}, :status=>:done, :result=>"so fancy"}
#   #  => "so fancy"
#   FancyService.new(fanciness: 8).do_something(force: false)
#   #  I, [2017-04-04T19:49:10.485462 #29957]  INFO -- : {:method=>:do_something, :values=>{:fancy?=>false, :force=>false, :fanciness=>8}, :status=>:starting}
#   #  I, [2017-04-04T19:49:10.485596 #29957]  INFO -- : {:method=>:do_something, :values=>{:fancy?=>false, :force=>false, :fanciness=>8}, :status=>:done, :result=>"so plain"}
#   => "so plain"
module Informed
  # Mixes in the DSL to classes which include {Informed}. Defines a `logger`
  # method which delegates to {Informed.logger} if the object doesn't respond
  # to logger already.
  # @returns nil
  def self.included(informed_upon_class)
    informed_upon_class.extend(DSL)

    unless informed_upon_class.method_defined?(:logger)
      define_method(:logger) do
        Informed.logger
      end
    end
  end

  # @return [Logger] The configured logger. If a logger isn't set, creates one that logs
  #                  to STDOUT
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  # Sets the global {Informed.logger} to whatever logger you desire.
  # @param logger [Logger] An object that responds to #debug, #info, #warn, #error, #fatal and #unkonwn
  # @return [Logger] Returns what it's given.
  def self.logger=(logger)
    @logger = logger
  end

  # When extended, this adds the `inform_on` class method to the class it's
  # mixed in to.
  module DSL
    # Logs method calls to the named method
    # @param method [Symbol] Name of method to inform upon
    # @param level [:debug, :info, :warn, :error, :fatal, :unknown] which level
    #              calls to this method at.
    # @param also_log [Hash] See {Informant#also_log}
    def inform_on(method, level:, also_log: {})
      alias_method :"unwatched_#{method}", method
      informant = Informant.new(method: method, also_log: also_log, level: level)
      define_method method do |*arguments, **keyword_arguments|
        informant.inform_on(informee: self, logger: logger, arguments: arguments, keyword_arguments: keyword_arguments)
      end
    end
  end

  # Informs on method calls!
  class Informant
    # Which level to log informed method calls at
    # @return [:debug,:info,:warn,:error,:fatal,:unknown]
    attr_accessor :level

    # The name of the method being informed on. This is included in all log
    # messages.
    # @return [Symbol]
    attr_accessor :method

    # What, if any, additional data to log when informing on a method.
    #
    # If this hash has `{ result: true }`, done messages will be logged
    # with the result of the method.
    #
    # If the hash has `{ values: [:a_method_name, :a_keyword_arg_name] }` the
    # values of the method `a_method_name` and the passed in keyword argument
    # `a_keyword_arg_name` will be logged as well.
    #
    # @example
    #   inform_on :a_method, level: :debug, also_log: { result: true,
    #                                                   values: [:some_method, :some_keyword_arg] }
    #   # This will log the result of `a_method` at the debug level, as well as
    #   # the value of `some_method` and the passed in keyword argumented
    #   # `some_keyword_arg`
    #
    #   inform_on :another_method, level: :info
    #   # This will merely log that another_method was called at the info
    #   # level, with no additional context.
    # @return [Hash]
    attr_accessor :also_log

    # @param method [Symbol] See {#method}
    # @param also_log [Hash] See {#also_log}
    # @param level [Hash] See {#level}
    def initialize(method:, also_log:, level:)
      self.level = level
      self.method = method
      # Somehow, nils are slipping in here...
      self.also_log = also_log || {}
    end

    # @param informee [Object] The object that had the method called on it.
    # @param keyword_arguments [Hash] The keyword arguments passed into the method being informed on. These may
    #                                 be logged if specified in the :values
    #                                 array in {#also_log}.
    # @return the result of the informed upon method.
    def inform_on(logger:, arguments:, keyword_arguments:, informee:)
      method_context = { keyword_arguments: keyword_arguments, method: method, also_log: also_log, informee: informee }
      log(logger: logger, type: StartingMessage, method_context: method_context)
      result = if arguments.empty? && keyword_arguments.empty?
                 informee.send(:"unwatched_#{method}")
               elsif arguments.empty? && !keyword_arguments.empty?
                 informee.send(:"unwatched_#{method}", **keyword_arguments)
               elsif !arguments.empty? && keyword_arguments.empty?
                 informee.send(:"unwatched_#{method}", *arguments)
               elsif !arguments.empty? && !keyword_arguments.empty?
                 informee.send(:"unwatched_#{method}", *arguments, **keyword_arguments)
               end
      log(logger: logger, type: DoneMessage, method_context: method_context.merge(result: result))
      result
    end

    private def log(logger:, type:, method_context:)
      logger.send(level, type.new(**method_context).to_h)
    end

    # Standard message that is logged when informed upon methods are executed.
    class Message
      # @return [Hash] from {Informant#inform_on}
      attr_accessor :keyword_arguments

      # @return [Object] from {Informant#inform_on}
      attr_accessor :informee

      # @return [Hash] from {Informant#also_log}
      attr_accessor :also_log

      # @return [Symbol] from {Informant#method}
      attr_accessor :method
      def initialize(method:, keyword_arguments:, informee:, also_log:)
        self.keyword_arguments = keyword_arguments
        self.informee = informee
        self.also_log = also_log
        self.method = method
      end

      # The message for the informant to log, in hash form. Actual return value
      # depends on {#also_log}
      # @return [Hash]
      def to_h
        message = { method: method, class: informee.class.name }
        if also_log[:values]
          message[:values] = {}
          also_log[:values].each do |local|
            message[:values][local] = keyword_arguments[local] if keyword_arguments.key?(local)
            message[:values][local] = informee.send(local) if informee.respond_to?(local, true)
          end
        end
        message
      end
    end


    # Message logged when an informed upon method begins to be executed.
    class StartingMessage < Message
      # @return [Hash] a Hash with `status: :starting` merged with {Message#to_h}
      def to_h
        super.merge(status: :starting)
      end
    end

    # Message that's logged when an informed upon method is completed
    class DoneMessage < Message
      attr_accessor :result

      # @param result [Object] Result of the called method. may be logged if
      #                        {#also_log} has `result: true`
      # @see Message#initialize
      def initialize(result:, **kwargs)
        super(**kwargs)
        self.result = result
      end

      # @return [Hash] a Hash with `status: :done` and the result of {#message}
      def to_h
        done_message = { status: :done }
        done_message[:result] = result if also_log[:result]
        super.merge(done_message)
      end
    end


    # The default data to include in a logged message. This will always include
    # the {#method_name}, but may also include additional context from when the
    # method was executed based upon the values of {#also_log}.
    # @see #also_log
    # @return [Hash]
    private def message
    end
  end
end
