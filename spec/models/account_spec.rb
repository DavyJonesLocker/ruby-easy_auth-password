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
    user = User.create(:email => 'test@example.com', :password => 'password', :password_confirmation => 'password')
    password_identity = user.identities.first
    password_identity.should eq user.password_identity
  end

  context 'username' do
    context '.identity_username_attribute' do
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
          TestUser.identity_username_attribute.should eq :username
        end
      end

      context 'when only email is defined' do
        before do
          TestUser.stubs(:column_names).returns(['email'])
          TestUser.instance_eval { include(EasyAuth::Models::Account) }
        end

        it 'relies upon username' do
          TestUser.identity_username_attribute.should eq :email
        end
      end

      context 'when both username and email are defined' do
        before do
          TestUser.stubs(:column_names).returns(['email', 'username'])
          TestUser.instance_eval { include(EasyAuth::Models::Account) }
        end

        it 'prefers username over email' do
          TestUser.identity_username_attribute.should eq :username
        end
      end

      context 'when both username and email are not defined' do
        before do
          TestUser.stubs(:column_names).returns([])
        end

        it 'raises an Exception as no appropriate identity username attribute is available' do
          lambda {
            TestUser.send(:include, EasyAuth::Models::Account)
            TestUser.identity_username_attribute
          }.should raise_exception(EasyAuth::Password::Models::Account::NoIdentityUsernameError)
        end
      end

      context 'when .identity_username_attribute is overridden' do
        before do
          TestUser.stubs(:identity_username_attribute).returns(:name)
          TestUser.send(:include, EasyAuth::Models::Account)
        end

        it 'returns :name' do
          TestUser.identity_username_attribute.should eq :name
        end
      end
    end
  end
end
