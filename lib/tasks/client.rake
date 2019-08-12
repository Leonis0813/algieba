namespace :client do
  desc 'Create application'
  task create: :environment do
    id = Client.generate_application_id
    key = Client.generate_application_key
    begin
      Client.create!(application_id: id, application_key: key)
      puts "Application id: #{id}"
      puts "Application key: #{key}"
    rescue StandardError => e
      p e
    end
  end

  desc 'Destroy application'
  task :destroy, [:application_id] => :environment do |_, args|
    Client.find_by(application_id: args.application_id).destroy
    puts "Destroy #{args.application_id}"
  rescue StandardError => e
    p e
  end
end
