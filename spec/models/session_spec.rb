require 'spec_helper'

describe Session do
	it "is valid with valid attributes" do
		Fabricate(:session).should be_valid
	end

	it { should validate_presence_of :login }
	it { should validate_presence_of :idle }
	it { should belong_to :user }
end