require 'spec_helper'

describe EasyAuth::Password::Models::Account do
  it 'skips password identity validations if password identity is not present' do
    User.create.new_record?.should be_false
  end

  it 'does not skip identity validations if identity is present' do
    user = User.new
    user.identities << Identities::Password.new
    user.valid?.should be_false
  end

  it 'does not skip identity validations if new record with password' do
    User.new(:password => 'test').valid?.should be_false
  end

  it 'provides a method to the password identity' do
    user = User.create(:email => 'test@example.com', :username => 'testuser', :password => 'password', :password_confirmation => 'password')
    user.password_identities.count.should eq 2
    user.password_identities.first.username.should eq 'test@example.com'
    user.password_identities.last.username.should  eq 'testuser'
  end

  it 'updates the proper password identity' do
    user = User.create(:email => 'test@example.com', :username => 'testuser', :password => 'password', :password_confirmation => 'password')
    user.reload
    user.update_attribute(:username, 'testuser2')
    user.password_identities.last.username.should eq 'testuser2'
  end

  context 'username' do
    context '.identity_username_attributes' do
      before do
        class TestUser; end
        TestUser.stubs(:has_many)
        TestUser.stubs(:has_one)
        TestUser.stubs(:before_create)
        TestUser.stubs(:before_update)
        TestUser.stubs(:validates)
        TestUser.stubs(:attr_accessible)
      end

      after do
        Object.send(:remove_const, :TestUser)
      end

      context 'when only username is defined' do
        before do
          TestUser.stubs(:column_names).returns(['username'])
          TestUser.instance_eval { include(EasyAuth::Models::Account) }
        end

        it 'relies upon username' do
          TestUser.identity_username_attributes.should eq [:username]
        end
      end

      context 'when only email is defined' do
        before do
          TestUser.stubs(:column_names).returns(['email'])
          TestUser.instance_eval { include(EasyAuth::Models::Account) }
        end

        it 'relies upon username' do
          TestUser.identity_username_attributes.should eq [:email]
        end
      end

      context 'when both username and email are defined' do
        before do
          TestUser.stubs(:column_names).returns(['email', 'username'])
          TestUser.instance_eval { include(EasyAuth::Models::Account) }
        end

        it 'relies upon bosth username and password' do
          TestUser.identity_username_attributes.should eq [:email, :username]
        end
      end

      context 'when both username and email are not defined' do
        before do
          TestUser.stubs(:column_names).returns([])
        end

        it 'raises an Exception as no appropriate identity username attribute is available' do
          lambda {
            TestUser.send(:include, EasyAuth::Models::Account)
            TestUser.identity_username_attributes
          }.should raise_exception(EasyAuth::Password::Models::Account::NoIdentityUsernameError)
        end
      end
    end
  end
end
