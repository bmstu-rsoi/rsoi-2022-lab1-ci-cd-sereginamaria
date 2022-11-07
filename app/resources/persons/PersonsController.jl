module PersonsController
using Lab1.Persons

using SearchLight
using Genie.Renderer.Json, Genie.Requests, Genie.Responses

#all persons
function index()
  foundPersons = map(SearchLight.all(Person)) do person
    Dict(key=>if key != :id getfield(person, key) else getfield(getfield(person, key), :value) end for key ∈ fieldnames(Person))
  end

  json(foundPersons)
end

#person by ID
function personID()
  foundPersons = map(SearchLight.find(Person, SearchLight.SQLWhereExpression("id = $(payload(:id))", 0))) do person
    Dict(key=>if key != :id getfield(person, key) else getfield(getfield(person, key), :value) end for key ∈ fieldnames(Person)) 
    end

    if isempty(foundPersons)
      json(Dict(:message=>"Person not found"), status = 404)
    else
      json(foundPersons[1])
    end
  
end

#add person
function add()
  payload = jsonpayload()

  if all(keys(payload) .∈ (["name", "work", "age", "address"],)) &&
  length(payload) == 4
    person = Person(name=payload["name"], 
                  work=payload["work"],
                  age=payload["age"],
                  address=payload["address"])
    person = SearchLight.save!(person)
    Genie.Responses.setheaders(Dict("Location"=>"/api/v1/persons/$(person.id)"))
    setstatus(201)
  else
    setstatus(400)
  end
end

#delete person by ID
function deletePersonID()
  foundPersons = SearchLight.find(Person, SearchLight.SQLWhereExpression("id = $(payload(:id))", 0))

    if !isempty(foundPersons)
      SearchLight.delete(foundPersons[1])
    end
    setstatus(204)
end

#update person by ID
# function update()
#   payload = jsonpayload()

#   foundPersons = map(SearchLight.find(Person, SearchLight.SQLWhereExpression("id = $(payload["id"])", 0))) do person
#     if all(keys(payload) .∈ (["name", "work", "age", "address", "id"],)) &&
#       length(payload) == 5
#         person.name = payload["name"]
#         person.work = payload["work"]
#         person.age = payload["age"]
#         person.address = payload["address"]
#         SearchLight.save(person)
        
#       else
#         json(:message=>"Error")
#       end

#       Dict(key=>if key != :id getfield(person, key) else getfield(getfield(person, key), :value) end for key ∈ fieldnames(Person)) 
#     end

#     if isempty(foundPersons)
#       json(Dict(:message=>"Person not found"), status = 404)
#     else
#       json(foundPersons[1])
#     end  

# end

function update() #Done
  jsonpayloadData = jsonpayload()

  additionalProps = Dict()
  for key in keys(jsonpayloadData)
    if key != "name" &&
       key != "work" &&
       key != "age" &&
       key != "address"

       additionalProps[key] = jsonpayloadData[key]
    end
  end
  if !isempty(additionalProps)
    errorMsg = Dict(:errors=>additionalProps, :message=>"Invalid data")
    return json(errorMsg, status=400)
  end

  foundPersons = SearchLight.find(Person, SearchLight.SQLWhereExpression("id = $(payload(:id))", 0))
    
  if isempty(foundPersons)
    return json(Dict(:message=>"Person not found"), status = 404)
  end

  if "name" in keys(jsonpayloadData)
    foundPersons[1].name = jsonpayloadData["name"]
  end
  if "work" in keys(jsonpayloadData)
    foundPersons[1].work = jsonpayloadData["work"]
  end
  if "age" in keys(jsonpayloadData)
    foundPersons[1].age = jsonpayloadData["age"]
  end
  if "address" in keys(jsonpayloadData)
    foundPersons[1].address = jsonpayloadData["address"]
  end

  foundPersons[1] = save!(foundPersons[1])

  #Dict(key=>if key != :id getfield(person, key) else getfield(getfield(person, key), :value) end for key ∈ fieldnames(Person)) 

  updatedPerson = map(SearchLight.find(Person, SearchLight.SQLWhereExpression("id = $(payload(:id))", 0))) do person
    Dict(key=>if key != :id getfield(person, key) else getfield(getfield(person, key), :value) end for key ∈ fieldnames(Person)) 
  end
  json(updatedPerson[1])
end

end
