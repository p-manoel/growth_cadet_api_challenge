require 'rails_helper'

RSpec.describe Hostname::Record, type: :model do
  describe '.table_name' do
    it { expect(described_class.table_name).to eq('hostnames') }
  end

  describe 'validations' do
    it { should validate_presence_of(:hostname) }
  end

  describe 'associations' do
    it do
      should have_many(:dns_hostnames)
             .with_foreign_key(:hostname_id)
             .class_name('DnsHostname::Record')
             .dependent(:destroy)
    end

    it do
      should have_many(:dns)
             .through(:dns_hostnames)
             .class_name('Dns::Record')
    end
  end

  describe '.create' do
    context 'when hostname is present' do
      it { expect(described_class.create(hostname: 'lorem.com')).to be_valid }
    end

    context 'when hostname is nil' do
      it { expect(described_class.create(hostname: nil)).to be_invalid }
    end
  end
end
