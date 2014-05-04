# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :image do
    name "My Image"
    description "Test image"
    docker_index "hyperdock/test"
    port_bindings ""
  end
end
