json.basePath "/api/v1"
json.host "localhost:3000"
json.info do 
  json.contact do
    json.name "wild.fauve@gmail.com"
  end
  json.description "This is a sample server Petstore server.  You can find out more about Swagger at <a href=\"http://swagger.wordnik.com\">http://swagger.wordnik.com</a> or on irc.freenode.net, #swagger.  For this sample, you can use the api key \"special-key\" to test the authorization filters"
  json.license do 
    json.name "Apache 2.0"
    json.url "http://www.apache.org/licenses/LICENSE-2.0.html"
  end
  json.termsOfService "http://helloreverb.com/terms/"
  json.title "TimeMachine API Docs"
  json.version "1.0.0"
end
json.set! :schemes ["http"]
json.swagger "2.0"
json.definitions do
end
json.paths do 
  json.partial! 'customer'
end
json.definitions do
  json.customers do
    json.properties do
      json.kind do
        json.type "string"
        json.description "The message type"
      end
      json.status do 
        json.type "string"
      end
      json.customers do
        json. type "array"
        json.items do
          json.type "object"
          json.properties do
            json.name do
              json.type "string"
              json.description "Name of the Customer"
            end
          end
        end
      end
    end
  end
end
          
