namespace :finery do
  desc "run checks"
  task :run_checks, [:schedule] => :environment do |_, args|
    Finery.run_checks(schedule: args[:schedule] || ENV["SCHEDULE"])
  end

  desc "send failing checks"
  task send_failing_checks: :environment do
    Finery.send_failing_checks
  end

  desc "archive queries"
  task archive_queries: :environment do
    begin
      Finery.archive_queries
    rescue => e
      abort e.message
    end
  end
end
