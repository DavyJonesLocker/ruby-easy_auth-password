require 'spec_helper'

describe EasyAuth::Password::Models::Account do
  it 'skips password identity validations if password identity is not present' do
    User.create.new_record?.should be_false
  end

  it 'does not skip identity validations if identity is present' do
    user = User.new
    user.identities << EasyAuth::Identities::Password.new
    user.valid?.should be_false
  end

  it 'does not skip identity validations if new record with password' do
    User.new(:password => 'test').valid?.should be_false
  end

  it 'provides a method to the password identity' do
    user = User.create(:email => 'test@example.com', :password => 'password', :password_confirmation => 'password')
    password_identity = user.identities.first
    password_identity.should eq user.password_identity
  end
end
