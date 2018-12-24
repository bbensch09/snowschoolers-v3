##
# This code was generated by
# \ / _    _  _|   _  _
#  | (_)\/(_)(_|\/| |(/_  v1.0.0
#       /       /
# 
# frozen_string_literal: true

module Twilio
  module REST
    class Sync < Domain
      class V1 < Version
        class ServiceContext < InstanceContext
          class SyncListContext < InstanceContext
            ##
            # PLEASE NOTE that this class contains beta products that are subject to change. Use them with caution.
            class SyncListItemList < ListResource
              ##
              # Initialize the SyncListItemList
              # @param [Version] version Version that contains the resource
              # @param [String] service_sid The unique SID identifier of the Service Instance
              #   that hosts this List object.
              # @param [String] list_sid The unique 34-character SID identifier of the List
              #   containing this Item.
              # @return [SyncListItemList] SyncListItemList
              def initialize(version, service_sid: nil, list_sid: nil)
                super(version)

                # Path Solution
                @solution = {service_sid: service_sid, list_sid: list_sid}
                @uri = "/Services/#{@solution[:service_sid]}/Lists/#{@solution[:list_sid]}/Items"
              end

              ##
              # Retrieve a single page of SyncListItemInstance records from the API.
              # Request is executed immediately.
              # @param [Hash] data Contains arbitrary user-defined, schema-less data that this
              #   List Item stores, represented by a JSON object, up to 16KB.
              # @param [String] ttl Alias for item_ttl. If both are provided, this value is
              #   ignored.
              # @param [String] item_ttl Time-to-live of this item in seconds, defaults to no
              #   expiration. In the range [1, 31 536 000 (1 year)], or 0 for infinity. Upon
              #   expiry, the list item will be cleaned up at least in a matter of hours, and
              #   often within seconds, making this a good tool for garbage management.
              # @param [String] collection_ttl Time-to-live of this item's parent List in
              #   seconds, defaults to no expiration. In the range [1, 31 536 000 (1 year)], or 0
              #   for infinity.
              # @return [SyncListItemInstance] Newly created SyncListItemInstance
              def create(data: nil, ttl: :unset, item_ttl: :unset, collection_ttl: :unset)
                data = Twilio::Values.of({
                    'Data' => Twilio.serialize_object(data),
                    'Ttl' => ttl,
                    'ItemTtl' => item_ttl,
                    'CollectionTtl' => collection_ttl,
                })

                payload = @version.create(
                    'POST',
                    @uri,
                    data: data
                )

                SyncListItemInstance.new(
                    @version,
                    payload,
                    service_sid: @solution[:service_sid],
                    list_sid: @solution[:list_sid],
                )
              end

              ##
              # Lists SyncListItemInstance records from the API as a list.
              # Unlike stream(), this operation is eager and will load `limit` records into
              # memory before returning.
              # @param [sync_list_item.QueryResultOrder] order A string; `asc` or `desc`
              # @param [String] from An integer representing Item index offset (inclusive). If
              #   not present, query is performed from the start or end, depending on the Order
              #   query parameter.
              # @param [sync_list_item.QueryFromBoundType] bounds The bounds
              # @param [Integer] limit Upper limit for the number of records to return. stream()
              #    guarantees to never return more than limit.  Default is no limit
              # @param [Integer] page_size Number of records to fetch per request, when
              #    not set will use the default value of 50 records.  If no page_size is defined
              #    but a limit is defined, stream() will attempt to read the limit with the most
              #    efficient page size, i.e. min(limit, 1000)
              # @return [Array] Array of up to limit results
              def list(order: :unset, from: :unset, bounds: :unset, limit: nil, page_size: nil)
                self.stream(order: order, from: from, bounds: bounds, limit: limit, page_size: page_size).entries
              end

              ##
              # Streams SyncListItemInstance records from the API as an Enumerable.
              # This operation lazily loads records as efficiently as possible until the limit
              # is reached.
              # @param [sync_list_item.QueryResultOrder] order A string; `asc` or `desc`
              # @param [String] from An integer representing Item index offset (inclusive). If
              #   not present, query is performed from the start or end, depending on the Order
              #   query parameter.
              # @param [sync_list_item.QueryFromBoundType] bounds The bounds
              # @param [Integer] limit Upper limit for the number of records to return. stream()
              #    guarantees to never return more than limit. Default is no limit.
              # @param [Integer] page_size Number of records to fetch per request, when
              #    not set will use the default value of 50 records. If no page_size is defined
              #    but a limit is defined, stream() will attempt to read the limit with the most
              #    efficient page size, i.e. min(limit, 1000)
              # @return [Enumerable] Enumerable that will yield up to limit results
              def stream(order: :unset, from: :unset, bounds: :unset, limit: nil, page_size: nil)
                limits = @version.read_limits(limit, page_size)

                page = self.page(order: order, from: from, bounds: bounds, page_size: limits[:page_size], )

                @version.stream(page, limit: limits[:limit], page_limit: limits[:page_limit])
              end

              ##
              # When passed a block, yields SyncListItemInstance records from the API.
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
              # Retrieve a single page of SyncListItemInstance records from the API.
              # Request is executed immediately.
              # @param [sync_list_item.QueryResultOrder] order A string; `asc` or `desc`
              # @param [String] from An integer representing Item index offset (inclusive). If
              #   not present, query is performed from the start or end, depending on the Order
              #   query parameter.
              # @param [sync_list_item.QueryFromBoundType] bounds The bounds
              # @param [String] page_token PageToken provided by the API
              # @param [Integer] page_number Page Number, this value is simply for client state
              # @param [Integer] page_size Number of records to return, defaults to 50
              # @return [Page] Page of SyncListItemInstance
              def page(order: :unset, from: :unset, bounds: :unset, page_token: :unset, page_number: :unset, page_size: :unset)
                params = Twilio::Values.of({
                    'Order' => order,
                    'From' => from,
                    'Bounds' => bounds,
                    'PageToken' => page_token,
                    'Page' => page_number,
                    'PageSize' => page_size,
                })
                response = @version.page(
                    'GET',
                    @uri,
                    params
                )
                SyncListItemPage.new(@version, response, @solution)
              end

              ##
              # Retrieve a single page of SyncListItemInstance records from the API.
              # Request is executed immediately.
              # @param [String] target_url API-generated URL for the requested results page
              # @return [Page] Page of SyncListItemInstance
              def get_page(target_url)
                response = @version.domain.request(
                    'GET',
                    target_url
                )
                SyncListItemPage.new(@version, response, @solution)
              end

              ##
              # Provide a user friendly representation
              def to_s
                '#<Twilio.Sync.V1.SyncListItemList>'
              end
            end

            ##
            # PLEASE NOTE that this class contains beta products that are subject to change. Use them with caution.
            class SyncListItemPage < Page
              ##
              # Initialize the SyncListItemPage
              # @param [Version] version Version that contains the resource
              # @param [Response] response Response from the API
              # @param [Hash] solution Path solution for the resource
              # @return [SyncListItemPage] SyncListItemPage
              def initialize(version, response, solution)
                super(version, response)

                # Path Solution
                @solution = solution
              end

              ##
              # Build an instance of SyncListItemInstance
              # @param [Hash] payload Payload response from the API
              # @return [SyncListItemInstance] SyncListItemInstance
              def get_instance(payload)
                SyncListItemInstance.new(
                    @version,
                    payload,
                    service_sid: @solution[:service_sid],
                    list_sid: @solution[:list_sid],
                )
              end

              ##
              # Provide a user friendly representation
              def to_s
                '<Twilio.Sync.V1.SyncListItemPage>'
              end
            end

            ##
            # PLEASE NOTE that this class contains beta products that are subject to change. Use them with caution.
            class SyncListItemContext < InstanceContext
              ##
              # Initialize the SyncListItemContext
              # @param [Version] version Version that contains the resource
              # @param [String] service_sid The service_sid
              # @param [String] list_sid The list_sid
              # @param [String] index The index
              # @return [SyncListItemContext] SyncListItemContext
              def initialize(version, service_sid, list_sid, index)
                super(version)

                # Path Solution
                @solution = {service_sid: service_sid, list_sid: list_sid, index: index, }
                @uri = "/Services/#{@solution[:service_sid]}/Lists/#{@solution[:list_sid]}/Items/#{@solution[:index]}"
              end

              ##
              # Fetch a SyncListItemInstance
              # @return [SyncListItemInstance] Fetched SyncListItemInstance
              def fetch
                params = Twilio::Values.of({})

                payload = @version.fetch(
                    'GET',
                    @uri,
                    params,
                )

                SyncListItemInstance.new(
                    @version,
                    payload,
                    service_sid: @solution[:service_sid],
                    list_sid: @solution[:list_sid],
                    index: @solution[:index],
                )
              end

              ##
              # Deletes the SyncListItemInstance
              # @return [Boolean] true if delete succeeds, true otherwise
              def delete
                @version.delete('delete', @uri)
              end

              ##
              # Update the SyncListItemInstance
              # @param [Hash] data Contains arbitrary user-defined, schema-less data that this
              #   List Item stores, represented by a JSON object, up to 16KB.
              # @param [String] ttl Alias for item_ttl. If both are provided, this value is
              #   ignored.
              # @param [String] item_ttl Time-to-live of this item in seconds, defaults to no
              #   expiration. In the range [1, 31 536 000 (1 year)], or 0 for infinity. Upon
              #   expiry, the list item will be cleaned up at least in a matter of hours, and
              #   often within seconds, making this a good tool for garbage management.
              # @param [String] collection_ttl Time-to-live of this item's parent List in
              #   seconds, defaults to no expiration. In the range [1, 31 536 000 (1 year)], or 0
              #   for infinity.
              # @return [SyncListItemInstance] Updated SyncListItemInstance
              def update(data: :unset, ttl: :unset, item_ttl: :unset, collection_ttl: :unset)
                data = Twilio::Values.of({
                    'Data' => Twilio.serialize_object(data),
                    'Ttl' => ttl,
                    'ItemTtl' => item_ttl,
                    'CollectionTtl' => collection_ttl,
                })

                payload = @version.update(
                    'POST',
                    @uri,
                    data: data,
                )

                SyncListItemInstance.new(
                    @version,
                    payload,
                    service_sid: @solution[:service_sid],
                    list_sid: @solution[:list_sid],
                    index: @solution[:index],
                )
              end

              ##
              # Provide a user friendly representation
              def to_s
                context = @solution.map {|k, v| "#{k}: #{v}"}.join(',')
                "#<Twilio.Sync.V1.SyncListItemContext #{context}>"
              end
            end

            ##
            # PLEASE NOTE that this class contains beta products that are subject to change. Use them with caution.
            class SyncListItemInstance < InstanceResource
              ##
              # Initialize the SyncListItemInstance
              # @param [Version] version Version that contains the resource
              # @param [Hash] payload payload that contains response from Twilio
              # @param [String] service_sid The unique SID identifier of the Service Instance
              #   that hosts this List object.
              # @param [String] list_sid The unique 34-character SID identifier of the List
              #   containing this Item.
              # @param [String] index The index
              # @return [SyncListItemInstance] SyncListItemInstance
              def initialize(version, payload, service_sid: nil, list_sid: nil, index: nil)
                super(version)

                # Marshaled Properties
                @properties = {
                    'index' => payload['index'].to_i,
                    'account_sid' => payload['account_sid'],
                    'service_sid' => payload['service_sid'],
                    'list_sid' => payload['list_sid'],
                    'url' => payload['url'],
                    'revision' => payload['revision'],
                    'data' => payload['data'],
                    'date_expires' => Twilio.deserialize_iso8601_datetime(payload['date_expires']),
                    'date_created' => Twilio.deserialize_iso8601_datetime(payload['date_created']),
                    'date_updated' => Twilio.deserialize_iso8601_datetime(payload['date_updated']),
                    'created_by' => payload['created_by'],
                }

                # Context
                @instance_context = nil
                @params = {
                    'service_sid' => service_sid,
                    'list_sid' => list_sid,
                    'index' => index || @properties['index'],
                }
              end

              ##
              # Generate an instance context for the instance, the context is capable of
              # performing various actions.  All instance actions are proxied to the context
              # @return [SyncListItemContext] SyncListItemContext for this SyncListItemInstance
              def context
                unless @instance_context
                  @instance_context = SyncListItemContext.new(
                      @version,
                      @params['service_sid'],
                      @params['list_sid'],
                      @params['index'],
                  )
                end
                @instance_context
              end

              ##
              # @return [String] Contains the numeric index of this List Item.
              def index
                @properties['index']
              end

              ##
              # @return [String] The unique SID identifier of the Twilio Account.
              def account_sid
                @properties['account_sid']
              end

              ##
              # @return [String] The unique SID identifier of the Service Instance that hosts this List object.
              def service_sid
                @properties['service_sid']
              end

              ##
              # @return [String] The unique 34-character SID identifier of the List containing this Item.
              def list_sid
                @properties['list_sid']
              end

              ##
              # @return [String] The absolute URL for this item.
              def url
                @properties['url']
              end

              ##
              # @return [String] Contains the current revision of this item, represented by a string identifier.
              def revision
                @properties['revision']
              end

              ##
              # @return [Hash] Contains arbitrary user-defined, schema-less data that this List Item stores, represented by a JSON object, up to 16KB.
              def data
                @properties['data']
              end

              ##
              # @return [Time] Contains the date this item expires and gets deleted automatically.
              def date_expires
                @properties['date_expires']
              end

              ##
              # @return [Time] The date this item was created, given in UTC ISO 8601 format.
              def date_created
                @properties['date_created']
              end

              ##
              # @return [Time] Specifies the date this item was last updated, given in UTC ISO 8601 format.
              def date_updated
                @properties['date_updated']
              end

              ##
              # @return [String] The identity of this item's creator.
              def created_by
                @properties['created_by']
              end

              ##
              # Fetch a SyncListItemInstance
              # @return [SyncListItemInstance] Fetched SyncListItemInstance
              def fetch
                context.fetch
              end

              ##
              # Deletes the SyncListItemInstance
              # @return [Boolean] true if delete succeeds, true otherwise
              def delete
                context.delete
              end

              ##
              # Update the SyncListItemInstance
              # @param [Hash] data Contains arbitrary user-defined, schema-less data that this
              #   List Item stores, represented by a JSON object, up to 16KB.
              # @param [String] ttl Alias for item_ttl. If both are provided, this value is
              #   ignored.
              # @param [String] item_ttl Time-to-live of this item in seconds, defaults to no
              #   expiration. In the range [1, 31 536 000 (1 year)], or 0 for infinity. Upon
              #   expiry, the list item will be cleaned up at least in a matter of hours, and
              #   often within seconds, making this a good tool for garbage management.
              # @param [String] collection_ttl Time-to-live of this item's parent List in
              #   seconds, defaults to no expiration. In the range [1, 31 536 000 (1 year)], or 0
              #   for infinity.
              # @return [SyncListItemInstance] Updated SyncListItemInstance
              def update(data: :unset, ttl: :unset, item_ttl: :unset, collection_ttl: :unset)
                context.update(data: data, ttl: ttl, item_ttl: item_ttl, collection_ttl: collection_ttl, )
              end

              ##
              # Provide a user friendly representation
              def to_s
                values = @params.map{|k, v| "#{k}: #{v}"}.join(" ")
                "<Twilio.Sync.V1.SyncListItemInstance #{values}>"
              end

              ##
              # Provide a detailed, user friendly representation
              def inspect
                values = @properties.map{|k, v| "#{k}: #{v}"}.join(" ")
                "<Twilio.Sync.V1.SyncListItemInstance #{values}>"
              end
            end
          end
        end
      end
    end
  end
end