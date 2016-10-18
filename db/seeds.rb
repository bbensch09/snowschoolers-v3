resorts = [
      "Alta",
      "Bear Valley",
      "Diamond Peak",
      "Dodge Ridge",
      "Donner Ski Ranch",
      "Homewood",
      "Mt. Rose",
      "Soda Springs",
      "Snowbasin",
      "Snowbird",
      "Sugar Bowl",
      "Tahoe Donner"
      ]
resorts.each do |resort|
  Location.create!({
  name: resort
  })
end

fake_instructor_emails = [
  "brian+hw_instructor_1@snowschoolers.com",
  "brian+hw_instructor_2@snowschoolers.com",
  "brian+hw_admin@snowschoolers.com",
  "brian+bv_instructor_1@snowschoolers.com",
  "brian+bv_instructor_2@snowschoolers.com",
]

fake_instructor_emails.each do |email|
User.create!({
  email: email,
  password: "password",
  user_type: "Partner",
  })

puts "User created: #{User.last.email}."

Instructor.create!({
  first_name: Faker::Name.first_name,
  last_name: Faker::Name.last_name,
  username: email,
  phone_number: "408-315-2900",
  city: "Powder Paradise, CA",
  sport: "Ski Instructor",
  certification: ['PSIA Level 1','PSIA Level 2','PSIA Level 3','AASI Level 1','AASI Level 2'].sample,
  intro: "I want to teach for Snow Schoolers!!!!",
  bio: "I am the best instructor on the mountain. period.",
  location_ids: [6,2], #just Alta & Bear Valley
  # location_ids: [1,2,3,4,5,6,7,8,9,10,11,12],
  adults_initial_rank: rand(1..10),
  kids_initial_rank: rand(1..10),
  overall_initial_rank: rand(1..10),
  status: 'Active',
  user_id: User.last.id
  })

puts "Instructor created: #{Instructor.last.first_name}."

end

Instructor.create!({
  first_name: "Shane",
  last_name: "McSki School",
  username: "brian@snowschoolers.com",
  phone_number: "408-315-2900",
  city: "San Francisco",
  sport: "Ski Instructor",
  certification: "Level 1 PSIA",
  intro: "I am the founder.",
  bio: "I am the best instructor on the mountain. period.",
  location_ids: [1,2], #just Alta & Bear Valley
  # location_ids: [1,2,3,4,5,6,7,8,9,10,11,12],
  adults_initial_rank: 10,
  kids_initial_rank: 10,
  overall_initial_rank: 10,
  status: 'Active'

  })

User.confirm_all_users

#LOAD HOMEWOOD PRODUCTS
Product.create!({
  name: '1hr Early Bird @9am',
  price: 89,
  location_id: 6,
  calendar_period: 'Regular'
  })
Product.create!({
  name: '3hr Half-day @10am',
  price: 399,
  location_id: 6,
  calendar_period: 'Regular'
  })
Product.create!({
  name: '3hr Half-day @1pm',
  price: 399,
  location_id: 6,
  calendar_period: 'Regular'
  })
Product.create!({
  name: 'Full-day @10am',
  price: 499,
  location_id: 6,
  calendar_period: 'Regular'
  })
Product.create!({
  name: '1hr Early Bird @9am',
  price: 119,
  location_id: 6,
  calendar_period: 'Peak'
  })
Product.create!({
  name: '3hr Half-day @10am',
  price: 479,
  location_id: 6,
  calendar_period: 'Peak'
  })
Product.create!({
  name: '3hr Half-day @1pm',
  price: 479,
  location_id: 6,
  calendar_period: 'Peak'
  })
Product.create!({
  name: 'Full-day @10am',
  price: 599,
  location_id: 6,
  calendar_period: 'Peak'
  })

#LOAD SUGAR BOWL PRODUCTS
Product.create!({
  name: '1hr Early Bird @9am',
  price: 109,
  location_id: 11,
  calendar_period: 'Regular'
  })
Product.create!({
  name: '3hr Half-day @10am',
  price: 449,
  location_id: 11,
  calendar_period: 'Regular'
  })
Product.create!({
  name: '3hr Half-day @1pm',
  price: 449,
  location_id: 11,
  calendar_period: 'Regular'
  })
Product.create!({
  name: 'Full-day @10am',
  price: 699,
  location_id: 11,
  calendar_period: 'Regular'
  })
Product.create!({
  name: '1hr Early Bird @9am',
  price: 139,
  location_id: 11,
  calendar_period: 'Peak'
  })
Product.create!({
  name: '3hr Half-day @10am',
  price: 499,
  location_id: 11,
  calendar_period: 'Peak'
  })
Product.create!({
  name: '3hr Half-day @1pm',
  price: 499,
  location_id: 11,
  calendar_period: 'Peak'
  })
Product.create!({
  name: 'Full-day @10am',
  price: 749,
  location_id: 11,
  calendar_period: 'Peak'
  })

puts "seed complete, locations created."
