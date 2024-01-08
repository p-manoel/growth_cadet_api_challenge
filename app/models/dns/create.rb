module Dns
  class Create < ::Micro::Case
    attribute :ip, validates: { kind: ::String }
    attribute :hostnames, validates: { kind: ::Array }

    def call!
      transaction do
        check_ip_format
          .then(:create_dns)
          .then(:create_hostnames_and_associate_dns)
      end
    end

    private

    def check_ip_format
      return Success(:ip_format_is_ok) if ip =~ Record::IPV4_FORMAT

      Failure(:invalid_ip_format)
    end

    def create_dns
      dns_record = Record.create!(ip: ip)

      Success(:dns_created, result: { dns_record: dns_record })
    end

    def create_hostnames_and_associate_dns(dns_record:, **)
      hostnames.each do |hostname|
        hostname_record = Hostname::Record.create!(hostname: hostname)

        DnsHostname::Record.create!(dns: dns_record, hostname: hostname_record)
      end

      Success(:dns_and_hostnames_created, result: { dns: dns_record })
    end
  end
end
