require 'rails_helper'

RSpec.describe Dns::Fetch, type: :use_case do
  describe '.call' do
    let(:page) { 1 }
    let!(:dns_1) { create(:dns) }
    let!(:dns_2) { create(:dns) }
    let!(:dns_3) { create(:dns) }

    subject(:fetch_dns) { described_class.call({ page: page, included: included, excluded: excluded }) }

    describe 'success' do
      context 'when included and excluded attributes are empty' do
        let(:included) { [] }
        let(:excluded) { [] }

        it 'returns a success' do
          result = fetch_dns

          expect(result).to be_success
          expect(result.type).to eq(:ok)
          expect(result.data.keys).to contain_exactly(:formatted_response)
        end

        it 'exposes the formatted response' do
          formatted_response = fetch_dns[:formatted_response]

          expect(formatted_response).to be_a(Hash)
          expect(formatted_response).to include(:total_records, :records, :related_hostnames)
          expect(formatted_response).to eq(
            total_records: 3,
            records: [
            {
              :id => dns_1.id,
              :ip_address => dns_1.ip
            },
            {
              :id => dns_2.id,
              :ip_address => dns_2.ip
            },
            {
              :id => dns_3.id,
              :ip_address => dns_3.ip
            }
          ],
            related_hostnames: [
              {
                :count => 1,
                :hostname => dns_1.hostnames.first.hostname
              },
              {
                :count => 1,
                :hostname => dns_2.hostnames.first.hostname
              },
              {
                count: 1,
                :hostname => dns_3.hostnames.first.hostname
              }
            ]
          )
        end
      end

      context 'when included attribute is present' do
        let(:included) { [dns_1.hostnames.first.hostname] }
        let(:excluded) { [] }

        it 'returns a success' do
          result = fetch_dns

          expect(result).to be_success
          expect(result.type).to eq(:ok)
          expect(result.data.keys).to contain_exactly(:formatted_response)
        end

        it 'exposes the formatted response' do
          formatted_response = fetch_dns[:formatted_response]

          expect(formatted_response).to be_a(Hash)
          expect(formatted_response).to include(:total_records, :records, :related_hostnames)
          expect(formatted_response).to eq(
            total_records: 1,
            records: [{ :id => dns_1.id, :ip_address => dns_1.ip }],
            related_hostnames: []
          )
        end
      end

      context 'when excluded attribute is present' do
        let(:included) { [] }
        let(:excluded) { [dns_1.hostnames.first.hostname] }

        it 'returns a success' do
          result = fetch_dns

          expect(result).to be_success
          expect(result.type).to eq(:ok)
          expect(result.data.keys).to contain_exactly(:formatted_response)
        end

        it 'exposes the formatted response' do
          formatted_response = fetch_dns[:formatted_response]

          expect(formatted_response).to be_a(Hash)
          expect(formatted_response).to include(:total_records, :records, :related_hostnames)
          expect(formatted_response).to eq(
            total_records: 2,
            records: [
              {
                :id => dns_2.id,
                :ip_address => dns_2.ip
              },
              {
                :id => dns_3.id,
                :ip_address => dns_3.ip
              }
            ],
            related_hostnames: [
              {
                :count => 1,
                :hostname => dns_2.hostnames.first.hostname
              },
              {
                :count => 1,
                :hostname => dns_3.hostnames.first.hostname
              }
            ]
          )
        end
      end

      context 'when included and excluded attributes are present' do
        let(:included) { [dns_1.hostnames.first.hostname] }
        let(:excluded) { [dns_2.hostnames.first.hostname] }

        it 'returns a success' do
          result = fetch_dns

          expect(result).to be_success
          expect(result.type).to eq(:ok)
          expect(result.data.keys).to contain_exactly(:formatted_response)
        end

        it 'exposes the formatted response' do
          formatted_response = fetch_dns[:formatted_response]

          expect(formatted_response).to be_a(Hash)
          expect(formatted_response).to include(:total_records, :records, :related_hostnames)
          expect(formatted_response).to eq(
            total_records: 1,
            records: [{ :id => dns_1.id, :ip_address => dns_1.ip }],
            related_hostnames: []
          )
        end
      end
    end

    describe 'failure' do
      context 'when attributes are invalid' do
        let(:page) { [nil, '1', {}].sample }
        let(:included) { [nil, '1', {}].sample }
        let(:excluded) { [nil, '1', {}].sample }

        it 'returns a failure' do
          result = fetch_dns

          expect(result).to be_a_failure
          expect(result.type).to eq(:invalid_attributes)
          expect(result.data.keys).to contain_exactly(:errors)
        end

        it 'exposes the errors' do
          errors = fetch_dns[:errors]

          expect(errors).to be_a(ActiveModel::Errors)
          expect(errors).to include(:page, :included, :excluded)
        end
      end
    end
  end
end
