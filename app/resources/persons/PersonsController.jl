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
    SearchLight.save(person)
    # json(Dict(:header=>"/api/v1/persons/[person.id]"), status = 201)
  else
    json(:message=>"Error")
  end
end

#delete person by ID
function deletePersonID()
  foundPersons = map(SearchLight.find(Person, SearchLight.SQLWhereExpression("id = $(payload(:id))", 0))) do person
    Dict(key=>if key != :id getfield(person, key) else getfield(getfield(person, key), :value) end for key ∈ fieldnames(Person)) 
    end

    if isempty(foundPersons)
      json(Dict(:message=>"Person not found"), status = 404)
    else
      map(SearchLight.find(Person, SearchLight.SQLWhereExpression("id = $(payload(:id))", 0))) do person
         SearchLight.delete(person)
      end
    end
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


function update()
  payload = jsonpayload()

  foundPersons = map(SearchLight.find(Person, SearchLight.SQLWhereExpression("id = $(payload["id"])", 0))) do person
    Dict(key=>if key != :id getfield(person, key) else getfield(getfield(person, key), :value) end for key ∈ fieldnames(Person)) 
    end

    if isempty(foundPersons)
      json(Dict(:message=>"Person not found"), status = 404)
    else
      foundPers = map(SearchLight.find(Person, SearchLight.SQLWhereExpression("id = $(payload["id"])", 0))) do person
        if all(keys(payload) .∈ (["name", "work", "age", "address", "id"],)) &&
          length(payload) == 5
            person.name = payload["name"]
            person.work = payload["work"]
            person.age = payload["age"]
            person.address = payload["address"]
            SearchLight.save(person)
            
          else
            json(:message=>"Error")
          end

          Dict(key=>if key != :id getfield(person, key) else getfield(getfield(person, key), :value) end for key ∈ fieldnames(Person))
        end
     
        json(foundPers[1])

    end
    
end

end
