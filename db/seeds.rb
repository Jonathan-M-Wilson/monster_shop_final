# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

@meg = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
@brian = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)

@merchant_user = User.create!(name: "Jose",
                              address: "789 Jkl St.",
                              city: "Denver",
                              state: "Colorado",
                              zip: "80202",
                              email: "merchant@hotmail.com",
                              password: "mer",
                              role: 1,
                              merchant_id: @meg.id)


@meg.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
@meg.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )
@brian.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )


@coupon_1 = @meg.coupons.create!(name: "4th of July 5%-Off 2 or more", code: "FREEDOM", min_items: 2, percent_off: 5, merchant: @meg)
@coupon_2 = @meg.coupons.create!(name: "Holiday Weekend 10%-Off 5 or more", code: "TAKE50", min_items: 5, percent_off: 10, merchant: @meg)
@coupon_3 = @meg.coupons.create!(name: "Bulk 20%-Off 20 or more", code: "BULK", min_items: 10, percent_off: 20, merchant: @meg, enabled: false)
