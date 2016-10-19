resorts = [
      "Alpine Meadows",
      "Alta",
      "Aspen",
      "Bear Valley",
      "Diamond Peak",
      "Dodge Ridge",
      "Donner Ski Ranch",
      "Homewood",
      "Jackson Hole",
      "Mt. Rose",
      "Soda Springs",
      "Snowbasin",
      "Snowbird",
      "Squaw Valley",
      "Sun Valley",
      "Sugar Bowl",
      "Tahoe Donner",
      "Taos"
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
  name: '1hr Early Bird',
  price: 89,
  location_id: 8,
  length: 1,
  slot: 'Morning',
  start_time: '9:00am',
  calendar_period: 'Regular'
  })
Product.create!({
  name: '1hr Early Bird',
  price: 119,
  location_id: 8,
  length: 1,
  slot: 'Morning',
  start_time: '9:00am',
  calendar_period: 'Peak'
  })
Product.create!({
  name: '1hr Early Bird',
  price: 129,
  location_id: 8,
  length: 1,
  slot: 'Morning',
  start_time: '9:00am',
  calendar_period: 'Holiday'
  })
Product.create!({
  name: 'Half-day Morning',
  price: 399,
  location_id: 8,
  length: 3,
  slot: 'Morning',
  start_time: '10:00am',
  calendar_period: 'Regular'
  })
Product.create!({
  name: 'Half-day Morning',
  price: 479,
  location_id: 8,
  length: 3,
  slot: 'Morning',
  start_time: '10:00am',
  calendar_period: 'Peak'
  })
Product.create!({
  name: 'Half-day Morning',
  price: 499,
  location_id: 8,
  length: 3,
  slot: 'Morning',
  start_time: '10:00am',
  calendar_period: 'Holiday'
  })
Product.create!({
  name: 'Half-day Afternoon',
  price: 399,
  location_id: 8,
  length: 3,
  slot: 'Afternoon',
  start_time: '1:00pm',
  calendar_period: 'Regular'
  })
Product.create!({
  name: 'Half-day Afternoon',
  price: 479,
  location_id: 8,
  length: 3,
  slot: 'Afternoon',
  start_time: '1:00pm',
  calendar_period: 'Peak'
  })
Product.create!({
  name: 'Half-day Afternoon',
  price: 499,
  location_id: 8,
  length: 3,
  slot: 'Afternoon',
  start_time: '1:00pm',
  calendar_period: 'Holiday'
  })
Product.create!({
  name: 'Full-day Private',
  price: 499,
  location_id: 8,
  length: 6,
  slot: 'All Day',
  start_time: '10:00am',
  calendar_period: 'Regular'
  })
Product.create!({
  name: 'Full-day Private',
  price: 599,
  location_id: 8,
  length: 6,
  slot: 'All Day',
  start_time: '10:00am',
  calendar_period: 'Peak'
  })
Product.create!({
  name: 'Full-day Private',
  price: 649,
  location_id: 8,
  length: 6,
  slot: 'All Day',
  start_time: '10:00am',
  calendar_period: 'Holiday'
  })

# LOAD SQUAW VALLEY PRODUCTS

Product.create!({
  name: 'Half-day Morning',
  price: 519,
  location_id: 14,
  length: 3,
  slot: 'Morning',
  start_time: '9:00am',
  calendar_period: 'Regular'
  })
Product.create!({
  name: 'Half-day Morning',
  price: 559,
  location_id: 14,
  length: 3,
  slot: 'Morning',
  start_time: '9:00am',
  calendar_period: 'Peak'
  })
Product.create!({
  name: 'Half-day Afternoon',
  price: 419,
  location_id: 14,
  length: 3,
  slot: 'Afternoon',
  start_time: '1:00pm',
  calendar_period: 'Regular'
  })
Product.create!({
  name: 'Half-day Afternoon',
  price: 459,
  location_id: 14,
  length: 3,
  slot: 'Afternoon',
  start_time: '1:00pm',
  calendar_period: 'Peak'
  })
Product.create!({
  name: 'Full-day Private',
  price: 739,
  location_id: 14,
  length: 7,
  slot: 'All Day',
  start_time: '9:00am',
  calendar_period: 'Regular'
  })
Product.create!({
  name: 'Full-day Private',
  price: 779,
  location_id: 14,
  length: 7,
  slot: 'All Day',
  start_time: '9:00am',
  calendar_period: 'Peak'
  })

puts "seed complete, locations created."
