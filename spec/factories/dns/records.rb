FactoryBot.define do
  factory :dns, class: 'Dns::Record' do
    ip { Faker::Internet.unique.ip_v4_address }

    after(:create) do |dns|
      create_list(:dns_hostname, 3, dns: dns, hostname: create(:hostname))
    end
  end
end
