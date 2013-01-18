#!/usr/bin/env ruby
#
#

require 'pp'
require 'rdoc/usage'
require 'rubygems'
require 'net/ldap'

ldap = Net::LDAP.new :host => 'ldap.glencoesoftware.com',
  :port => 636,
  :encryption => :simple_tls,
  :auth => {
  :method => :simple,
  :username => "cn=auth, dc=glencoesoftware, dc=com",
  :password => "5SlynBut9",
  :base => 'dc=glencoesoftware,dc=com'
}

filter = Net::LDAP::Filter.eq('objectClass', 'posixAccount')

guids = []
uids = []
ldap.search(:filter => filter, :base => 'ou=People,dc=glencoesoftware,dc=com') do |entry|
  guids << entry[:gidnumber]
  uids << entry[:uidnumber]
  puts "#{entry[:uid]}: #{entry[:uidnumber]} #{entry[:gidnumber]}"
end
