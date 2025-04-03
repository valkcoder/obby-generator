# valk's obby generator

a (semi-)smart ai-driven obby sequence generator for roblox, built with a two-part system:

- **roblox studio plugin**: train, test, and export obby data using real parts
- **rust app**: visualize, edit, and generate obbies based on training data

---

## how it works

### 1. in roblox studio

- create obby parts in `ReplicatedStorage > Pieces`
- each piece must have:
  - `StartPart` → where it begins
  - `EndPart` → where the next piece connects
- use the roblox plugin ui to:
  - mark pieces as good starts / ends
  - mark transitions (a → b) as good combos
  - Export `training_data.json` (as a JSON string)

---

### 2. in the rust app (`obby_generator`)

- paste the exported training data JSON
- choose the desired obby length
- click **Generate Obby**
- see a table preview of the generated sequence
- modify individual piece ids directly
- click **Copy Generated Obby JSON**
- paste the result back into roblox to build it

---

## requirements
- `ReplicatedStorage > Pieces` (folder)
- `ReplicatedStorage > StopPlatform` (model)
- plugin (see plugin section)

---

## how to set up the plugin
- go into roblox studio (duh)
- make a new script called whatever you want (it doesnt matter), lets call it script_name here
- paste the contents of `roblox_plugin/ObbyGenerator.lua` into it
- make a new modulescript in script_name called ObbyImporter
- paste the contents of `roblox_plugin/ObbyImporter.lua` into it
- make a new modulescript in script_name called TrainingData
- paste the contents of `roblox_plugin/TrainingData.lua` into it
- publish script_name to roblox (save to local file wont work)

---

## example training data
```json
{
  "good_starts": ["StartPlatform"],
  "good_ends": ["EndFlag"],
  "good_combinations": [
    ["StartPlatform", "JumpGap"],
    ["JumpGap", "WallTurn"],
    ["WallTurn", "EndFlag"]
  ]
}
```

## example generated obby json
```json
{
  "pieces": [
    {
      "id": "LongPart"
    },
    {
      "id": "WallPart"
    },
    {
      "id": "LongPart"
    },
    {
      "id": "WallPart"
    },
    {
      "id": "LongPart"
    }
  ]
}
```