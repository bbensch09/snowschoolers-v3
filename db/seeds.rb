# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

resorts = [
  "Bear Valley",
  "Boreal",
  "Diamond Peak",
  "Dodge Ridge",
  "Donner Ski Ranch",
  "Homewood",
  "Mt. Rose",
  "Soda Springs",
  "Sugar Bowl",
  "Tahoe Donner"]

resorts.each do |resort|
  Location.create!({
  name: resort
  })
end

puts "seed complete, locations created. #{Location.count} resorts have been added."
