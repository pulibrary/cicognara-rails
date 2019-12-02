# Combines jsonld context hashes from all the json files in the directory. Used
# to create a master list for mapping version metadata to show fields. Left here
# in case the data changes over time and we want to look at these again. More
# details in https://github.com/pulibrary/cicognara-rails/issues/334

# To run this script you have to unzip all the resource dumps that get
# downloaded during a getty load.

# It's written to be invoked from Rails root like
# `ruby scripts/context_combiner.rb`

require 'JSON'
require 'pry'

combined_context = {}

all_files = Dir.glob('./tmp/resources/*.json')

all_files.each do |file|
  json = JSON.parse(File.open(file).read)
  combined_context.merge!(json['@context'])
end

puts combined_context.keys
pp combined_context
puts "count: #{combined_context.keys.count}" # 61 at last run
