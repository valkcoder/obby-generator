-- normal server script

local plugin = plugin
local HttpService = game:GetService("HttpService")
local Selection = game:GetService("Selection")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ObbyImporter = require(script:WaitForChild("ObbyImporter"))
local TrainingData = require(script:WaitForChild("TrainingData"))

local toolbar = plugin:CreateToolbar("Obby Tools")
local button = toolbar:CreateButton("Obby UI", "Open Obby Generator", "")

local widget_info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Left, true, false, 300, 400)
local widget = plugin:CreateDockWidgetPluginGui("ObbyTrainer", widget_info)
widget.Title = "Obby Generator"
widget.Enabled = false

-- UI Layout
local container = Instance.new("Frame", widget)
container.Size = UDim2.new(1, 0, 1, 0)

-- Tab toggle
local tab_button = Instance.new("TextButton", container)
tab_button.Size = UDim2.new(1, 0, 0, 30)
tab_button.Text = "Switch Tab"

-- Import Tab
local import_tab = Instance.new("TextBox", container)
import_tab.Position = UDim2.new(0, 0, 0, 30)
import_tab.Size = UDim2.new(1, 0, 1, -30)
import_tab.TextWrapped = true
import_tab.TextYAlignment = Enum.TextYAlignment.Top
import_tab.ClearTextOnFocus = false
import_tab.MultiLine = true
import_tab.PlaceholderText = "Paste obby JSON here"

-- Create Tab
local create_tab = Instance.new("Frame", container)
create_tab.Position = import_tab.Position
create_tab.Size = import_tab.Size
create_tab.Visible = false

local id_box = Instance.new("TextBox", create_tab)
id_box.PlaceholderText = "Piece ID"
id_box.Position = UDim2.new(0, 0, 0, 0)
id_box.Size = UDim2.new(1, 0, 0, 30)

local load_button = Instance.new("TextButton", container)
load_button.Text = "Load Obby from JSON"
load_button.Position = UDim2.new(0, 0, 0, 65)
load_button.Size = UDim2.new(1, 0, 0, 30)
import_tab.Position = UDim2.new(0, 0, 0, 100)
import_tab.Size = UDim2.new(1, 0, 1, -100)
load_button.Visible = true
import_tab.Visible = true

local register_button = Instance.new("TextButton", create_tab)
register_button.Text = "Register Selected Piece"
register_button.Position = UDim2.new(0, 0, 0, 35)
register_button.Size = UDim2.new(1, 0, 0, 30)

local mark_start_button = Instance.new("TextButton", create_tab)
mark_start_button.Text = "Mark as Good Start"
mark_start_button.Position = UDim2.new(0, 0, 0, 75)
mark_start_button.Size = UDim2.new(1, 0, 0, 30)

local mark_end_button = Instance.new("TextButton", create_tab)
mark_end_button.Text = "Mark as Good End"
mark_end_button.Position = UDim2.new(0, 0, 0, 110)
mark_end_button.Size = UDim2.new(1, 0, 0, 30)

local mark_combo_button = Instance.new("TextButton", create_tab)
mark_combo_button.Text = "Mark Combo A -> B"
mark_combo_button.Position = UDim2.new(0, 0, 0, 145)
mark_combo_button.Size = UDim2.new(1, 0, 0, 30)

local export_button = Instance.new("TextButton", create_tab)
export_button.Text = "Export Training Data"
export_button.Position = UDim2.new(0, 0, 0, 185)
export_button.Size = UDim2.new(1, 0, 0, 30)

local export_box = Instance.new("TextBox", create_tab)
export_box.Position = UDim2.new(0, 0, 0, 220)
export_box.Size = UDim2.new(1, 0, 1, -220)
export_box.TextWrapped = true
export_box.TextYAlignment = Enum.TextYAlignment.Top
export_box.ClearTextOnFocus = false
export_box.MultiLine = true
export_box.Text = ""

local import_training_box = Instance.new("TextBox", create_tab)
import_training_box.Position = UDim2.new(0, 0, 1, -100)
import_training_box.Size = UDim2.new(1, 0, 0, 70)
import_training_box.TextWrapped = true
import_training_box.TextYAlignment = Enum.TextYAlignment.Top
import_training_box.ClearTextOnFocus = false
import_training_box.MultiLine = true
import_training_box.PlaceholderText = "Paste training data JSON here"
import_training_box.Text = ""

local import_training_button = Instance.new("TextButton", create_tab)
import_training_button.Text = "Load Training Data"
import_training_button.Position = UDim2.new(0, 0, 1, -30)
import_training_button.Size = UDim2.new(1, 0, 0, 30)

-- Tab switching
local showing_import = true
tab_button.MouseButton1Click:Connect(function()
	showing_import = not showing_import
	import_tab.Visible = showing_import
	create_tab.Visible = not showing_import
	load_button.Visible = showing_import
end)

-- Register piece
register_button.MouseButton1Click:Connect(function()
	local model = Selection:Get()[1]
	if not model or not model:IsA("Model") then return end
	if not model:FindFirstChild("EndPart") or (not model:FindFirstChild("StartPart") and not model.PrimaryPart) then
		warn("Model must have StartPart (or a primarypart that serves as StartPart) and EndPart")
		return
	end

	local id = id_box.Text
	if id == "" then return end

	local folder = ReplicatedStorage:FindFirstChild("Pieces")
	if not folder then
		folder = Instance.new("Folder", ReplicatedStorage)
		folder.Name = "Pieces"
	end

	local clone = model:Clone()
	clone.Name = id
	clone.Parent = folder
end)

-- Training actions
mark_start_button.MouseButton1Click:Connect(function()
	local model = Selection:Get()[1]
	if model then
		TrainingData.AddGoodStart(model.Name)
	end
end)

mark_end_button.MouseButton1Click:Connect(function()
	local model = Selection:Get()[1]
	if model then
		TrainingData.AddGoodEnd(model.Name)
	end
end)

mark_combo_button.MouseButton1Click:Connect(function()
	local selected = Selection:Get()
	if #selected == 2 then
		TrainingData.AddGoodCombination(selected[1].Name, selected[2].Name)
	end
end)

export_button.MouseButton1Click:Connect(function()
	export_box.Text = TrainingData.ExportAsJson()
end)

-- Obby importer
load_button.MouseButton1Click:Connect(function()
	local success, err = pcall(function()
		ObbyImporter.ImportFromJson(import_tab.Text)
	end)
	if not success then
		warn("Failed to load obby: ", err)
	end
end)

import_training_button.MouseButton1Click:Connect(function()
	local raw = import_training_box.Text
	local success, parsed = pcall(function()
		return HttpService:JSONDecode(raw)
	end)

	if not success or typeof(parsed) ~= "table" then
		warn("Invalid training JSON")
		return
	end

	if parsed.good_starts and parsed.good_ends and parsed.good_combinations then
		-- Replace memory in TrainingData module
		TrainingData.SetData(parsed)
		print("✅ Training data loaded!")
	else
		warn("Training JSON missing required keys")
	end
end)

-- Toggle panel
button.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)
