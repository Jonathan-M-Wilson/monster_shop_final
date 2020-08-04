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

  describe 'When I visit my coupons index' do
    before(:each) do
      visit '/merchant/coupons'
    end

    it "should show both the id and name as links to that coupon's show page" do
      expect(page).to have_link("#{@coupon_1.id}", href: "/merchant/coupons/#{@coupon_1.id}")
      expect(page).to have_link("#{@coupon_1.name}", href: "/merchant/coupons/#{@coupon_1.id}")
      expect(page).to have_link("#{@coupon_2.id}", href: "/merchant/coupons/#{@coupon_2.id}")
      expect(page).to have_link("#{@coupon_2.name}", href: "/merchant/coupons/#{@coupon_2.id}")
      expect(page).to have_link("#{@coupon_3.id}", href: "/merchant/coupons/#{@coupon_3.id}")
      expect(page).to have_link("#{@coupon_3.name}", href: "/merchant/coupons/#{@coupon_3.id}")
    end

    describe 'When I click on that ID or name for a coupon' do
      before(:each) do
        click_on @coupon_1.name
      end

      it 'I\'m taken to this coupon\'s show page"' do
        expect(current_path).to eq("/merchant/coupons/#{@coupon_1.id}")
      end

      describe "Once I am on the coupon's show page" do
        it " see that coupon's id, name, code, and percent_off" do
          expect(page).to have_content("#{@coupon_1.name} Information")
          expect(page).to have_content("ID: #{@coupon_1.id}")
          expect(page).to have_content("Name: #{@coupon_1.name}")
          expect(page).to have_content("Code: #{@coupon_1.code}")
          expect(page).to have_content("Status: #{@coupon_1.enabled?}")
          expect(page).to have_content("Percent Off: -#{@coupon_1.percent_off}%")
          expect(page).to have_content("Created: #{@coupon_1.created_at}")
          expect(page).to have_content("Last Updated: #{@coupon_1.updated_at}")
        end
      end
    end
  end
end
