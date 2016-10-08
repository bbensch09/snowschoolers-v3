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
  "brian+instructor_1@snowschoolers.com",
  "brian+instructor_2@snowschoolers.com",
  "brian+instructor_3@snowschoolers.com",
  "brian+instructor_4@snowschoolers.com",
  "brian+instructor_5@snowschoolers.com",
]

fake_instructor_emails.each do |email|
User.create!({
  email: email,
  password: "password"
  })

puts "User created: #{User.last.email}."

Instructor.create!({
  first_name: Faker::Name.first_name,
  last_name: Faker::Name.last_name,
  username: email,
  phone_number: "408-315-2900",
  city: "Powder Paradise",
  sport: "Ski Instructor",
  certification: "Level 4000 FTW!",
  intro: "I want to teach for Snow Schoolers!!!!",
  bio: "I am the best instructor on the mountain. period.",
  location_ids: [1,2], #just Alta & Bear Valley
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

puts "seed complete, locations created."
