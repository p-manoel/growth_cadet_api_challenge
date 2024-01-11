require 'rails_helper'

RSpec.describe Dns::Create, type: :use_case do
  describe '.call' do
    let(:hostnames) { ['lorem.com', 'ipsum.com', 'dolor.com', 'amet.com', 'sit.com'].sample(3) }

    subject(:create_dns) { described_class.call({ ip: ip, hostnames: hostnames }) }

    describe 'success' do
      context 'when ip is valid' do
        let(:ip) { ['1.1.1.1', '255.255.255.255', '192.168.1.1'].sample }

        it 'returns a success' do
          result = create_dns

          expect(result).to be_success
          expect(result.type).to eq(:dns_and_hostnames_created)
        end

        it 'creates a dns record' do
          expect { create_dns }.to change { Dns::Record.count }.by(1)
        end

        it 'creates a hostname record for each given hostname' do
          expect { create_dns }.to change { Hostname::Record.count }.by(hostnames.count)
        end

        it 'creates a dns_hostname record for each given hostname' do
          expect { create_dns }.to change { DnsHostname::Record.count }.by(hostnames.count)
        end

        it 'exposes the created dns record' do
          created_dns = create_dns[:dns]

          expect(created_dns).to be_a(Dns::Record)
          expect(created_dns).to have_attributes(ip: ip)
        end
      end
    end

    describe 'failure' do
      context 'when attributes are invalid' do
        let(:ip) { [nil, 23, {}].sample }
        let(:hostnames) { [1, nil, {}].sample }

        it 'returns a failure' do
          result = create_dns

          expect(result).to be_a_failure
          expect(result.type).to eq(:invalid_attributes)
          expect(result.data.keys).to contain_exactly(:errors)
        end

        it 'exposes the errors' do
          errors = create_dns[:errors]

          expect(errors).to be_a(ActiveModel::Errors)
          expect(errors).to include(:ip, :hostnames)
        end
      end

      context 'when ip format is invalid' do
        let(:ip) { ['1.2.d.4', '255.255.255.256', '0.2.3'].sample }

        it 'returns a failure' do
          result = create_dns

          expect(result).to be_a_failure
          expect(result.type).to eq(:invalid_ip_format)
        end
      end
    end
  end
end
