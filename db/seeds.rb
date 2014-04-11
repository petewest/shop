# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Currency.create([
  {
    iso_code: "GBP",
    symbol: "£",
    decimal_places: 2
  },
  {
    iso_code: "USD",
    symbol: "$",
    decimal_places: 2
  }
])

gbp=Currency.find_by(iso_code: "GBP")

#Postage costs from http://www.royalmail.com/sites/default/files/RM_OurPrices_Mar2014a.pdf
#UK standard 1st class for large letter & small parcel
PostageCost.create([
  {
    from_weight: 0,
    to_weight: 100,
    cost: 93,
    currency: gbp
  },
  {
    from_weight: 100,
    to_weight: 250,
    cost: 124,
    currency: gbp
  },
  {
    from_weight: 250,
    to_weight: 500,
    cost: 165,
    currency: gbp
  },
  {
    from_weight: 500,
    to_weight: 750,
    cost: 238,
    currency: gbp
  },
  {
    from_weight: 750,
    to_weight: 1000,
    cost: 320,
    currency: gbp
  },
  {
    from_weight: 1000,
    to_weight: 2000,
    cost: 545,
    currency: gbp
  }
])
