desc "update high schools csv"
task :update_high_schools_csv => :environment do
	HighSchool.to_csv
end
