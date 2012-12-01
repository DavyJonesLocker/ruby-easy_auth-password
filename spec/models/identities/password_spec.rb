require 'spec_helper'

describe Identities::Password do
  let(:params) { Hash.new }
  let(:controller) do
    controller = mock('Controller')
    controller.stubs(:params).returns({:identities_password => params})
    controller
  end

  describe 'username' do
    before { create(:password_identity) }
    it { should     have_valid(:username).when('another_test@example.com') }
    it { should_not have_valid(:username).when('test@example.com', 'TEST@EXAMPLE.COM', nil, '') }
  end

  describe 'password' do
    context 'new record' do
      it { should     have_valid(:password).when('password') }
      it { should_not have_valid(:password).when(nil, '') }
    end

    context 'existing record' do
      subject do
        create(:password_identity)
        Identities::Password.last
      end
      it { should have_valid(:password).when('password', nil, '') }
    end

    context 'password reset' do
      subject do
        create(:password_identity)
        identity = Identities::Password.last
        identity.password_reset = true
        identity
      end
      it { should_not have_valid(:password).when(nil, '') }
    end
  end

  describe '.authenticate' do
    before do
      params.merge!(:username => 'test@example.com')
    end
    context 'correct username and password' do
      before do
        params[:password] = 'password'
        create(:password_identity)
      end
      it 'returns the user' do
        Identities::Password.authenticate(controller).should be_instance_of Identities::Password
      end
    end
    context 'incorrect username bad password' do
      before do
        params[:password] = 'bad'
        create(:password_identity)
      end
      it 'returns nil' do
        Identities::Password.authenticate(controller).should be_false
      end
    end
    context 'bad username and password' do
      before { params.merge!(:username => 'bad@example.com', :password => 'bad') }
      it 'returns nil' do
        Identities::Password.authenticate(controller).should be_nil
      end
    end
    context 'no attributes given' do
      it 'returns nil' do
        Identities::Password.authenticate(controller).should be_nil
      end
    end
  end

  describe '#password_reset' do
    it 'sets a unique reset token' do
      identity = create(:password_identity, :account => build(:user))
      identity.reset_token_digest.should be_nil
      unencrypted_token = identity.generate_reset_token!
      identity = Identities::Password.last
      identity.reset_token_digest.should_not be_nil
      BCrypt::Password.new(identity.reset_token_digest).should eq unencrypted_token
    end
  end
end
