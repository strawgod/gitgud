local Players = game:GetService"Players"
local RunService = game:GetService"RunService"
local UserInputService = game:GetService"UserInputService"
local LocalPlayer = Players.LocalPlayer

local holding = false
local outlines = {}

local Camera = workspace.CurrentCamera

local previousbehavior = Enum.MouseBehavior.Default

local onPlayerAdded = function(player)
	if player == Players.LocalPlayer then
		return
	end

	local onCharacterAdded = function(character)
		local outline = Instance.new"Highlight"
		outline.OutlineColor = player.TeamColor.Color
		outline.FillColor = Color3.new(1 - player.TeamColor.Color.R, 1 - player.TeamColor.Color.G, 1 - player.TeamColor.Color.B)
		outline.Adornee = character
		outline.Parent = character

		outlines[player] = outline
	end

	if player.Character then
		onCharacterAdded(player.Character)
	end

	player.CharacterAdded:Connect(onCharacterAdded)
end

_G.outlines = {
	create = function()
		for index, player in next, Players:GetPlayers() do
			onPlayerAdded(player)
		end

		Players.PlayerAdded:Connect(onPlayerAdded)
	end,
	clear = function()
		for player, outline in next, outlines do
			outline:remove()
			outline[player] = nil
		end
	end,
}

_G.aimbot = {
	teamCheck = false,
	inputType = Enum.UserInputType.MouseButton2
}

local function getTarget()
	local max = 0.7
	local target = nil

	for index, player in next, Players:GetPlayers() do
		if player ~= LocalPlayer then --if self
			if _G.aimbot.teamCheck == true and player.Neutral == false and player.Team == LocalPlayer.Team then --if teamcheck on and same team
				--warn"teamcheck on, teammate"
				return
			end

			local character = player.Character
			if character then --if their character doesn't exist
				local rootPart = character:FindFirstChild"HumanoidRootPart"
				if rootPart then --if lacking rootpart
					local humanoid = character:FindFirstChild"Humanoid"
					if humanoid then --if lacking humanoid
						if humanoid.Health > 0 then
							local dot = (rootPart.Position - Camera.CFrame.Position).Unit:Dot(Camera.CFrame.LookVector)
							if dot > max then
								max = dot
								target = character
							end
						end
					end
				end
			end
		end
	end

	return target
end

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == _G.aimbot.inputType then
		holding = true
		--previousbehavior = UserInputService.MouseBehavior
		--UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == _G.aimbot.inputType then
		holding = false
		--UserInputService.MouseBehavior = previousbehavior
	end
end)

_G.aimbot.enable = function()
	RunService:BindToRenderStep("hax", Enum.RenderPriority.First.Value, function(dt)
		if holding then
			local target = getTarget()
			if target then
				Camera.CFrame = CFrame.new(Camera.CFrame.Position, (target.Head or target:FindFirstChildWhichIsA"BasePart").Position)
			end
		end
	end)
end

_G.aimbot.disable = function()
	RunService:UnbindFromRenderStep"hax"
end

_G.aimbot.enable()
_G.outlines.create()
