module Dns
  class Fetch < ::Micro::Case
    attribute :page, validates: { kind: ::Integer }
    attribute :included, validates: { kind: ::Array }
    attribute :excluded, validates: { kind: ::Array }

    def call!
      fetch_dns_records_and_hostnames
        .then(:format_response)
    end

    private

    def fetch_dns_records_and_hostnames
      query = ::Dns::Record.joins(:hostnames)

      hostnames = query.map(&:hostnames).flatten.pluck(:hostname).uniq

      if included.any?
        query = query.where(hostnames: { hostname: included })
                     .group(:id)
                     .having('COUNT(DISTINCT hostnames.id) = ?', included.count)

        hostnames = query.map(&:hostnames).flatten.pluck(:hostname).uniq.select { included.exclude?(_1) }
      end

      if excluded.any?
        query = query.map { _1 unless _1.hostnames.pluck(:hostname).include?(*excluded) }.compact

        hostnames = query.map(&:hostnames).flatten.pluck(:hostname).uniq.select { included.exclude?(_1) }
      end

      Success(:dns_records_fetched, result: { dns_records: query.uniq, hostnames: hostnames })
    end

    def format_response(dns_records:, hostnames:, **)
      hostnames_with_count = hostnames.map do |hostname|
        {
          hostname: hostname,
          count: dns_records.select { _1.hostnames.pluck(:hostname).include?(hostname) }.count
        }
      end.sort_by { -_1[:count] }

      Success(result: {
        formatted_response: {
          total_records: dns_records.count,
          records: dns_records.map do |dns_record|
            {
              id: dns_record.id,
              ip_address: dns_record.ip,
            }
          end,
          related_hostnames: hostnames_with_count
      }
      })
    end
  end
end
