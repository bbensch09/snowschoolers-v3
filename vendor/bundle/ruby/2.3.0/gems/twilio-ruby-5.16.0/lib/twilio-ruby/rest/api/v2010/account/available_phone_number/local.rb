##
# This code was generated by
# \ / _    _  _|   _  _
#  | (_)\/(_)(_|\/| |(/_  v1.0.0
#       /       /
# 
# frozen_string_literal: true

module Twilio
  module REST
    class Api < Domain
      class V2010 < Version
        class AccountContext < InstanceContext
          class AvailablePhoneNumberCountryContext < InstanceContext
            class LocalList < ListResource
              ##
              # Initialize the LocalList
              # @param [Version] version Version that contains the resource
              # @param [String] account_sid The 34 character string that uniquely identifies
              #   your account.
              # @param [String] country_code The ISO Country code to lookup phone numbers for.
              # @return [LocalList] LocalList
              def initialize(version, account_sid: nil, country_code: nil)
                super(version)

                # Path Solution
                @solution = {account_sid: account_sid, country_code: country_code}
                @uri = "/Accounts/#{@solution[:account_sid]}/AvailablePhoneNumbers/#{@solution[:country_code]}/Local.json"
              end

              ##
              # Lists LocalInstance records from the API as a list.
              # Unlike stream(), this operation is eager and will load `limit` records into
              # memory before returning.
              # @param [String] area_code Find phone numbers in the specified area code. (US and
              #   Canada only)
              # @param [String] contains A pattern on which to match phone numbers. Valid
              #   characters are `'*'` and `[0-9a-zA-Z]`. The `'*'` character will match any
              #   single digit. See [Example
              #   2](https://www.twilio.com/docs/api/rest/available-phone-numbers#local-get-basic-example-2) and [Example 3](https://www.twilio.com/docs/api/rest/available-phone-numbers#local-get-basic-example-3) below. *NOTE:* Patterns must be at least two characters long.
              # @param [Boolean] sms_enabled This indicates whether the phone numbers can
              #   receive text messages. Possible values are `true` or `false`.
              # @param [Boolean] mms_enabled This indicates whether the phone numbers can
              #   receive MMS messages. Possible values are `true` or `false`.
              # @param [Boolean] voice_enabled This indicates whether the phone numbers can
              #   receive calls. Possible values are `true` or `false`.
              # @param [Boolean] exclude_all_address_required Indicates whether the response
              #   includes phone numbers which require any
              #   [Address](https://www.twilio.com/docs/usage/api/addresses). Possible values are
              #   `true` or `false`. If not specified, the default is `false`, and results could
              #   include phone numbers with an Address required.
              # @param [Boolean] exclude_local_address_required Indicates whether the response
              #   includes phone numbers which require a local
              #   [Address](https://www.twilio.com/docs/usage/api/addresses). Possible values are
              #   `true` or `false`. If not specified, the default is `false`, and results could
              #   include phone numbers with a local Address required.
              # @param [Boolean] exclude_foreign_address_required Indicates whether the response
              #   includes phone numbers which require a foreign
              #   [Address](https://www.twilio.com/docs/usage/api/addresses). Possible values are
              #   `true` or `false`. If not specified, the default is `false`, and results could
              #   include phone numbers with a foreign Address required.
              # @param [Boolean] beta Include phone numbers new to the Twilio platform. Possible
              #   values are either `true` or `false`. Default is `true`.
              # @param [String] near_number Given a phone number, find a geographically close
              #   number within `Distance` miles. Distance defaults to 25 miles. *Limited to US
              #   and Canadian phone numbers.*
              # @param [String] near_lat_long Given a latitude/longitude pair `lat,long` find
              #   geographically close numbers within `Distance` miles. *Limited to US and
              #   Canadian phone numbers.*
              # @param [String] distance Specifies the search radius for a `Near-` query in
              #   miles. If not specified this defaults to 25 miles. Maximum searchable distance
              #   is 500 miles. *Limited to US and Canadian phone numbers.*
              # @param [String] in_postal_code Limit results to a particular postal code. Given
              #   a phone number, search within the same postal code as that number. *Limited to
              #   US and Canadian phone numbers.*
              # @param [String] in_region Limit results to a particular region (i.e. 
              #   State/Province). Given a phone number, search within the same Region as that
              #   number. *Limited to US and Canadian phone numbers.*
              # @param [String] in_rate_center Limit results to a specific rate center, or given
              #   a phone number search within the same rate center as that number. Requires
              #   InLata to be set as well. *Limited to US and Canadian phone numbers.*
              # @param [String] in_lata Limit results to a specific Local access and transport
              #   area ([LATA](http://en.wikipedia.org/wiki/Local_access_and_transport_area)).
              #   Given a phone number, search within the same
              #   [LATA](http://en.wikipedia.org/wiki/Local_access_and_transport_area) as that
              #   number. *Limited to US and Canadian phone numbers.*
              # @param [String] in_locality Limit results to a particular locality (i.e.  City).
              #   Given a phone number, search within the same Locality as that number. *Limited
              #   to US and Canadian phone numbers.*
              # @param [Boolean] fax_enabled This indicates whether the phone numbers can
              #   receive faxes. Possible values are `true` or `false`.
              # @param [Integer] limit Upper limit for the number of records to return. stream()
              #    guarantees to never return more than limit.  Default is no limit
              # @param [Integer] page_size Number of records to fetch per request, when
              #    not set will use the default value of 50 records.  If no page_size is defined
              #    but a limit is defined, stream() will attempt to read the limit with the most
              #    efficient page size, i.e. min(limit, 1000)
              # @return [Array] Array of up to limit results
              def list(area_code: :unset, contains: :unset, sms_enabled: :unset, mms_enabled: :unset, voice_enabled: :unset, exclude_all_address_required: :unset, exclude_local_address_required: :unset, exclude_foreign_address_required: :unset, beta: :unset, near_number: :unset, near_lat_long: :unset, distance: :unset, in_postal_code: :unset, in_region: :unset, in_rate_center: :unset, in_lata: :unset, in_locality: :unset, fax_enabled: :unset, limit: nil, page_size: nil)
                self.stream(
                    area_code: area_code,
                    contains: contains,
                    sms_enabled: sms_enabled,
                    mms_enabled: mms_enabled,
                    voice_enabled: voice_enabled,
                    exclude_all_address_required: exclude_all_address_required,
                    exclude_local_address_required: exclude_local_address_required,
                    exclude_foreign_address_required: exclude_foreign_address_required,
                    beta: beta,
                    near_number: near_number,
                    near_lat_long: near_lat_long,
                    distance: distance,
                    in_postal_code: in_postal_code,
                    in_region: in_region,
                    in_rate_center: in_rate_center,
                    in_lata: in_lata,
                    in_locality: in_locality,
                    fax_enabled: fax_enabled,
                    limit: limit,
                    page_size: page_size
                ).entries
              end

              ##
              # Streams LocalInstance records from the API as an Enumerable.
              # This operation lazily loads records as efficiently as possible until the limit
              # is reached.
              # @param [String] area_code Find phone numbers in the specified area code. (US and
              #   Canada only)
              # @param [String] contains A pattern on which to match phone numbers. Valid
              #   characters are `'*'` and `[0-9a-zA-Z]`. The `'*'` character will match any
              #   single digit. See [Example
              #   2](https://www.twilio.com/docs/api/rest/available-phone-numbers#local-get-basic-example-2) and [Example 3](https://www.twilio.com/docs/api/rest/available-phone-numbers#local-get-basic-example-3) below. *NOTE:* Patterns must be at least two characters long.
              # @param [Boolean] sms_enabled This indicates whether the phone numbers can
              #   receive text messages. Possible values are `true` or `false`.
              # @param [Boolean] mms_enabled This indicates whether the phone numbers can
              #   receive MMS messages. Possible values are `true` or `false`.
              # @param [Boolean] voice_enabled This indicates whether the phone numbers can
              #   receive calls. Possible values are `true` or `false`.
              # @param [Boolean] exclude_all_address_required Indicates whether the response
              #   includes phone numbers which require any
              #   [Address](https://www.twilio.com/docs/usage/api/addresses). Possible values are
              #   `true` or `false`. If not specified, the default is `false`, and results could
              #   include phone numbers with an Address required.
              # @param [Boolean] exclude_local_address_required Indicates whether the response
              #   includes phone numbers which require a local
              #   [Address](https://www.twilio.com/docs/usage/api/addresses). Possible values are
              #   `true` or `false`. If not specified, the default is `false`, and results could
              #   include phone numbers with a local Address required.
              # @param [Boolean] exclude_foreign_address_required Indicates whether the response
              #   includes phone numbers which require a foreign
              #   [Address](https://www.twilio.com/docs/usage/api/addresses). Possible values are
              #   `true` or `false`. If not specified, the default is `false`, and results could
              #   include phone numbers with a foreign Address required.
              # @param [Boolean] beta Include phone numbers new to the Twilio platform. Possible
              #   values are either `true` or `false`. Default is `true`.
              # @param [String] near_number Given a phone number, find a geographically close
              #   number within `Distance` miles. Distance defaults to 25 miles. *Limited to US
              #   and Canadian phone numbers.*
              # @param [String] near_lat_long Given a latitude/longitude pair `lat,long` find
              #   geographically close numbers within `Distance` miles. *Limited to US and
              #   Canadian phone numbers.*
              # @param [String] distance Specifies the search radius for a `Near-` query in
              #   miles. If not specified this defaults to 25 miles. Maximum searchable distance
              #   is 500 miles. *Limited to US and Canadian phone numbers.*
              # @param [String] in_postal_code Limit results to a particular postal code. Given
              #   a phone number, search within the same postal code as that number. *Limited to
              #   US and Canadian phone numbers.*
              # @param [String] in_region Limit results to a particular region (i.e. 
              #   State/Province). Given a phone number, search within the same Region as that
              #   number. *Limited to US and Canadian phone numbers.*
              # @param [String] in_rate_center Limit results to a specific rate center, or given
              #   a phone number search within the same rate center as that number. Requires
              #   InLata to be set as well. *Limited to US and Canadian phone numbers.*
              # @param [String] in_lata Limit results to a specific Local access and transport
              #   area ([LATA](http://en.wikipedia.org/wiki/Local_access_and_transport_area)).
              #   Given a phone number, search within the same
              #   [LATA](http://en.wikipedia.org/wiki/Local_access_and_transport_area) as that
              #   number. *Limited to US and Canadian phone numbers.*
              # @param [String] in_locality Limit results to a particular locality (i.e.  City).
              #   Given a phone number, search within the same Locality as that number. *Limited
              #   to US and Canadian phone numbers.*
              # @param [Boolean] fax_enabled This indicates whether the phone numbers can
              #   receive faxes. Possible values are `true` or `false`.
              # @param [Integer] limit Upper limit for the number of records to return. stream()
              #    guarantees to never return more than limit. Default is no limit.
              # @param [Integer] page_size Number of records to fetch per request, when
              #    not set will use the default value of 50 records. If no page_size is defined
              #    but a limit is defined, stream() will attempt to read the limit with the most
              #    efficient page size, i.e. min(limit, 1000)
              # @return [Enumerable] Enumerable that will yield up to limit results
              def stream(area_code: :unset, contains: :unset, sms_enabled: :unset, mms_enabled: :unset, voice_enabled: :unset, exclude_all_address_required: :unset, exclude_local_address_required: :unset, exclude_foreign_address_required: :unset, beta: :unset, near_number: :unset, near_lat_long: :unset, distance: :unset, in_postal_code: :unset, in_region: :unset, in_rate_center: :unset, in_lata: :unset, in_locality: :unset, fax_enabled: :unset, limit: nil, page_size: nil)
                limits = @version.read_limits(limit, page_size)

                page = self.page(
                    area_code: area_code,
                    contains: contains,
                    sms_enabled: sms_enabled,
                    mms_enabled: mms_enabled,
                    voice_enabled: voice_enabled,
                    exclude_all_address_required: exclude_all_address_required,
                    exclude_local_address_required: exclude_local_address_required,
                    exclude_foreign_address_required: exclude_foreign_address_required,
                    beta: beta,
                    near_number: near_number,
                    near_lat_long: near_lat_long,
                    distance: distance,
                    in_postal_code: in_postal_code,
                    in_region: in_region,
                    in_rate_center: in_rate_center,
                    in_lata: in_lata,
                    in_locality: in_locality,
                    fax_enabled: fax_enabled,
                    page_size: limits[:page_size],
                )

                @version.stream(page, limit: limits[:limit], page_limit: limits[:page_limit])
              end

              ##
              # When passed a block, yields LocalInstance records from the API.
              # This operation lazily loads records as efficiently as possible until the limit
              # is reached.
              def each
                limits = @version.read_limits

                page = self.page(page_size: limits[:page_size], )

                @version.stream(page,
                                limit: limits[:limit],
                                page_limit: limits[:page_limit]).each {|x| yield x}
              end

              ##
              # Retrieve a single page of LocalInstance records from the API.
              # Request is executed immediately.
              # @param [String] area_code Find phone numbers in the specified area code. (US and
              #   Canada only)
              # @param [String] contains A pattern on which to match phone numbers. Valid
              #   characters are `'*'` and `[0-9a-zA-Z]`. The `'*'` character will match any
              #   single digit. See [Example
              #   2](https://www.twilio.com/docs/api/rest/available-phone-numbers#local-get-basic-example-2) and [Example 3](https://www.twilio.com/docs/api/rest/available-phone-numbers#local-get-basic-example-3) below. *NOTE:* Patterns must be at least two characters long.
              # @param [Boolean] sms_enabled This indicates whether the phone numbers can
              #   receive text messages. Possible values are `true` or `false`.
              # @param [Boolean] mms_enabled This indicates whether the phone numbers can
              #   receive MMS messages. Possible values are `true` or `false`.
              # @param [Boolean] voice_enabled This indicates whether the phone numbers can
              #   receive calls. Possible values are `true` or `false`.
              # @param [Boolean] exclude_all_address_required Indicates whether the response
              #   includes phone numbers which require any
              #   [Address](https://www.twilio.com/docs/usage/api/addresses). Possible values are
              #   `true` or `false`. If not specified, the default is `false`, and results could
              #   include phone numbers with an Address required.
              # @param [Boolean] exclude_local_address_required Indicates whether the response
              #   includes phone numbers which require a local
              #   [Address](https://www.twilio.com/docs/usage/api/addresses). Possible values are
              #   `true` or `false`. If not specified, the default is `false`, and results could
              #   include phone numbers with a local Address required.
              # @param [Boolean] exclude_foreign_address_required Indicates whether the response
              #   includes phone numbers which require a foreign
              #   [Address](https://www.twilio.com/docs/usage/api/addresses). Possible values are
              #   `true` or `false`. If not specified, the default is `false`, and results could
              #   include phone numbers with a foreign Address required.
              # @param [Boolean] beta Include phone numbers new to the Twilio platform. Possible
              #   values are either `true` or `false`. Default is `true`.
              # @param [String] near_number Given a phone number, find a geographically close
              #   number within `Distance` miles. Distance defaults to 25 miles. *Limited to US
              #   and Canadian phone numbers.*
              # @param [String] near_lat_long Given a latitude/longitude pair `lat,long` find
              #   geographically close numbers within `Distance` miles. *Limited to US and
              #   Canadian phone numbers.*
              # @param [String] distance Specifies the search radius for a `Near-` query in
              #   miles. If not specified this defaults to 25 miles. Maximum searchable distance
              #   is 500 miles. *Limited to US and Canadian phone numbers.*
              # @param [String] in_postal_code Limit results to a particular postal code. Given
              #   a phone number, search within the same postal code as that number. *Limited to
              #   US and Canadian phone numbers.*
              # @param [String] in_region Limit results to a particular region (i.e. 
              #   State/Province). Given a phone number, search within the same Region as that
              #   number. *Limited to US and Canadian phone numbers.*
              # @param [String] in_rate_center Limit results to a specific rate center, or given
              #   a phone number search within the same rate center as that number. Requires
              #   InLata to be set as well. *Limited to US and Canadian phone numbers.*
              # @param [String] in_lata Limit results to a specific Local access and transport
              #   area ([LATA](http://en.wikipedia.org/wiki/Local_access_and_transport_area)).
              #   Given a phone number, search within the same
              #   [LATA](http://en.wikipedia.org/wiki/Local_access_and_transport_area) as that
              #   number. *Limited to US and Canadian phone numbers.*
              # @param [String] in_locality Limit results to a particular locality (i.e.  City).
              #   Given a phone number, search within the same Locality as that number. *Limited
              #   to US and Canadian phone numbers.*
              # @param [Boolean] fax_enabled This indicates whether the phone numbers can
              #   receive faxes. Possible values are `true` or `false`.
              # @param [String] page_token PageToken provided by the API
              # @param [Integer] page_number Page Number, this value is simply for client state
              # @param [Integer] page_size Number of records to return, defaults to 50
              # @return [Page] Page of LocalInstance
              def page(area_code: :unset, contains: :unset, sms_enabled: :unset, mms_enabled: :unset, voice_enabled: :unset, exclude_all_address_required: :unset, exclude_local_address_required: :unset, exclude_foreign_address_required: :unset, beta: :unset, near_number: :unset, near_lat_long: :unset, distance: :unset, in_postal_code: :unset, in_region: :unset, in_rate_center: :unset, in_lata: :unset, in_locality: :unset, fax_enabled: :unset, page_token: :unset, page_number: :unset, page_size: :unset)
                params = Twilio::Values.of({
                    'AreaCode' => area_code,
                    'Contains' => contains,
                    'SmsEnabled' => sms_enabled,
                    'MmsEnabled' => mms_enabled,
                    'VoiceEnabled' => voice_enabled,
                    'ExcludeAllAddressRequired' => exclude_all_address_required,
                    'ExcludeLocalAddressRequired' => exclude_local_address_required,
                    'ExcludeForeignAddressRequired' => exclude_foreign_address_required,
                    'Beta' => beta,
                    'NearNumber' => near_number,
                    'NearLatLong' => near_lat_long,
                    'Distance' => distance,
                    'InPostalCode' => in_postal_code,
                    'InRegion' => in_region,
                    'InRateCenter' => in_rate_center,
                    'InLata' => in_lata,
                    'InLocality' => in_locality,
                    'FaxEnabled' => fax_enabled,
                    'PageToken' => page_token,
                    'Page' => page_number,
                    'PageSize' => page_size,
                })
                response = @version.page(
                    'GET',
                    @uri,
                    params
                )
                LocalPage.new(@version, response, @solution)
              end

              ##
              # Retrieve a single page of LocalInstance records from the API.
              # Request is executed immediately.
              # @param [String] target_url API-generated URL for the requested results page
              # @return [Page] Page of LocalInstance
              def get_page(target_url)
                response = @version.domain.request(
                    'GET',
                    target_url
                )
                LocalPage.new(@version, response, @solution)
              end

              ##
              # Provide a user friendly representation
              def to_s
                '#<Twilio.Api.V2010.LocalList>'
              end
            end

            class LocalPage < Page
              ##
              # Initialize the LocalPage
              # @param [Version] version Version that contains the resource
              # @param [Response] response Response from the API
              # @param [Hash] solution Path solution for the resource
              # @return [LocalPage] LocalPage
              def initialize(version, response, solution)
                super(version, response)

                # Path Solution
                @solution = solution
              end

              ##
              # Build an instance of LocalInstance
              # @param [Hash] payload Payload response from the API
              # @return [LocalInstance] LocalInstance
              def get_instance(payload)
                LocalInstance.new(
                    @version,
                    payload,
                    account_sid: @solution[:account_sid],
                    country_code: @solution[:country_code],
                )
              end

              ##
              # Provide a user friendly representation
              def to_s
                '<Twilio.Api.V2010.LocalPage>'
              end
            end

            class LocalInstance < InstanceResource
              ##
              # Initialize the LocalInstance
              # @param [Version] version Version that contains the resource
              # @param [Hash] payload payload that contains response from Twilio
              # @param [String] account_sid The 34 character string that uniquely identifies
              #   your account.
              # @param [String] country_code The ISO Country code to lookup phone numbers for.
              # @return [LocalInstance] LocalInstance
              def initialize(version, payload, account_sid: nil, country_code: nil)
                super(version)

                # Marshaled Properties
                @properties = {
                    'friendly_name' => payload['friendly_name'],
                    'phone_number' => payload['phone_number'],
                    'lata' => payload['lata'],
                    'locality' => payload['locality'],
                    'rate_center' => payload['rate_center'],
                    'latitude' => payload['latitude'].to_f,
                    'longitude' => payload['longitude'].to_f,
                    'region' => payload['region'],
                    'postal_code' => payload['postal_code'],
                    'iso_country' => payload['iso_country'],
                    'address_requirements' => payload['address_requirements'],
                    'beta' => payload['beta'],
                    'capabilities' => payload['capabilities'],
                }
              end

              ##
              # @return [String] A nicely-formatted version of the phone number.
              def friendly_name
                @properties['friendly_name']
              end

              ##
              # @return [String] The phone number, in E.
              def phone_number
                @properties['phone_number']
              end

              ##
              # @return [String] The LATA of this phone number.
              def lata
                @properties['lata']
              end

              ##
              # @return [String] The locality/city of this phone number.
              def locality
                @properties['locality']
              end

              ##
              # @return [String] The rate center of this phone number.
              def rate_center
                @properties['rate_center']
              end

              ##
              # @return [String] The latitude coordinate of this phone number.
              def latitude
                @properties['latitude']
              end

              ##
              # @return [String] The longitude coordinate of this phone number.
              def longitude
                @properties['longitude']
              end

              ##
              # @return [String] The two-letter state or province abbreviation of this phone number.
              def region
                @properties['region']
              end

              ##
              # @return [String] The postal code of this phone number.
              def postal_code
                @properties['postal_code']
              end

              ##
              # @return [String] The ISO country code of this phone number.
              def iso_country
                @properties['iso_country']
              end

              ##
              # @return [String] This indicates whether the phone number requires you or your customer to have an Address registered with Twilio.
              def address_requirements
                @properties['address_requirements']
              end

              ##
              # @return [Boolean] Phone numbers new to the Twilio platform are marked as beta.
              def beta
                @properties['beta']
              end

              ##
              # @return [String] This is a set of boolean properties that indicate whether a phone number can receive calls or messages.
              def capabilities
                @properties['capabilities']
              end

              ##
              # Provide a user friendly representation
              def to_s
                "<Twilio.Api.V2010.LocalInstance>"
              end

              ##
              # Provide a detailed, user friendly representation
              def inspect
                "<Twilio.Api.V2010.LocalInstance>"
              end
            end
          end
        end
      end
    end
  end
end