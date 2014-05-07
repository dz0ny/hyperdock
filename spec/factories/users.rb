# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email { 'some@email.com' }
    password { 'mypass123456' }
  end
end
