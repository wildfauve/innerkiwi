json.set! "/customers" do
  json.get do
    json.set! :consumes,  ["application/json"]
    json.description ""
    json.operationId "getCustomers"
    json.set! :produces,  ["application/json"]      
    json.responses do
      json.set! "200" do
        json.description "Successful"
        json.schema do
          json.set! "$ref", '#/definitions/customers'
        end
      end
    end
    json.summary "Get All Customers"
    json.set! :tags, [ "customer" ]
  end
end