puts "Seeding subscription plans..."
plans = [
  { name: "Basic", bucket_size: 10, price: 199, description: "10L bucket - ideal for small households" },
  { name: "Standard", bucket_size: 25, price: 349, description: "25L bucket - ideal for medium households" },
  { name: "Premium", bucket_size: 50, price: 599, description: "50L bucket - ideal for large households" }
]

plans.each do |plan|
  SubscriptionPlan.find_or_create_by!(name: plan[:name]) do |p|
    p.bucket_size = plan[:bucket_size]
    p.price = plan[:price]
    p.description = plan[:description]
    p.active = true
  end
end

puts "Seeding admin user..."
admin = User.find_or_create_by!(email: "admin@cleancircle.in") do |u|
  u.name = "Admin User"
  u.password = "password123"
  u.role = :admin
end

puts "Seeding agent user..."
agent = User.find_or_create_by!(email: "agent@cleancircle.in") do |u|
  u.name = "Ravi Kumar"
  u.password = "password123"
  u.role = :agent
end

puts "Seeding demo customer..."
customer = User.find_or_create_by!(email: "customer@cleancircle.in") do |u|
  u.name = "Priya Sharma"
  u.password = "password123"
  u.role = :customer
  u.family_size = 4
  u.address = "B-204, Green Valley Apartments, Sector 62, Noida"
  u.phone = "9876543210"
end

puts "Seeding route..."
route = Route.find_or_create_by!(name: "Sector 62 Morning") do |r|
  r.area = "Sector 62, Noida"
  r.agent = agent
end

puts "Seeding household..."
household = Household.find_or_create_by!(user: customer) do |h|
  h.address = customer.address
  h.building_name = "Green Valley Apartments"
  h.unit_number = "B-204"
  h.route = route
end

puts "Adding wallet balance..."
customer.wallet.credit!(500, description: "Welcome bonus")

puts "Creating subscription..."
Subscription.find_or_create_by!(user: customer, subscription_plan: SubscriptionPlan.find_by(name: "Standard")) do |s|
  s.status = :active
  s.starts_on = Date.current
  s.ends_on = Date.current + 30.days
end

puts "Seeding badges..."
Badge.seed_defaults!

puts "Done!"
