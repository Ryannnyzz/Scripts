--// ===============================
--// YANZ GUI FRAMEWORK (GUI ONLY)
--// ===============================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local yanz = {}
yanz.Tabs = {}
yanz.InfoData = {}

--// GUI ROOT
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "yanz_gui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

--// OPEN BUTTON
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0,120,0,30)
OpenBtn.Position = UDim2.new(0.5,-60,0,10)
OpenBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
OpenBtn.TextColor3 = Color3.fromRGB(255,255,255)
OpenBtn.Text = "YANZ"
OpenBtn.Parent = ScreenGui

--// MAIN FRAME
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,500,0,320)
Main.Position = UDim2.new(0.5,-250,0.5,-160)
Main.BackgroundColor3 = Color3.fromRGB(15,15,15)
Main.Visible = false
Main.Parent = ScreenGui

--// DRAG SYSTEM
local dragging, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	Main.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

Main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = Main.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		update(input)
	end
end)

--// OPEN / CLOSE
OpenBtn.MouseButton1Click:Connect(function()
	Main.Visible = not Main.Visible
end)

--// TAB CONTAINERS
local TabButtons = Instance.new("Frame", Main)
TabButtons.Size = UDim2.new(0,120,1,0)
TabButtons.BackgroundColor3 = Color3.fromRGB(20,20,20)

local Content = Instance.new("Frame", Main)
Content.Position = UDim2.new(0,120,0,0)
Content.Size = UDim2.new(1,-120,1,0)
Content.BackgroundTransparency = 1

--// CREATE TAB
function yanz:AddTab(name)
	local Tab = {}

	local Btn = Instance.new("TextButton", TabButtons)
	Btn.Size = UDim2.new(1,0,0,35)
	Btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
	Btn.TextColor3 = Color3.fromRGB(255,255,255)
	Btn.Text = name

	local Page = Instance.new("Frame", Content)
	Page.Size = UDim2.new(1,0,1,0)
	Page.Visible = false
	Page.BackgroundTransparency = 1

	Btn.MouseButton1Click:Connect(function()
		for _,t in pairs(yanz.Tabs) do
			t.Page.Visible = false
		end
		Page.Visible = true
	end)

	Tab.Page = Page
	yanz.Tabs[name] = Tab

	return Tab
end

--// LABEL
function yanz:AddLabel(tab, text)
	local L = Instance.new("TextLabel", tab.Page)
	L.Size = UDim2.new(1,-10,0,25)
	L.Position = UDim2.new(0,5,0,0)
	L.BackgroundTransparency = 1
	L.TextColor3 = Color3.fromRGB(255,255,255)
	L.Text = text
end

--// BUTTON
function yanz:AddButton(tab, text, callback)
	local B = Instance.new("TextButton", tab.Page)
	B.Size = UDim2.new(1,-10,0,30)
	B.Position = UDim2.new(0,5,0,0)
	B.BackgroundColor3 = Color3.fromRGB(40,40,40)
	B.TextColor3 = Color3.fromRGB(255,255,255)
	B.Text = text

	B.MouseButton1Click:Connect(function()
		if callback then callback() end
	end)
end

--// TOGGLE
function yanz:AddToggle(tab, text, callback)
	local state = false

	local T = Instance.new("TextButton", tab.Page)
	T.Size = UDim2.new(1,-10,0,30)
	T.Position = UDim2.new(0,5,0,0)
	T.BackgroundColor3 = Color3.fromRGB(40,40,40)
	T.TextColor3 = Color3.fromRGB(255,255,255)
	T.Text = text .. " : OFF"

	T.MouseButton1Click:Connect(function()
		state = not state
		T.Text = text .. " : " .. (state and "ON" or "OFF")
		if callback then callback(state) end
	end)
end

--// SLIDER (simple click cycle)
function yanz:AddSlider(tab, text, min, max, callback)
	local value = min

	local S = Instance.new("TextButton", tab.Page)
	S.Size = UDim2.new(1,-10,0,30)
	S.Position = UDim2.new(0,5,0,0)
	S.BackgroundColor3 = Color3.fromRGB(40,40,40)
	S.TextColor3 = Color3.fromRGB(255,255,255)
	S.Text = text .. " : " .. value

	S.MouseButton1Click:Connect(function()
		value += 1
		if value > max then value = min end
		S.Text = text .. " : " .. value
		if callback then callback(value) end
	end)
end

--// DROPDOWN (cycle)
function yanz:AddDropdown(tab, text, list, callback)
	local index = 1

	local D = Instance.new("TextButton", tab.Page)
	D.Size = UDim2.new(1,-10,0,30)
	D.Position = UDim2.new(0,5,0,0)
	D.BackgroundColor3 = Color3.fromRGB(40,40,40)
	D.TextColor3 = Color3.fromRGB(255,255,255)
	D.Text = text .. " : " .. list[index]

	D.MouseButton1Click:Connect(function()
		index += 1
		if index > #list then index = 1 end
		D.Text = text .. " : " .. list[index]
		if callback then callback(list[index]) end
	end)
end

--// SET INFO DATA (for external script)
function yanz:SetInfo(tbl)
	yanz.InfoData = tbl
end

return yanz
