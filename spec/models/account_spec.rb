require 'spec_helper'

describe EasyAuth::Models::Account do
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
end
