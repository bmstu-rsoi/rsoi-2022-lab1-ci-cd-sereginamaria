using Genie.Router

using Lab1.PersonsController
using JSON

# API documentation route
using SwagUI
api_doc = JSON.parsefile("APIdocumentation.json")
route("/api/v1") do
  SwagUI.render_swagger(api_doc)
end

route("/") do
  # serve_static_file("welcome.html")
  json(["Foo", "Bar", "Three"])
end


route("/api/v1/persons/:id", PersonsController.update, method=PATCH) 

route("/api/v1/persons", PersonsController.add, method=POST) 

route("/api/v1/persons/:id", PersonsController.deletePersonID, method=DELETE)

route("/api/v1/persons/:id", PersonsController.personID, method=GET) 

route("/api/v1/persons", PersonsController.index, method=GET) 