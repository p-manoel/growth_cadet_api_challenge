FactoryBot.define do
  factory :hostname, class: 'Hostname::Record' do
    hostname { Faker::Internet.unique.domain_name }
  end
end
