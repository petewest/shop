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

first_class=PostageService.find_or_create_by(name: "Royal Mail UK standard first class", default: true)

gbp=Currency.find_by(iso_code: "GBP")

#Postage costs from http://www.royalmail.com/sites/default/files/RM_OurPrices_Mar2014a.pdf
#UK standard 1st class for large letter & small parcel
first_class.postage_costs=PostageCost.create([
  {
    from_weight: 0,
    to_weight: 100,
    unit_cost: 93,
    currency: gbp
  },
  {
    from_weight: 100,
    to_weight: 250,
    unit_cost: 124,
    currency: gbp
  },
  {
    from_weight: 250,
    to_weight: 500,
    unit_cost: 165,
    currency: gbp
  },
  {
    from_weight: 500,
    to_weight: 750,
    unit_cost: 238,
    currency: gbp
  },
  {
    from_weight: 750,
    to_weight: 1000,
    unit_cost: 320,
    currency: gbp
  },
  {
    from_weight: 1000,
    to_weight: 2000,
    unit_cost: 545,
    currency: gbp
  }
])
