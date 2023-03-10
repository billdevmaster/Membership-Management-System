require 'test_helper'

class ClientTest < ActiveSupport::TestCase
  def setup
    @client = Client.new(first_name: 'Amala',
                         last_name: 'Paw',
                         email: 'amala@thespace.in',
                         phone: '914567890',
                         instagram: '#paw',
                         note: 'our top client')
    @client2 = clients(:bhavik)
    @booked_class = wkclasses(:wkclass_2)
  end

  test 'should be valid' do
    assert_predicate @client, :valid?
  end

  test 'first name should be present' do
    @client.first_name = '     '
    refute_predicate @client, :valid?
  end

  test 'last name should be present' do
    @client.last_name = '     '
    refute_predicate @client, :valid?
  end

  test 'first_name should not be too long' do
    @client.first_name = 'a' * 41
    refute_predicate @client, :valid?
  end

  test 'last_name should not be too long' do
    @client.last_name = 'a' * 41
    refute_predicate @client, :valid?
  end

  test 'full name should be unique' do
    duplicate_named_client = Client.new(first_name: @client.first_name, last_name: @client.last_name)
    @client.save
    refute_predicate duplicate_named_client, :valid?
  end

  test 'email should not be too long' do
    @client.email = "#{'a' * 244}@example.com"
    refute_predicate @client, :valid?
  end

  test 'email validation should accept valid addresses' do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @client.email = valid_address
      assert_predicate @client, :valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test 'email validation should reject invalid addresses' do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @client.email = invalid_address
      refute_predicate @client, :valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test 'email addresses should be unique' do
    duplicate_client = @client.dup
    duplicate_client.email = @client.email.upcase
    @client.save
    refute_predicate duplicate_client, :valid?
  end

  test 'email addresses should be saved as lower-case' do
    mixed_case_email = 'Foo@ExAMPle.CoM'
    @client.email = mixed_case_email
    @client.save
    assert_equal mixed_case_email.downcase, @client.reload.email
  end

  test 'name method' do
    assert_equal 'Amala Paw', @client.name
  end

  test 'booked? method' do
    assert @client2.booked? @booked_class
    refute @client.booked? @booked_class
  end

  test 'associated account (if there is one) should exist' do
    @client.account_id = 4000
    refute_predicate @client, :valid?
  end
end
