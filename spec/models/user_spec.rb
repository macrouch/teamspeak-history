require 'spec_helper'

describe User do
	it "is valid with valid attributes" do
		Fabricate(:user).should be_valid
	end

	it { should validate_presence_of :name }
	it { should have_many :sessions }
end