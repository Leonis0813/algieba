namespace :db do
  desc 'Dump database'
  task :dump => :environment do
    db_config = Rails.configuration.database_configuration
    user = db_config[Rails.env]['username']
    database = db_config[Rails.env]['database']
    sh "mysqldump -u #{user} #{database} > #{Rails.root}/db/dump.sql"
  end
end
