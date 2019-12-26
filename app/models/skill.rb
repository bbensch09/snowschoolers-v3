class Skill < ApplicationRecord

def self.seed_skills
	Skill.delete_all
# create skiing skills - level 1
	Skill.create!({
	id: 1,
	sport_id: 1,
	name: "First-time fundamentals",
	description: "Learning about the parts of a ski, edges, bindings, tips tails; how to step into and out of skis.",
	ability_category: 'Beginner',
	ability_level: 1
	})
	Skill.create!({
	id: 2,
	sport_id: 1,
	name: "Athletic stance",
	description: "Feet shoulder width apart, knees & ankles slightly bent, and eyes up looking ahead.",
	ability_category: 'Beginner',
	ability_level: 1
	})
	Skill.create!({
	id: 3,
	sport_id: 1,
	name: "Walking in skis",
	description: "Take turns walking in one ski, sliding back & forth, and gliding on one foot",
	ability_category: 'Beginner',
	ability_level: 1
	})
	Skill.create!({
	id: 4,
	sport_id: 1,
	name: "Getting up after a fall",
	description: "Practiced at least two different ways, including taking our skis off if that's easiest.",
	ability_category: 'Beginner',
	ability_level: 1
	})
	
# create skiing skills - level 2
	Skill.create!({
	id: 5,
	sport_id: 1,
	name: "Stationary pizza / french fries",
	description: "While standing still, changing between the pizza wedge and parallel french fries",
	ability_category: 'Beginner',
	ability_level: 2
	})
	Skill.create!({
	id: 6,
	sport_id: 1,
	name: "Breaking wedge",
	description: "Making our skis into a 'pizza' in order to come to a full stop.",
	ability_category: 'Beginner',
	ability_level: 2
	})
	Skill.create!({
	id: 7,
	sport_id: 1,
	name: "Wedge turns to one side",
	description: "To turn to the left (or right), we shift pressure to our right (or left) ski and rotate in the direction we want to turn.",
	ability_category: 'Beginner',
	ability_level: 2
	})
	Skill.create!({
	id: 8,
	sport_id: 1,
	name: "Side stepping",
	description: "In order to walk up-hill, we position our skis perpendicular to the hill and take steps sideways uphill, engaging our uphill edges.",
	ability_category: 'Beginner',
	ability_level: 2
	})
	Skill.create!({
	id: 9,
	sport_id: 1,
	name: "Rope Tow",
	description: "Safely ride the rop tow by keeping skis straight, standing up tall, and letting bar pull us rather than leaning against it or pulling on it.",
	ability_category: 'Beginner',
	ability_level: 2
	})

# create skiing skills - level 3
	Skill.create!({
	id: 10,
	sport_id: 1,
	name: "Linked wedge turns",
	description: "Without stopping, we alternate between wedge turns to the left and then the right by shifting pressure to the outside ski.",
	ability_category: 'Beginner',
	ability_level: 3
	})
	Skill.create!({
	id: 11,
	sport_id: 1,
	name: "Herringbone",
	description: "An alternative way of walking uphill, using our skis in backwards 'V' shape to skate uphill",
	ability_category: 'Beginner',
	ability_level: 3
	})
	Skill.create!({
	id: 12,
	sport_id: 1,
	name: "Advanced breaking wedge",
	description: "Ability to use aggressive wedge shape to come to an abrupt stop even on steep terrain.",
	ability_category: 'Beginner',
	ability_level: 3
	})
	Skill.create!({
	id: 13,
	sport_id: 1,
	name: "J-Turns",
	description: "Completing a turn to one side by making a 'J' shape where we come to a full stop with our skis pointed slightly uphill",
	ability_category: 'Beginner',
	ability_level: 3
	})
	Skill.create!({
	id: 14,
	sport_id: 1,
	name: "Ride the Poma",
	description: "Can safely ride the poma to the first tower.",
	ability_category: 'Beginner',
	ability_level: 3
	})	

# create skiing skills - level 4
	Skill.create!({
	id: 15,
	sport_id: 1,
	name: "Linked turns at speed",
	description: "Can confidently link wedge turns on intermediate terrain.",
	ability_category: 'Beginner',
	ability_level: 4
	})
	Skill.create!({
	id: 16,
	sport_id: 1,
	name: "Wedge Christies",
	description: "Wedge Christie turns are characterized by the presence of a wedge in the initiation phase of the turn, and by the gradual steering of the skis (inside more than outside) to achieve a parallel skidded turn sometime during the shaping or early finish phase of the turn.",
	ability_category: 'Beginner',
	ability_level: 4
	})
	Skill.create!({
	id: 17,
	sport_id: 1,
	name: "Traversing",
	description: "Can traverse across intermediate terrain while fully engaging uphill edges.",
	ability_category: 'Beginner',
	ability_level: 4
	})
	Skill.create!({
	id: 18,
	sport_id: 1,
	name: "Navigating obstacles",
	description: "Can control shape and speed of turns to follow obstacle course without stopping or falling.",
	ability_category: 'Beginner',
	ability_level: 4
	})
# create skiing skills - level 5
	Skill.create!({
	id: 19,
	sport_id: 1,
	name: "Near Parallel Turns",
	description: "Can complete nearly parallel turns by shifting pressure from inside to outside ski and engaging inside edges, with only minimal wedge gap at turn initiation",
	ability_category: 'Intermediate',
	ability_level: 5
	})
	Skill.create!({
	id: 20,
	sport_id: 1,
	name: "Hockey Stops",
	description: "Can quickly rotate skis to left or right and then engage uphill edges to come to a sliding stop.",
	ability_category: 'Intermediate',
	ability_level: 5
	})
	Skill.create!({
	id: 21,
	sport_id: 1,
	name: "Side Slipping",
	description: "With skis perpendicular to the hill, can control edge angle in order to slide slowly or quickly downhill.",
	ability_category: 'Intermediate',
	ability_level: 5
	})

# create skiing skills - level 6
	Skill.create!({
	id: 22,
	sport_id: 1,
	name: "Parallel Turns",
	description: "Can initiate, control the shape, and finishe turns in both directions while keeping skis fully parallel throughout the turn.",
	ability_category: 'Intermediate',
	ability_level: 5
	})
	Skill.create!({
	id: 23,
	sport_id: 1,
	name: "Skidded & Carved Turns",
	description: "Can increase/decrease edge angle and leg rotation to vary between skidded turns and carving turns.",
	ability_category: 'Intermediate',
	ability_level: 5
	})
	Skill.create!({
	id: 24,
	sport_id: 1,
	name: "Navigate variable terrain",
	description: "Can navigate tradeoffs btw turn speed and shape to handle diverse snow conditions and variable terrain.",
	ability_category: 'Intermediate',
	ability_level: 5
	})
	Skill.create!({
	id: 25,
	sport_id: 1,
	name: "Intro to moguls",
	description: "Capable of safely getting down moguls, steep blacks, or other variable terrain.",
	ability_category: 'Intermediate',
	ability_level: 5
	})

end

end
