# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :host do
    name "MyHost"
    ip_address "10.0.0.12"
    port 5544
    association :region
    after(:build) do |host|
      host.region = create(:region)
    end
    after(:create) do |host|
      host.region.hosts << host
      host.region.save
    end
  end
end
