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