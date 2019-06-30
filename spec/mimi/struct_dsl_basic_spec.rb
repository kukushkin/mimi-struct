# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "Mimi::Struct basic attribute DSL" do
  let(:subclass) do
    Class.new(Mimi::Struct) do
    end
  end

  subject { subclass }

  context "with empty schema" do
    it "allows class to be defined" do
      expect { subject }.to_not raise_error
    end

    it "allows objects to be instantiated" do
      expect { subject.new() }.to_not raise_error
      expect { subject.new(a: 1, b: 2) }.to_not raise_error
    end
  end # with empty schema

  context "with defined schema" do
    let(:subclass) do
      Class.new(Mimi::Struct) do
        attribute :a
        attribute :b
      end
    end

    it "requires presence of defined attributes" do
      expect { subject.new({}) }.to raise_error(Mimi::Struct::Error)
    end

    it "successfully maps the object with correct attributes" do
      expect { subject.new(a: 1, b: 2) }.to_not raise_error
    end

    it "maps attributes directly one-to-one" do
      object = subject.new(a: 1, b: "2")
      expect(object.a).to eq 1
      expect(object.b).to eq "2"
    end

    it "ignores extra attributes" do
      object = subject.new(a: 1, b: "2", c: 3)
      expect(object).to_not respond_to(:c)
      expect { object.c }.to raise_error(NoMethodError)
      expect { object[:c] }.to raise_error(NameError)
    end
  end # with defined schema
end
