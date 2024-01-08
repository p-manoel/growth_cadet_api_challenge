class DnsHostname::Record < ::ApplicationRecord
  self.table_name = 'dns_hostnames'

  belongs_to :dns, class_name: 'Dns::Record', inverse_of: :dns_hostnames
  belongs_to :hostname, class_name: 'Hostname::Record', inverse_of: :dns_hostnames
end
