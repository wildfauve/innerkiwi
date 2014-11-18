json.kind "kiwis"
json.kiwis @kiwis do |kiwi|
  json.name kiwi.name
  json._links do
    json.self do
      json.href api_v1_kiwi_url(kiwi)
    end
  end
end