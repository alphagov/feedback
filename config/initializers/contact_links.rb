require "csv"
require "contact_links"

CONTACT_LINKS = ContactLinks.new(CSV.read("config/contact-links.csv", headers: true))
