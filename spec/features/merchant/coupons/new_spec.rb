require 'rails_helper'

RSpec.describe 'As a logged-in merchant user', type: :feature do
  before(:each) do
    @meg = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)

    @merchant_user = User.create!(name: "Jose",
                                  address: "789 Jkl St.",
                                  city: "Denver",
                                  state: "Colorado",
                                  zip: "80202",
                                  email: "merchant@hotmail.com",
                                  password: "mer",
                                  role: 1,
                                  merchant_id: @meg.id)

    @coupon_1 = @meg.coupons.create!(name: "4th of July 5%-Off 2 or more", code: "FREEDOM", min_items: 2, percent_off: 5, merchant: @meg)
    @coupon_2 = @meg.coupons.create!(name: "Holiday Weekend 10%-Off 5 or more", code: "TAKE50", min_items: 5, percent_off: 10, merchant: @meg)
    @coupon_3 = @meg.coupons.create!(name: "Bulk 20%-Off 20 or more", code: "BULK", min_items: 10, percent_off: 20, merchant: @meg, enabled: false)

    visit root_path
    click_on 'Log In'

    fill_in 'Email', with: @merchant_user.email
    fill_in 'Password', with: @merchant_user.password

    click_button 'Log In'
  end

  describe "When I visit my coupons index view page" do
    before(:each) do
      visit '/merchant'

      click_on 'Manage Coupons'
    end

    it 'I see a link to "Create New Coupon"' do
      expect(page).to have_link('Create New Coupon', href: '/merchant/coupons/new')
    end

    describe 'When I click on the "Create New Coupon" link' do
      before(:each) do
        click_link 'Create New Coupon'
      end

      it 'I see a form that has fields for a coupon name, code, and percent off' do
        expect(current_path).to eq('/merchant/coupons/new')
        expect(page).to have_field('Name')
        expect(page).to have_field('Code')
        expect(page).to have_field('Min items')
        expect(page).to have_field('Percent Off')
      end

      describe "I can fill out each field and click 'Create Coupon' if the fields are valid" do
        before(:each) do
          fill_in 'Name', with: "Hot Summer Deal"
          fill_in 'Code', with: 'SummerSavings'
          fill_in 'Min items', with: 5
          fill_in 'Percent Off', with: '80%'


          click_button 'Create Coupon'
        end

        it 'After clicking on the Create Coupon button, I am returned to my coupons index where I see that coupon listed with all the info and the status is Enabled' do
          expect(current_path).to eq('/merchant/coupons')

          within "#coupon-#{Coupon.last.id}" do
            expect(page).to have_content("#{Coupon.last.id}")
            expect(page).to have_content("Hot Summer Deal")
            expect(page).to have_content("SummerSavings")
            expect(page).to have_content(5)
            expect(page).to have_content("80%")
            expect(page).to have_content("Enabled")
          end
        end
      end

      describe 'If not all of the fields are valid or filled in' do
        it 'I see an error message and I am returned to the form where it shows my previously entered info' do
          fill_in 'Name', with: "Hot Summer Deal"
          fill_in 'Percent Off', with: '80%'

          click_button 'Create Coupon'

          expect(page).to have_content("Code can't be blank")
          expect(page).to have_css('h1', text: 'Create New Coupon')
          expect(page.find_field('Name').value).to eq("Hot Summer Deal")
          expect(page.find_field('Percent Off').value).to eq("80%")

          fill_in 'Name', with: ''
          fill_in 'Code', with: 'HOT'

          click_button 'Create Coupon'

          expect(page).to have_content("Name can't be blank")
          expect(page).to have_css('h1', text: 'Create New Coupon')
          expect(page.find_field('Name').value).to eq('')
          expect(page.find_field('Code').value).to eq('HOT')
          expect(page.find_field('Percent Off').value).to eq("80%")
        end
      end

      describe 'When I enter a name or code that already exists' do
        it 'I see an error message and am returned to the form which shows my previously entered info' do
          fill_in 'Name', with: @coupon_1.name
          fill_in 'Code', with: 'FREEDOM'
          fill_in 'Percent Off', with: '30%'

          click_button 'Create Coupon'

          expect(page).to have_content("Name has already been taken")
          expect(page.find('h1').text).to eq('Create New Coupon')
          expect(page.find_field('Name').value).to eq(@coupon_1.name)
          expect(page.find_field('Code').value).to eq('FREEDOM')
          expect(page.find_field('Percent Off').value).to eq("30%")

          fill_in 'Name', with: 'Another One: Dj Khalid'
          fill_in 'Code', with: @coupon_1.code

          click_button 'Create Coupon'

          expect(page).to have_content("Code has already been taken")
          expect(page.find('h1').text).to eq('Create New Coupon')
          expect(page.find_field('Name').value).to eq('Another One: Dj Khalid')
          expect(page.find_field('Code').value).to eq(@coupon_1.code)
          expect(page.find_field('Percent Off').value).to eq("30%")
        end
      end

      describe 'When I enter a percent off value outside of 0-100' do
        before(:each) do
          fill_in 'Name', with: "Another Deal"
          fill_in 'Code', with: 'Another1'
          fill_in 'Percent Off', with: '101%'

          click_button 'Create Coupon'
        end

        it 'I see an error message and am returned to the form which shows my previously entered info' do
          expect(page).to have_content("Percent off Field is empty or range is outside 0-100")
          expect(page.find('h1').text).to eq('Create New Coupon')
          expect(page.find_field('Name').value).to eq('Another Deal')
          expect(page.find_field('Code').value).to eq('Another1')
          expect(page.find_field('Percent Off').value).to eq("101%")
        end
      end
    end
  end
end
