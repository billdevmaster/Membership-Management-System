require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  setup do
    @junioradmin = accounts(:junioradmin)
    @admin = accounts(:admin)
    @superadmin = accounts(:superadmin)
    @account_partner = accounts(:partner1)
    @partner = @account_partner.partners.first
    @account_client = accounts(:client1)
    @client = @account_client.clients.first
  end

  test 'layout links when logged-in as superadmin' do
    log_in_as(@superadmin)
    follow_redirect!
    assert_template 'admin/clients/index'
    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/'
    assert_select 'a[href=?]', admin_clients_path
    assert_select 'a[href=?]', admin_wkclasses_path
    assert_select 'a[href=?]', admin_purchases_path
    assert_select 'a[href=?]', admin_fitternities_path
    assert_select 'a[href=?]', admin_instructors_path
    assert_select 'a[href=?]', admin_partners_path
    assert_select 'a[href=?]', admin_products_path
    assert_select 'a[href=?]', admin_workouts_path
    assert_select 'a[href=?]', admin_workout_groups_path
    assert_select 'a[href=?]', superadmin_expenses_path
    assert_select 'a[href=?]', superadmin_instructor_rates_path
    assert_select 'a[href=?]', logout_path
    assert_select 'a[href=?]', login_path, count: 0

    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/Aboutus.html'
    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/PackagePolicy.html'
    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/Charges.html'
    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/Privacy.html'
    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/Paymentpolicy.html'
    assert_select 'a[href=?]', 'https://thespacejuhu.in/blog/'
    assert_select 'a[href=?]', 'https://www.instagram.com/thespace.juhu/'
    assert_select 'a[href=?]', 'https://www.facebook.com/TheSpace.Mumbai/timeline'
    assert_select 'a[href=?]', 'https://wa.me/919619348427'
  end

  test 'layout links when logged-in as admin' do
    log_in_as(@admin)
    follow_redirect!
    assert_template 'admin/clients/index'
    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/'
    assert_select 'a[href=?]', admin_clients_path
    assert_select 'a[href=?]', admin_wkclasses_path
    assert_select 'a[href=?]', admin_purchases_path
    assert_select 'a[href=?]', admin_fitternities_path
    assert_select 'a[href=?]', admin_instructors_path
    assert_select 'a[href=?]', admin_partners_path
    assert_select 'a[href=?]', admin_products_path
    assert_select 'a[href=?]', admin_workouts_path
    assert_select 'a[href=?]', admin_workout_groups_path
    assert_select 'a[href=?]', superadmin_expenses_path, count: 0
    assert_select 'a[href=?]', superadmin_instructor_rates_path, count: 0
    assert_select 'a[href=?]', logout_path
    assert_select 'a[href=?]', login_path, count: 0

    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/Aboutus.html'
    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/PackagePolicy.html'
    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/Charges.html'
    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/Privacy.html'
    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/Paymentpolicy.html'
    assert_select 'a[href=?]', 'https://thespacejuhu.in/blog/'
    assert_select 'a[href=?]', 'https://www.instagram.com/thespace.juhu/'
    assert_select 'a[href=?]', 'https://www.facebook.com/TheSpace.Mumbai/timeline'
    assert_select 'a[href=?]', 'https://wa.me/919619348427'
  end

  test 'layout links when logged-in as junioradmin' do
    log_in_as(@junioradmin)
    follow_redirect!
    assert_template 'admin/clients/index'
    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/'
    assert_select 'a[href=?]', admin_clients_path
    assert_select 'a[href=?]', admin_wkclasses_path
    assert_select 'a[href=?]', admin_purchases_path
    assert_select 'a[href=?]', admin_fitternities_path
    assert_select 'a[href=?]', admin_instructors_path, count: 0
    assert_select 'a[href=?]', admin_partners_path, count: 0
    assert_select 'a[href=?]', admin_products_path
    assert_select 'a[href=?]', admin_workouts_path, count: 0
    assert_select 'a[href=?]', admin_workout_groups_path, count: 0
    assert_select 'a[href=?]', superadmin_expenses_path, count: 0
    assert_select 'a[href=?]', superadmin_instructor_rates_path, count: 0
    assert_select 'a[href=?]', logout_path
    assert_select 'a[href=?]', login_path, count: 0

    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/Aboutus.html'
    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/PackagePolicy.html'
    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/Charges.html'
    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/Privacy.html'
    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/Paymentpolicy.html'
    assert_select 'a[href=?]', 'https://thespacejuhu.in/blog/'
    assert_select 'a[href=?]', 'https://www.instagram.com/thespace.juhu/'
    assert_select 'a[href=?]', 'https://www.facebook.com/TheSpace.Mumbai/timeline'
    assert_select 'a[href=?]', 'https://wa.me/919619348427'
  end

  test 'layout links when logged-in as client' do
    log_in_as(@account_client)
    follow_redirect!
    assert_template 'client/clients/book'
    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/'
    assert_select 'a[href=?]', client_history_path(@client)
    assert_select 'a[href=?]', client_book_path(@client)
    assert_select 'a[href=?]', client_client_path(@client)
    assert_select 'a[href=?]', admin_clients_path, count: 0
    assert_select 'a[href=?]', admin_wkclasses_path, count: 0
    assert_select 'a[href=?]', admin_purchases_path, count: 0
    assert_select 'a[href=?]', admin_fitternities_path, count: 0
    assert_select 'a[href=?]', admin_clients_path, count: 0
    assert_select 'a[href=?]', admin_wkclasses_path, count: 0
    assert_select 'a[href=?]', admin_purchases_path, count: 0
    assert_select 'a[href=?]', admin_fitternities_path, count: 0
    assert_select 'a[href=?]', admin_instructors_path, count: 0
    assert_select 'a[href=?]', admin_partners_path, count: 0
    assert_select 'a[href=?]', admin_products_path, count: 0
    assert_select 'a[href=?]', admin_workouts_path, count: 0
    assert_select 'a[href=?]', admin_workout_groups_path, count: 0
    assert_select 'a[href=?]', superadmin_expenses_path, count: 0
    assert_select 'a[href=?]', superadmin_instructor_rates_path, count: 0
    assert_select 'a[href=?]', logout_path
    assert_select 'a[href=?]', login_path, count: 0

    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/Aboutus.html'
    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/PackagePolicy.html'
    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/Charges.html'
    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/Privacy.html'
    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/Paymentpolicy.html'
    assert_select 'a[href=?]', 'https://thespacejuhu.in/blog/'
    assert_select 'a[href=?]', 'https://www.instagram.com/thespace.juhu/'
    assert_select 'a[href=?]', 'https://www.facebook.com/TheSpace.Mumbai/timeline'
    assert_select 'a[href=?]', 'https://wa.me/919619348427'
  end

  test 'layout links when logged-in as partner' do
    log_in_as(@account_partner)
    follow_redirect!
    assert_template 'admin/partners/show'
    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/'
    assert_select 'a[href=?]', admin_workout_groups_path
    assert_select 'a[href=?]', admin_partner_path(@partner)
    assert_select 'a[href=?]', admin_clients_path, count: 0
    assert_select 'a[href=?]', admin_wkclasses_path, count: 0
    assert_select 'a[href=?]', admin_purchases_path, count: 0
    assert_select 'a[href=?]', admin_fitternities_path, count: 0
    assert_select 'a[href=?]', admin_clients_path, count: 0
    assert_select 'a[href=?]', admin_wkclasses_path, count: 0
    assert_select 'a[href=?]', admin_purchases_path, count: 0
    assert_select 'a[href=?]', admin_fitternities_path, count: 0
    assert_select 'a[href=?]', admin_instructors_path, count: 0
    assert_select 'a[href=?]', admin_partners_path, count: 0
    assert_select 'a[href=?]', admin_products_path, count: 0
    assert_select 'a[href=?]', admin_workouts_path, count: 0
    assert_select 'a[href=?]', superadmin_expenses_path, count: 0
    assert_select 'a[href=?]', superadmin_instructor_rates_path, count: 0
    assert_select 'a[href=?]', logout_path
    assert_select 'a[href=?]', login_path, count: 0

    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/Aboutus.html'
    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/PackagePolicy.html'
    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/Charges.html'
    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/Privacy.html'
    assert_select 'a[href=?]', 'https://www.thespacejuhu.in/Paymentpolicy.html'
    assert_select 'a[href=?]', 'https://thespacejuhu.in/blog/'
    assert_select 'a[href=?]', 'https://www.instagram.com/thespace.juhu/'
    assert_select 'a[href=?]', 'https://www.facebook.com/TheSpace.Mumbai/timeline'
    assert_select 'a[href=?]', 'https://wa.me/919619348427'
  end
end
