# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :container do
    association :image
    status nil
    instance_id "id"
    port_bindings nil
    name "My Container"
    association :region
    after(:build) do |container|
      region = create(:region)
      region.hosts.create attributes_for(:host)
      container.region = region
    end
  end
end
