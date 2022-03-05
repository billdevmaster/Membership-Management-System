require "test_helper"
class PurchasesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @client1 = accounts(:client1)
    @client2 = accounts(:client2)
    @admin = accounts(:admin)
    @superadmin = accounts(:superadmin)
    @junioradmin = accounts(:junioradmin)
    @partner1 = accounts(:partner1)
    @partner2 = accounts(:partner2)
    @purchase1 = purchases(:aparna_package)
    @purchase2 = purchases(:aparna_dropin)
  end

  test "should redirect index when not logged in as admin or more senior" do
    get admin_purchases_url
    assert_redirected_to login_path
    [@client1, @partner1, @junioradmin].each do |account_holder|
      log_in_as(account_holder)
      get admin_purchases_url
      assert_redirected_to login_path
    end
  end

  test 'should redirect show when not logged in as admin or more senior' do
    get admin_purchase_path(@purchase1)
    assert_redirected_to login_path
    [@client1, @partner1, @junioradmin].each do |account_holder|
      log_in_as(account_holder)
      get admin_purchase_path(@purchase1)
      assert_redirected_to login_path
    end
  end

  # test 'should redirect edit when not logged in as junioradmin or more senior' do
  #   get edit_admin_client_path(@client2.clients.first)
  #   assert_redirected_to login_path
  #   log_in_as(@client1)
  #   get edit_admin_client_path(@client2.clients.first)
  #   assert_redirected_to login_path
  #   log_in_as(@partner1)
  #   get edit_admin_client_path(@client2.clients.first)
  #   assert_redirected_to login_path
  # end
  #
  # test 'should redirect create when not logged in as junior admin or more senior' do
  #   assert_no_difference 'Client.count' do
  #     post admin_clients_path, params: { client: { first_name: 'test', last_name: 'tester', email: 'example@example.com' } }
  #   end
  #   assert_redirected_to login_path
  #   log_in_as(@client1)
  #   assert_no_difference 'Client.count' do
  #     post admin_clients_path, params: { client: { first_name: 'test', last_name: 'tester', email: 'example@example.com' } }
  #   end
  #   assert_redirected_to login_path
  #   log_in_as(@partner1)
  #   assert_no_difference 'Client.count' do
  #     post admin_clients_path, params: { client: { first_name: 'test', last_name: 'tester', email: 'example@example.com' } }
  #   end
  #   assert_redirected_to login_path
  # end
  #
  # test 'should redirect update when not logged in as junior admin or more senior' do
  #   patch admin_client_path(@client2.clients.first), params: { client: { instagram: 'test' } }
  #   assert_redirected_to login_path
  #   log_in_as(@client1)
  #   patch admin_client_path(@client2.clients.first), params: { client: { instagram: 'test' } }
  #   assert_redirected_to login_path
  #   log_in_as(@partner1)
  #   patch admin_client_path(@client2.clients.first), params: { client: { instagram: 'test' } }
  #   assert_redirected_to login_path
  # end
  #
  # test 'should redirect destroy when not logged in as admin or more senior' do
  #   assert_no_difference 'Client.count' do
  #     delete admin_client_path(@client1.clients.first)
  #   end
  #   assert_redirected_to login_path
  #   log_in_as(@client1)
  #   assert_no_difference 'Client.count' do
  #     delete admin_client_path(@client1.clients.first)
  #   end
  #   assert_redirected_to login_path
  #   log_in_as(@partner1)
  #   assert_no_difference 'Client.count' do
  #     delete admin_client_path(@client1.clients.first)
  #   end
  #   assert_redirected_to login_path
  #   log_in_as(@junioradmin)
  #   assert_no_difference 'Client.count' do
  #     delete admin_client_path(@client1.clients.first)
  #   end
  #   assert_redirected_to login_path
  # end
end
