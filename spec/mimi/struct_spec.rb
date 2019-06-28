# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mimi::Struct do
  it "is a Class" do
    expect(described_class).to be_a Class
  end

  it "has a version" do
    expect(Mimi::Struct::VERSION).to_not be nil
  end

  context "schema DSL" do
    let(:subclass) do
      Class.new(Mimi::Struct) do
        attribute :a
        attribute :b, default: -> { 123 }
        attribute :c, optional: true
        attribute :d, from: :e
        attribute :e, using: -> (o) { 456 }
        # TODO: test nested structures
      end
    end

    subject { subclass }

    it "allows to define schema in subclasses" do
      expect { subclass }.to_not raise_error
      expect(subclass).to be_a(Class)
      expect(subclass).to be < Mimi::Struct
    end
  end # schema DSL

  context "subclass with a defined schema" do
    let(:subclass) do
      Class.new(Mimi::Struct) do
        attribute :a
        attribute :b, default: -> { 123 }
        attribute :c, optional: true
        attribute :d, from: :e
        attribute :e, using: -> (o) { 456 }
        # TODO: test nested structures
      end
    end
    let(:params) do
      {
        a: 1,
        e: "abc"
      }
    end

    subject { subclass }

    it "allows to map source object to Mimi::Struct descendant" do
      expect { subject.new(params) }.to_not raise_error
      struct = subject.new(params)
      expect(struct).to be_a(Mimi::Struct)
      expect(struct).to respond_to(:a)
      expect(struct).to respond_to(:b)
      expect(struct).to_not respond_to(:c)
      expect(struct).to respond_to(:d)
      expect(struct).to respond_to(:e)
    end
  end # subclass with a defined schema
end
