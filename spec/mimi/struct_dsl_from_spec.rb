# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "Mimi::Struct DSL :from" do
  let(:subclass) do
    Class.new(Mimi::Struct) do
      attribute :a, from: :b
    end
  end

  subject { subclass }

  it "successfully maps the object with correct attributes" do
    expect { subject.new(b: 2) }.to_not raise_error
  end

  it "maps the source attribute to target attribute" do
    expect { subject.new(a: 1, b: 2) }.to_not raise_error
    object = subject.new(a: 1, b: 2)
    expect(object).to respond_to(:a)
    expect(object).to_not respond_to(:b)
    expect(object.a).to eq 2
  end
end
