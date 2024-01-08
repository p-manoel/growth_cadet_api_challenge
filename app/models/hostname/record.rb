class Hostname::Record < ::ApplicationRecord
  self.table_name = 'hostnames'

  validates :hostname, presence: true

  has_many :dns_hostnames,
           foreign_key: :hostname_id,
           class_name: 'DnsHostname::Record',
           dependent: :destroy

  has_many :dns, through: :dns_hostnames, class_name: 'Dns::Record'
end
