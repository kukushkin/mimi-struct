# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "Mimi::Struct DSL :using" do
  let(:subclass) do
    Class.new(Mimi::Struct) do
      attribute :a
      attribute :b, using: -> (o) { o.a }
    end
  end

  subject { subclass }

  it "successfully maps the object with correct attributes" do
    expect { subject.new(a: 1) }.to_not raise_error
  end

  context "when :using is a proc/lambda" do
    it "maps the attribute by evaluating the proc" do
      expect { subject.new(a: 1) }.to_not raise_error
      object = subject.new(a: 1)
      expect(object).to respond_to(:b)
      expect(object.b).to eq 1
    end

    it "tests that proc can accept 2 parameters (source, params)"
  end # when :using is a proc/lambda


  context "when :using is a Mimi::Struct" do
    let(:subclass) do
      inner_struct = Class.new(Mimi::Struct) do
        attribute :c
      end
      Class.new(Mimi::Struct) do
        attribute :a
        attribute :b, using: inner_struct
      end
    end

    it "maps the source attribute as a single object to a Mimi::Struct" do
      expect { subject.new(a: 1, b: { c: 2 }) }.to_not raise_error
      object = subject.new(a: 1, b: { c: 2 })
      expect(object).to respond_to(:b)
      expect(object.b).to be_a(Mimi::Struct)
      puts "object.b: #{object.b.to_h}"
      expect(object.b).to respond_to(:c)
      expect(object.b.c).to eq 2
    end

    it "tests the source attribute as Array"
  end # when :using is a proc/lambda
end
