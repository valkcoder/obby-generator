-- module under ObbyGenerator

local HttpService = game:GetService("HttpService")

local TrainingData = {}

local good_starts = {}
local good_ends = {}
local good_combinations = {}

function TrainingData.AddGoodStart(id)
	if not table.find(good_starts, id) then
		table.insert(good_starts, id)
	end
end

function TrainingData.AddGoodEnd(id)
	if not table.find(good_ends, id) then
		table.insert(good_ends, id)
	end
end

function TrainingData.AddGoodCombination(a, b)
	for _, pair in ipairs(good_combinations) do
		if pair[1] == a and pair[2] == b then
			return
		end
	end
	table.insert(good_combinations, { a, b })
end

function TrainingData.ExportAsJson()
	local data = {
		good_starts = good_starts,
		good_ends = good_ends,
		good_combinations = good_combinations,
	}
	return HttpService:JSONEncode(data)
end

function TrainingData.SetData(data)
	good_starts = data.good_starts or {}
	good_ends = data.good_ends or {}
	good_combinations = data.good_combinations or {}
end

return TrainingData
