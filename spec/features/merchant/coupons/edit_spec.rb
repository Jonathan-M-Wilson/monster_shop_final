require 'rails_helper'

RSpec.describe 'As a logged-in Merchant user', type: :feature do
  describe 'When I have coupons created and I visit "Manage Coupons" ' do
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

      visit '/merchant'

      click_on 'Manage Coupons'
    end

    it 'I should see an "Edit" button for each coupon' do
      within "#coupon-#{@coupon_1.id}" do
        expect(page).to have_button('Edit')
      end

      within "#coupon-#{@coupon_2.id}" do
        expect(page).to have_button('Edit')
      end

      within "#coupon-#{@coupon_3.id}" do
        expect(page).to have_button('Edit')
      end
    end

    describe 'When I click the "Edit" button next to one of my coupons' do
      before(:each) do
        within "#coupon-#{@coupon_1.id}" do
          click_button('Edit')
        end
      end

      it 'I am taken to a form to edit this coupon' do
        expect(current_path).to eq("/merchant/coupons/#{@coupon_1.id}/edit")
      end

      it 'I see fields for name, code, and percent off with the pre-existing values' do
        expect(page).to have_content("Edit Coupon")
        expect(page).to have_field('Name', with: @coupon_1.name)
        expect(page).to have_field('Code', with: @coupon_1.code)
        expect(page).to have_field('Percent Off', with: "#{@coupon_1.percent_off}%")
      end

      describe 'When I enter change information and click "Update Coupon"' do
        before(:each) do
          fill_in 'Name', with: 'Changed Coupon Name'
          click_on 'Update Coupon'
        end

        it 'I am returned to my coupons index page and see the updated info' do
          within "#coupon-#{@coupon_1.id}" do
            expect(page).to have_content('Changed Coupon Name')
            expect(page).to have_content(@coupon_1.code)
            expect(page).to have_content(@coupon_1.percent_off)
            expect(page).not_to have_content('4th of July 30%-Off')
          end
        end
      end

      describe 'When I fail to fill in all fields' do
        it 'I see an error message and am returned to the form which shows my previously entered information' do
          fill_in 'Code', with: ""

          click_button 'Update Coupon'

          expect(page).to have_content("Code can't be blank")
          expect(page).to have_css('h1', text: 'Edit Coupon')
          expect(page.find_field('Name').value).to eq(@coupon_1.name)
          expect(page.find_field('Code').value).to eq("")
          expect(page.find_field('Percent Off').value).to eq("30%")

          fill_in 'Name', with: ''
          fill_in 'Code', with: 'VeryCool'

          click_button 'Update Coupon'

          expect(page).to have_content("Name can't be blank")
          expect(page).to have_css('h1', text: 'Edit Coupon')
          expect(page.find_field('Name').value).to eq('')
          expect(page.find_field('Code').value).to eq('VeryCool')
          expect(page.find_field('Percent Off').value).to eq("30%")
        end
      end

      describe 'When I enter a name or code that already exists' do
        it 'I see an error message and am returned to the form which shows my previously entered info' do
          fill_in 'Name', with: @coupon_2.name

          click_button 'Update Coupon'

          expect(page).to have_content("Name has already been taken")
          expect(page.find_field('Name').value).to eq(@coupon_2.name)
          expect(page.find_field('Code').value).to eq('FREEDOM')
          expect(page.find_field('Percent Off').value).to eq("30%")

          fill_in 'Name', with: 'Another One: Dj Khalid'
          fill_in 'Code', with: @coupon_2.code

          click_button 'Update Coupon'

          expect(page).to have_content("Code has already been taken")
          expect(page.find('h1').text).to eq('Edit Coupon')
          expect(page.find_field('Name').value).to eq('Another One: Dj Khalid')
          expect(page.find_field('Code').value).to eq(@coupon_2.code)
          expect(page.find_field('Percent Off').value).to eq("30%")
        end
      end

      describe 'When I enter a percent off value outside of 0-100' do
        before(:each) do
          fill_in 'Name', with: "Another Deal"
          fill_in 'Code', with: 'Another1'
          fill_in 'Percent Off', with: '101%'

          click_button 'Update Coupon'
        end

        it 'I see an error message and am returned to the form which shows my previously entered info' do
          expect(page).to have_content("Percent off Field is empty or range is outside 0-100")
          expect(page.find('h1').text).to eq('Edit Coupon')
          expect(page.find_field('Name').value).to eq('Another Deal')
          expect(page.find_field('Code').value).to eq('Another1')
          expect(page.find_field('Percent Off').value).to eq("101%")
        end
      end
    end
  end
end
