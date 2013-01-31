require 'spec_helper'

describe Identities::Password do
  let(:params) { Hash.new }
  let(:controller) do
    controller = mock('Controller')
    controller.stubs(:params).returns({:identities_password => params})
    controller
  end

  it { should     have_valid(:password_digest).when('password_digest') }
  it { should_not have_valid(:password_digest).when(nil, '') }

  describe 'username' do
    before { create(:password_identity) }
    it { should     have_valid(:uid).when('another_test@example.com') }
    it { should_not have_valid(:uid).when('test@example.com', 'TEST@EXAMPLE.COM', nil, '') }
  end

  describe '.authenticate' do
    before do
      params.merge!(:uid => 'test@example.com')
    end
    context 'correct uid and password' do
      before do
        params[:password] = 'password'
        create(:password_identity)
      end
      it 'returns the user' do
        Identities::Password.authenticate(controller).should be_instance_of Identities::Password
      end
    end
    context 'incorrect uid bad password' do
      before do
        params[:password] = 'bad'
        create(:password_identity)
      end
      it 'returns nil' do
        Identities::Password.authenticate(controller).should be_false
      end
    end
    context 'bad uid and password' do
      before { params.merge!(:uid => 'bad@example.com', :password => 'bad') }
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
