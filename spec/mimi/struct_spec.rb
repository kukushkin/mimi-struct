# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mimi::Struct do
  it "is a Class" do
    expect(described_class).to be_a Class
  end

  it "has a version" do
    expect(Mimi::Struct::VERSION).to_not be nil
  end

  describe "DSL" do
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
  end # DSL

  describe "subclass with a defined schema" do
    let(:subclass) do
      Class.new(Mimi::Struct) do
        attribute :a
        attribute :b, default: 123
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

    it "accepts a Hash as a source object" do
      expect(params).to be_a(Hash)
      expect { subject.new(params) }.to_not raise_error
    end

    it "accepts a PORO as a source object" do
      object = ::Struct.new(:a, :e).new(1, "abc")
      expect(object).to_not be_a(Hash)
      expect(object).to respond_to(:a)
      expect(object).to respond_to(:e)
      expect { subject.new(object) }.to_not raise_error
    end
  end # subclass with a defined schema

  describe "instance" do
    let(:subclass) do
      Class.new(Mimi::Struct) do
        attribute :a
        attribute :b, optional: true
      end
    end

    subject { subclass.new(a: 1, b: 2) }

    it { is_expected.to be_a(Mimi::Struct) }

    it { is_expected.to respond_to(:to_h) }
    it { is_expected.to respond_to(:[]) }
    it { is_expected.to respond_to(:dup) }

    it "exposes defined members as methods" do
      expect(subject).to respond_to(:a)
      expect { subject.a }.to_not raise_error
      expect(subject).to respond_to(:b)
      expect { subject.b }.to_not raise_error
    end

    it "does NOT expose non-defined members as methods" do
      expect(subject).to_not respond_to(:c)
    end

    it "exposes defined members as indifferent Hash keys" do
      expect { subject[:a] }.to_not raise_error
    end
  end # instance

  describe ".<<" do
    it "tests the .<< method"
  end # .<<
end
