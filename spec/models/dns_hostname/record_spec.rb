require 'rails_helper'

RSpec.describe DnsHostname::Record, type: :model do
  describe '.table_name' do
    it { expect(described_class.table_name).to eq('dns_hostnames') }
  end

  describe 'associations' do
    it do
      should belong_to(:dns)
             .class_name('Dns::Record')
             .inverse_of(:dns_hostnames)
    end

    it do
      should belong_to(:hostname)
             .class_name('Hostname::Record')
             .inverse_of(:dns_hostnames)
    end
  end
end
