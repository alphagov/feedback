require 'csv'

POPULAR_CONTACT_LINKS = CSV.read("config/contact-links.csv", headers: true)
