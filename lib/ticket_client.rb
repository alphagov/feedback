class TicketClient
	DEPARTMENT_FIELD = 21494928

	class << self

		def raise_ticket(zendesk)
			tags = zendesk[:tags] << "public_form"
			result = client.tickets.create(
				:subject => zendesk[:subject],
				:tags => tags,
				:requester => {name: zendesk[:name], email: zendesk[:email]},
				:fields => [{id: DEPARTMENT_FIELD, value: zendesk[:department]}],
				:description => zendesk[:description]
			)
			!! result
		end

		def get_departments
			departments_hash = {}
			client.ticket_fields.find(:id => DEPARTMENT_FIELD).custom_field_options.each do |tf| 
				departments_hash[tf.name] = tf.value
			end
			departments_hash
		end

		def report_a_problem(params)
			description = <<-EOT
url: #{params[:url]}
what_doing: #{params[:what_doing]}
what_wrong: #{params[:what_wrong]}
EOT
result = client.tickets.create(
	:subject => path_for_url(params[:url]),
	:description => description,
	:tags => ['report_a_problem']
)
!! result
		end

		def client
			@client ||= build_client
		end

		private

		def build_client
			details = YAML.load_file(Rails.root.join('config', 'zendesk.yml'))
			if details["development_mode"]
				DummyClient.new
			else
				ZendeskAPI::Client.new do |config|
					config.url = details["url"]
					config.username = details["username"]
					config.password = details["password"]
					config.logger = Rails.logger
				end
			end
		end

		def path_for_url(url)
			uri = URI.parse(url)
			uri.path
		rescue URI::InvalidURIError
			"Unknown page"
		end
	end # << self

	class DummyClient
		class Tickets
			def self.create(attrs)
				if attrs[:description] =~ /break_zendesk/
					Rails.logger.info "Simulating Zendesk ticket creation fail for: #{attrs.inspect}"
					nil
				else
					Rails.logger.info "Zendesk ticket created: #{attrs.inspect}"
					attrs
				end
			end
		end

		class TicketFields
			class CustomFieldOptions
				class CustomFieldOption
					attr_reader :name, :value

					def initialize(name, value)
						@name = name
						@value = value
					end
				end
				def self.custom_field_options
					Rails.logger.info "Simulating Zendesk department lookup"
					[
						CustomFieldOption.new("Test Department One", "test_department_one"),
						CustomFieldOption.new("Test Department Two", "test_department_two")
					]
				end
			end
			def self.find(attrs)
				CustomFieldOptions
			end
		end

		def tickets
			Tickets
		end

		def ticket_fields
			TicketFields
		end
	end
end
