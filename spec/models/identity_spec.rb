require 'spec_helper'

describe EasyAuth::Password::Models::Identity do

  describe 'setter and getter' do
    it 'will typecast vaulues to booleans' do
      identity = Identity.new
      identity.remember = '1'
      identity.remember.should be_true
      identity.remember = '0'
      identity.remember.should be_false
    end
  end

  describe '#remember_time' do
    it 'defaults to 1.year' do
      Identity.new.remember_time.should eq 1.year
    end
  end
end
