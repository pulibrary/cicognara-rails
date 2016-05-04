json.array!(@books) do |books|
  json.extract! books, :id
  json.url book_url(book, format: :json)
end
