# Debug animal statuses
puts "Animal statuses:"
Animal.all.each do |animal|
  puts "  #{animal.id} - #{animal.name}: status=#{animal.status}, has_adoptions=#{animal.adoptions.any?}"
end
