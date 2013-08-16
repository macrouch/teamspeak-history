require 'spec_helper'

describe Channel do
  it "is valid with valid attributes" do
    Fabricate(:channel).should be_valid
  end

  it { should validate_presence_of :name }
end