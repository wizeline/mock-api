# Mock API
Static json object to simulate api rest responses

# Uses
Access the json objects directly with the github raw file format `https://raw.githubusercontent.com/`

e.g [GET {baseurl}/pokedex/v1/pokemons/{pokemon.id}.json](https://raw.githubusercontent.com/wizeline/mock-api/main/pokedex/v1/pokemons/090E2E23-2E8C-4130-AF41-25A65321E1CE.json)

# Scripts
A `generate.swift` file is provided to auto-generate the schema file and entry points from a single repository json file
