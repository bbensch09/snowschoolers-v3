require 'test_helper'

class ResourcesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @resource = resources(:one)
  end

  test "should get index" do
    get resources_url
    assert_response :success
  end

  test "should get new" do
    get new_resource_url
    assert_response :success
  end

  test "should create resource" do
    assert_difference('Resource.count') do
      post resources_url, params: { resource: { binding_model: @resource.binding_model, board_model: @resource.board_model, boot_age: @resource.boot_age, boot_size: @resource.boot_size, boot_size_raw: @resource.boot_size_raw, gb_identifier: @resource.gb_identifier, is_boot: @resource.is_boot, manufacturer: @resource.manufacturer, non_unique_identifier: @resource.non_unique_identifier, ss_unique_identifier: @resource.ss_unique_identifier, status: @resource.status, type: @resource.type, walk_in_only: @resource.walk_in_only } }
    end

    assert_redirected_to resource_url(Resource.last)
  end

  test "should show resource" do
    get resource_url(@resource)
    assert_response :success
  end

  test "should get edit" do
    get edit_resource_url(@resource)
    assert_response :success
  end

  test "should update resource" do
    patch resource_url(@resource), params: { resource: { binding_model: @resource.binding_model, board_model: @resource.board_model, boot_age: @resource.boot_age, boot_size: @resource.boot_size, boot_size_raw: @resource.boot_size_raw, gb_identifier: @resource.gb_identifier, is_boot: @resource.is_boot, manufacturer: @resource.manufacturer, non_unique_identifier: @resource.non_unique_identifier, ss_unique_identifier: @resource.ss_unique_identifier, status: @resource.status, type: @resource.type, walk_in_only: @resource.walk_in_only } }
    assert_redirected_to resource_url(@resource)
  end

  test "should destroy resource" do
    assert_difference('Resource.count', -1) do
      delete resource_url(@resource)
    end

    assert_redirected_to resources_url
  end
end
