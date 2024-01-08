require 'rails_helper'

RSpec.describe Dns::Record, type: :model do
  describe '.table_name' do
    it { expect(described_class.table_name).to eq('dns') }
  end

  describe 'validations' do
    it { should validate_presence_of(:ip) }
  end

  describe 'associations' do
    it do
      should have_many(:dns_hostnames)
             .with_foreign_key(:dns_id)
             .class_name('DnsHostname::Record')
             .dependent(:destroy)
    end

    it do
      should have_many(:hostnames)
             .through(:dns_hostnames)
             .class_name('Hostname::Record')
    end
  end

  describe '.create' do
    context 'when ip is valid' do
      let(:valid_ip) { ['1.1.1.1', '192.168.3.1', '255.255.255.255'].sample }

      it { expect(described_class.create(ip: valid_ip)).to be_valid }
    end

    context 'when ip is invalid' do
      let(:invalid_ip) { ['1.1.1', '192.168.3.256', '1.fd.24.2'].sample }

      it { expect(described_class.create(ip: invalid_ip)).to be_invalid }
    end
  end
end
