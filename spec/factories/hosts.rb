# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :host do
    name "MyString"
    ip_address "MyString"
    port 1
  end
end
