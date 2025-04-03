-- module under ObbyGenerator

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PiecesFolder = ReplicatedStorage:WaitForChild("Pieces")

local ObbyImporter = {}

function ObbyImporter.ImportFromJson(json_string)
	local success, data = pcall(function()
		return HttpService:JSONDecode(json_string)
	end)

	if not success then
		warn("Invalid JSON")
		return
	end

	local last_piece = nil

	for i, piece in ipairs(data.pieces or {}) do
		local template = PiecesFolder:FindFirstChild(piece.id)
		if not template then
			warn("Missing piece:", piece.id)
			continue
		end

		local clone = template:Clone()

		-- Auto-set PrimaryPart to StartPart if needed
		if not clone.PrimaryPart then
			local start = clone:FindFirstChild("StartPart")
			if start and start:IsA("BasePart") then
				clone.PrimaryPart = start
			else
				warn("Missing StartPart or PrimaryPart for:", clone.Name)
				continue
			end
		end

		local end_part = clone:FindFirstChild("EndPart")
		if not end_part then
			warn("Missing EndPart for:", clone.Name)
			continue
		end

		clone.Parent = workspace

		if last_piece then
			local last_end = last_piece:FindFirstChild("EndPart")
			if last_end then
				clone:SetPrimaryPartCFrame(last_end.CFrame)
			else
				warn("Previous piece missing EndPart")
			end
		end

		last_piece = clone

		if i >= #data.pieces then
			local stop = game.ReplicatedStorage.StopPlatform:Clone()
			stop.Parent = game.Workspace

			if not stop.PrimaryPart then
				local start = clone:FindFirstChild("StartPart")
				if start and start:IsA("BasePart") then
					stop.PrimaryPart = start
				else
					warn("Missing StartPart or PrimaryPart for:", clone.Name)
					continue
				end
			end

			stop:SetPrimaryPartCFrame(last_piece.EndPart.CFrame)
		end
	end
end

return ObbyImporter
