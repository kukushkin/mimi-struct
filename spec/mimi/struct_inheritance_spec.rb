# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "Mimi::Struct inheritance" do
  let(:subclass_a) do
    Class.new(Mimi::Struct) do
      attribute :a
    end
  end
  let(:subclass_b) do
    Class.new(subclass_a) do
      attribute :b
    end
  end

  subject { subclass_b }

  it "successfully maps the object with correct attributes" do
    expect { subject.new(a: 1, b: 2) }.to_not raise_error
  end

  it "recognizes inherited attributes" do
    expect { subject.new(b: 1) }.to raise_error(Mimi::Struct::Error)
  end

  it "exposes inherited attributes" do
    expect(subject.new(a: 1, b: 2).attributes.keys).to eq [:a, :b]
  end
end
