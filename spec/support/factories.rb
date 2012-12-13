FactoryGirl.define do
  factory :user do
    email                 'test@example.com'
    username              'testuser'
    password              'password'
    password_confirmation 'password'
  end

  factory :password_identity, :class => Identities::Password do
    uid                   'test@example.com'
    password              'password'
    password_confirmation 'password'
  end
end
