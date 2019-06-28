# frozen_string_literal: true

require "mimi/core"

module Mimi
  #
  # A Struct that can be initialized from a Hash or a PORO.
  #
  # A Struct declares its attributes and rules, which define how its attributes
  # are mapped from input data.
  #
  class Struct < Mimi::Core::Struct
    #
    # Default attribute mapper
    #
    # Maps value of the source attribute to the target attribute.
    # Calculates a default value if the source attribute is not set.
    #
    DEFAULT_ATTRIBUTE_MAPPER = -> (o, params) do
      if params.key?(:default)
        o.respond_to?(params[:from]) || call_as_proc(params[:default], o, params)
      else
        o.send(params[:from])
      end
    end

    # Default :if block for an optional attribute
    #
    # Skips the attribute if the source attribute is not set.
    #
    DEFAULT_IF_FOR_OPTIONAL = -> (o, params) do
      o.respond_to?(params[:from])
    end

    # Creates a mapped Struct object from another object
    #
    # @param source [Hash,Object]
    #
    def initialize(source)
      source = Mimi::Core::Struct.new(source) if source.is_a?(Hash)
      attributes = self.class.transform_attributes(source)
      super(attributes)
    rescue StandardError => e
      raise e.class, "Failed to construct #{self.class}: #{e}", e.backtrace
    end

    # Fetches an attribute with given name
    #
    # @param name [Symbol]
    #
    def [](name)
      @attributes[name.to_sym]
    end

    # Presents this Struct as a Hash, deeply converting nested Structs
    #
    # @return [Hash]
    #
    def to_h
      attributes.map do |k, v|
        [k, self.class.value_to_h(v)]
      end.to_h
    end

    # Returns attributes of this Structs as a Hash
    #
    # @return [Hash]
    #
    def attributes
      @attributes
    end

    # An attribute definition
    #
    # Possible params:
    #   from: <Symbol>
    #   using: <proc,Mimi::Struct>
    #   if: <proc>
    #   default: <proc,Object>
    #   optional: <true,false>
    #
    # @param name [Symbol]
    # @param params [Hash]
    #
    def self.attribute(name, params = {})
      name = name.to_sym
      raise "Attribute '#{name}' is already declared" if attribute_definitions.key?(name)
      defaults = group_params.reduce(:merge).merge(
        from: name,
        using: DEFAULT_ATTRIBUTE_MAPPER
      )
      params = defaults.merge(params)
      if params.key?(:if) && params.key?(:optional)
        raise ArgumentError, "Keys :if and :optional cannot be used together"
      end
      params[:if] = DEFAULT_IF_FOR_OPTIONAL if params[:optional]
      add_attribute_definition(name, params)
    end

    # Declare a group of parameters with common options
    #
    # E.g.
    #   Class User < Mimi::Struct
    #     attribute :id
    #     attribute :type
    #     attribute :name
    #     group if: -> (o) { o.type == 'ADMIN' } do
    #       attribute :admin_role
    #       attribute :admin_domain
    #     end
    #     group default: -> { Time.now.utc } do
    #       attribute :created_at
    #       attribute :updated_at
    #     end
    #   end
    #
    # NOTE: Not reentrable.
    #
    # @param params [Hash]
    #
    def self.group(params, &block)
      group_params << params
      yield
      group_params.pop
    end


    # Converts a single object or collection to Struct.
    #
    def self.<<(obj_or_collection)
      if obj_or_collection.is_a?(Array)
        obj_or_collection.map { |o| self << o }
      else
        new(obj_or_collection)
      end
    end

    # Returns a Hash of attribute definitions
    #
    # @return [Hash]
    #
    private_class_method def self.attribute_definitions
      @attribute_definitions ||= {}
      # merge with base class
      defined?(super) ? super.merge(@attribute_definitions) : @attribute_definitions
    end

    # Adds a new attribute definition
    #
    # @param name [Symbol]
    # @param params [Hash]
    #
    private_class_method def self.add_attribute_definition(name, params)
      @attribute_definitions ||= {}
      @attribute_definitions[name] = params.dup
    end

    # Returns current stack of group parameters
    #
    # @return [Array<Hash>]
    #
    private_class_method def self.group_params
      @group_params ||= [{}]
    end

    # Transform attributes according to rules
    #
    # @param source [Struct]
    # @return [Hash] map of attribute name -> value
    #
    def self.transform_attributes(source)
      result = attribute_definitions.map do |k, params|
        if params[:if].is_a?(Proc)
          next unless call_as_proc(params[:if], source, params)
        end
        [k, transform_single_attribute(source, k, params)]
      end.compact.to_h
      result
    end

    # Transforms a single attribute value according to rules passed as params
    #
    # @param source [Struct]
    # @param key [Symbol]
    # @param params [Hash] transformation rules
    # @return [Object]
    #
    private_class_method def self.transform_single_attribute(source, key, params)
      return call_as_proc(params[:using], source, params) if params[:using].is_a?(Proc)
      if params[:using].is_a?(Class) && params[:using] < Mimi::Struct
        return params[:using] << source.send(params[:from])
      end
      raise "unexpected :using type: #{params[:using].class}"
    rescue StandardError => e
      raise "Failed to transform attribute :#{key} : #{e}"
    end

    # Calls a lambda as a proc, not caring about the number of arguments
    #
    # @param proc_or_lambda [Proc]
    # @param *args
    #
    private_class_method def self.call_as_proc(proc, *args)
      raise ArgumentError, "Proc is expected as proc" unless proc.is_a?(Proc)
      if proc.lambda?
        proc.call(*args.first(proc.arity))
      else
        proc.call(*args)
      end
    end

    # Map value or values to Hash
    #
    # @param value [Object]
    #
    def self.value_to_h(value)
      case value
      when Struct
        value.to_h
      when Array
        value.map { |v| value_to_h(v) }
      else
        value
      end
    end
  end # class Struct
end # module Mimi

require "mimi/struct/version"
