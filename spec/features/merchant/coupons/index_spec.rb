require 'rails_helper'

RSpec.describe 'As a merchant user', type: :feature do
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

  describe "When I visit my coupons index view page" do
    before(:each) do
      visit '/merchant'

      click_on 'Manage Coupons'
    end

    it 'I see the name, id, code, percent off, and status of all my coupons' do
      within "#coupon-#{@coupon_1.id}" do
        expect(page).to have_link("#{@coupon_1.id}", href: "/merchant/coupons/#{@coupon_1.id}")
        expect(page).to have_link("#{@coupon_1.name}", href: "/merchant/coupons/#{@coupon_1.id}")
        expect(page).to have_content("#{@coupon_1.code}")
        expect(page).to have_content("#{@coupon_1.percent_off}%")
        expect(page).to have_content("#{@coupon_1.enabled?}")
      end

      within "#coupon-#{@coupon_2.id}" do
        expect(page).to have_link("#{@coupon_2.id}", href: "/merchant/coupons/#{@coupon_2.id}")
        expect(page).to have_link("#{@coupon_2.name}", href: "/merchant/coupons/#{@coupon_2.id}")
        expect(page).to have_content("#{@coupon_2.code}")
        expect(page).to have_content("#{@coupon_2.percent_off}%")
        expect(page).to have_content("#{@coupon_2.enabled?}")
      end

      within "#coupon-#{@coupon_3.id}" do
        expect(page).to have_link("#{@coupon_3.id}", href: "/merchant/coupons/#{@coupon_3.id}")
        expect(page).to have_link("#{@coupon_3.name}", href: "/merchant/coupons/#{@coupon_3.id}")
        expect(page).to have_content("#{@coupon_3.code}")
        expect(page).to have_content("#{@coupon_3.percent_off}%")
        expect(page).to have_content("#{@coupon_3.enabled?}")
      end
    end

    it "should show both the id and name as links to that coupon's show page" do
      within "#coupon-#{@coupon_1.id}" do
        expect(page).to have_link("#{@coupon_1.id}", href: "/merchant/coupons/#{@coupon_1.id}")
        expect(page).to have_link("#{@coupon_1.name}", href: "/merchant/coupons/#{@coupon_1.id}")
      end

      within "#coupon-#{@coupon_2.id}" do
        expect(page).to have_link("#{@coupon_2.id}", href: "/merchant/coupons/#{@coupon_2.id}")
        expect(page).to have_link("#{@coupon_2.name}", href: "/merchant/coupons/#{@coupon_2.id}")
      end

      within "#coupon-#{@coupon_3.id}" do
        expect(page).to have_link("#{@coupon_3.id}", href: "/merchant/coupons/#{@coupon_3.id}")
        expect(page).to have_link("#{@coupon_3.name}", href: "/merchant/coupons/#{@coupon_3.id}")
      end
    end

    it "I see a button next to each coupon to delete that coupon" do
      within "#coupon-#{@coupon_1.id}" do
        expect(page).to have_button('Delete')
      end

      within "#coupon-#{@coupon_2.id}" do
        expect(page).to have_button('Delete')
      end

      within "#coupon-#{@coupon_3.id}" do
        expect(page).to have_button('Delete')
      end
    end

    it "I see a button to enable or disable this coupon depending on its status" do
      within "#coupon-#{@coupon_1.id}" do
        expect(page).to have_button('Disable')
      end

      within "#coupon-#{@coupon_2.id}" do
        expect(page).to have_button('Disable')
      end

      within "#coupon-#{@coupon_3.id}" do
        expect(page).to have_button('Enable')
      end
    end

    describe 'If I click the Disable button on an Enabled coupon' do
      before(:each) do
        within "#coupon-#{@coupon_1.id}" do
          click_on 'Disable'
        end
      end

      it 'I am returned to the coupon index page' do
        expect(current_path).to eq('/merchant/coupons')
      end

      it 'I see a flash message indicating coupon has been Disabled' do
        expect(page).to have_content("This coupon is now Disabled")
      end

      it 'I see the Disable button has been replaced with an Enable button' do
        within "#coupon-#{@coupon_1.id}" do
          expect(page).to have_button('Enable')
          expect(page).not_to have_button('Disable')
        end
      end
    end

    describe 'If I click the Enable button on a Disabled coupon' do
      before(:each) do
        within "#coupon-#{@coupon_3.id}" do
          click_on 'Enable'
        end
      end

      it 'I am returned to the coupon index page' do
        expect(current_path).to eq('/merchant/coupons')
      end

      it 'I see a flash message indicating coupon has been Enabled' do
        expect(page).to have_content("This coupon is now Enabled")
      end

      it 'I see the Enable button has been replaced with a Disable button' do
        within "#coupon-#{@coupon_3.id}" do
          expect(page).to have_button('Disable')
          expect(page).not_to have_button('Enable')
        end
      end
    end
  end
end
