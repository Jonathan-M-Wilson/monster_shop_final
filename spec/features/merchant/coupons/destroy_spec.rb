require 'rails_helper'

RSpec.describe 'As a logged-in merchant user', type: :feature do
  describe 'when I visit the coupons index' do
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

      @coupon_1 = Coupon.create!(name: "4th of July 30%-Off", code: "FREEDOM", percent_off: 30, merchant: @meg)
      @coupon_2 = Coupon.create!(name: "Holiday Weekend 50%-Off", code: "TAKE50", percent_off: 50, merchant: @meg)
      @coupon_3 = Coupon.create!(name: "Bulk 5%-Off", code: "BULK", percent_off: 5, merchant: @meg, enabled: false)

      visit root_path
      click_on 'Log In'

      fill_in 'Email', with: @merchant_user.email
      fill_in 'Password', with: @merchant_user.password

      click_button 'Log In'
    end

    describe "When I click on the delete button next to a coupon that is disabled" do
      before(:each) do

        visit '/merchant'

        click_on 'Manage Coupons'

        within "#coupon-#{@coupon_3.id}" do
          click_on 'Delete'
        end
      end

      it 'After clicking on the Delete button, I remain on the coupons index' do
        expect(current_path).to eq('/merchant/coupons')
      end

      it "I see a flash message confirming this coupon was deleted" do
        expect(page).to have_content "This coupon has been Deleted"
      end

      it 'and it no longer appears on the coupon index' do
        expect(page).not_to have_css("#coupon-#{@coupon_3.id}")
        expect(page).not_to have_content("#{@coupon_3.id}")
        expect(page).not_to have_content("#{@coupon_3.name}")
        expect(page).not_to have_content("#{@coupon_3.code}")
      end
    end

    describe 'When I click on the delete button next to a coupon that is currently enabled' do
      before(:each) do
        visit '/merchant'

        click_on 'Manage Coupons'

        within "#coupon-#{@coupon_1.id}" do
          click_on 'Delete'
        end
      end

      it "I see a flash message saying it couldn't be deleted" do
        expect(page).to have_content("This coupon is currently in use. Please disable before Deleting")
      end

      it "If coupon is enabled and you click delete coupon, the coupon remains in index" do
        expect(page).to have_css("#coupon-#{@coupon_1.id}")
        expect(page).to have_content("#{@coupon_1.id}")
        expect(page).to have_content("#{@coupon_1.name}")
        expect(page).to have_content("#{@coupon_1.code}")
      end
    end
  end
end
