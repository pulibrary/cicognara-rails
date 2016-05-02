require 'cicognara/tei_process'

namespace :tei do
  desc 'generate solr documents from TEI documents.'
  task :generate do
    Cicognara::TEI.thunk
  end
end
