class Dns::Record < ::ApplicationRecord
  self.table_name = 'dns'

  ipv4_block = /\d{,2}|1\d{2}|2[0-4]\d|25[0-5]/.freeze
  IPV4_FORMAT = /\A#{ipv4_block}\.#{ipv4_block}\.#{ipv4_block}\.#{ipv4_block}\z/.freeze

  validates :ip, presence: true, format: { with: IPV4_FORMAT }

  has_many :dns_hostnames,
           foreign_key: :dns_id,
           class_name: 'DnsHostname::Record',
           dependent: :destroy
  
  has_many :hostnames, through: :dns_hostnames, class_name: 'Hostname::Record'
end
