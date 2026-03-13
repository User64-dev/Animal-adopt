# This file creates initial data for the Animals Adopt application

# Create an admin user
admin = User.create!(
  username: "admin",
  email: "admin@example.com",
  password: "password123",
  password_confirmation: "password123",
  admin: true
)

puts "Admin user created: #{admin.username}"

# Create a regular user
user = User.create!(
  username: "michele",
  email: "michele@example.com",
  password: "password123",
  password_confirmation: "password123",
  admin: false
)

puts "Regular user created: #{user.username}"

# Create some animals
animals = [
  { name: "Max", animal_type: "Dog", age: 3, race: "Golden Retriever" },
  { name: "Luna", animal_type: "Cat", age: 2, race: "Siamese" },
  { name: "Buddy", animal_type: "Dog", age: 5, race: "Labrador" },
  { name: "Daisy", animal_type: "Dog", age: 1, race: "Beagle" },
  { name: "Bella", animal_type: "Cat", age: 4, race: "Persian" }
]

animals.each do |animal_attrs|
  animal = Animal.create!(animal_attrs)
  puts "Created animal: #{animal.name}, #{animal.animal_type}"
end

puts "Database seeded successfully!"
