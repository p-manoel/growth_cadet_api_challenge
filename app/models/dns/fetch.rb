module Dns
  class Fetch < ::Micro::Case
    attribute :page, validates: { kind: ::Integer }
    attribute :included, validates: { kind: ::Array }
    attribute :excluded, validates: { kind: ::Array }

    def call!
      fetch_dns_records
        .then(:format_response)
    end

    private

    def fetch_dns_records
      dns_records = Record.joins(:hostnames).all

      dns_records = dns_records.where.not(hostnames: { hostname: excluded }) if excluded.any?

      if included.any?
        dns_records = dns_records
                      .where(hostnames: { hostname: included })
                      .group(:id)
                      .having("COUNT(DISTINCT hostnames.id) = ?", included.count)
      end

      Success(:dns_records_fetched, result: { dns_records: dns_records.uniq })
    end

    def format_response(dns_records:, **)
      formatted_response = {
        total_records: dns_records.count,
        records: dns_records.map do |dns_record|
          {
            id: dns_record.id,
            ip_address: dns_record.ip
          }
        end,
        related_hostnames: dns_records.flat_map(&:hostnames)
                                      .reject { |hostname| included.include?(hostname.hostname) }
                                      .group_by(&:hostname)
                                      .map do |hostname, hostnames|
          {
            hostname: hostname,
            count: hostnames.size
          }
        end
      }

      Success(:response_formatted, result: { formatted_response: formatted_response })
    end
  end
end
