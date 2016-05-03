json.array!(@contributing_libraries) do |contributing_library|
  json.extract! contributing_library, :id
  json.url contributing_library_url(contributing_library, format: :json)
end
