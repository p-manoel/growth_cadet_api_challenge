FactoryBot.define do
  factory :dns_hostname, class: 'DnsHostname::Record' do
    dns { create(:dns) }
    hostname { create(:hostname) }
  end
end
