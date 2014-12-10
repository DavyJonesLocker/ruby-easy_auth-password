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

  it 'creates password identities when account is already created and password is set after create' do
    user = User.create(:email => 'test@example.com', :username => 'testuser')
    user.password_identities.should be_empty
    user.password = user.password_confirmation = 'password'
    user.save
    user.password_identities.should_not be_empty
  end

  it 'creates the missing password identity when account is already created and password is set after create' do
    user = User.create(:email => 'test@example.com', :username => 'testuser')
    user.password_identities.create(:password => 'password1', :uid => 'test@example.com')
    user.password_identities.count.should eq 1
    user.password = user.password_confirmation = 'password2'
    user.save
    user.password_identities.count.should eq 2
    password_identities = user.password_identities
    password_identities.first.authenticate('password2').should be_true
    password_identities.last.authenticate('password2').should be_true
  end

  it 'does not skip identity validations if new record with password' do
    User.new(:password => 'test').valid?.should be_false
  end

  it 'provides a method to the password identity' do
    user = User.create(:email => 'test@example.com', :username => 'testuser', :password => 'password', :password_confirmation => 'password')
    user.reload
    user.password_identities.count.should eq 2
    user.password_identities.first.uid.should eq 'test@example.com'
    user.password_identities.last.uid.should  eq 'testuser'
  end

  it 'updates the proper password identity' do
    user = User.create(:email => 'test@example.com', :username => 'testuser', :password => 'password', :password_confirmation => 'password')
    user = User.last

    user.update_attribute(:username, 'testuser2')
    user.password_identities.last.uid.should eq 'testuser2'
    user.password_identities.last.authenticate('password').should be_true
  end

  it 'updates the proper password identity, even with case changes' do
    user = User.create(:email => 'test@example.com', :username => 'TESTUSER', :password => 'password', :password_confirmation => 'password')
    user.password_identities.where(uid: 'TESTUSER').update_all(uid: 'testuser')
    user = User.last

    user.password = user.password_confirmation = 'foo'
    user.save

    user = User.last
    user.password_identities.last.authenticate('foo').should be_true
  end

  context 'username' do
    context '.identity_uid_attributes' do
      before do
        class TestUser; end
        TestUser.stubs(:has_many)
        TestUser.stubs(:has_one)
        TestUser.stubs(:before_create)
        TestUser.stubs(:before_save)
        TestUser.stubs(:validates)
        TestUser.stubs(:accepts_nested_attributes_for)
      end

      after do
        Object.send(:remove_const, :TestUser)
      end

      context 'when table exists' do
        before do
          TestUser.stubs(:table_exists?).returns(true)
        end

        context 'when only username is defined' do
          before do
            TestUser.stubs(:column_names).returns(['username'])
            TestUser.instance_eval { include(EasyAuth::Models::Account) }
          end

          it 'relies upon username' do
            TestUser.identity_uid_attributes.should eq [:username]
          end
        end

        context 'when only email is defined' do
          before do
            TestUser.stubs(:column_names).returns(['email'])
            TestUser.instance_eval { include(EasyAuth::Models::Account) }
          end

          it 'relies upon username' do
            TestUser.identity_uid_attributes.should eq [:email]
          end
        end

        context 'when both username and email are defined' do
          before do
            TestUser.stubs(:column_names).returns(['email', 'username'])
            TestUser.instance_eval { include(EasyAuth::Models::Account) }
          end

          it 'relies upon bosth username and password' do
            TestUser.identity_uid_attributes.should eq [:email, :username]
          end
        end
      end

      context 'when no table exists' do
        before do
          TestUser.stubs(:table_exists?).returns(false)
        end

        it 'raises an Exception as no appropriate identity username attribute is available' do
          lambda {
            TestUser.send(:include, EasyAuth::Models::Account)
            TestUser.identity_uid_attributes
          }.should raise_exception(EasyAuth::Password::Models::Account::NoIdentityUIDError)
        end
      end
    end
  end
end
