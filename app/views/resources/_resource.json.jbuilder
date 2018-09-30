json.extract! resource, :id, :type, :gb_identifier, :manufacturer, :board_model, :binding_model, :is_boot, :boot_age, :boot_size, :boot_size_raw, :status, :ss_unique_identifier, :non_unique_identifier, :walk_in_only, :created_at, :updated_at
json.url resource_url(resource, format: :json)
