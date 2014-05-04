# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :container do
    image nil
    status nil
    instance_id nil
    port_bindings nil
    name "My Container"
    host nil
  end
end
