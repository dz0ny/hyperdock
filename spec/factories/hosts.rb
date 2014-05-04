# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :host do
    name "MyHost"
    ip_address "10.0.0.12"
    port 5544
  end
end
