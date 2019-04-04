task :refresh, [:org] => :environment do |_t, args|
  raise 'organisation expected as an argument' if args[:org].nil?
  Github.refresh(args[:org])
end
