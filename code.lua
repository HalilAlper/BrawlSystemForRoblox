	--Initialize brawl from start to end
	local function InitializeBrawl()
		ResetTables() --Make sure we have clear tables
		SetPhase(2) --Popups
		InitializePopups()--Execute popups and wait for popups
		--Make sure there are enough players
		if #Participants > 1 then --If there are
			SetPhase(4) --Start the rules
			InitializeRules()
			--Remotes.StartRules:FireAllClients(Timers[4]) --Start rules timer for clients
			if #Participants < 2 then --If so not enough left during rules phase
				SetPhase(3) --Set phase to not enough players
				wait(Timers[3])
				CancelBrawl()
				return
			end
			if not PickNext(1) then warn("Error at PickNext") end --Pick two players to put in ring
			PutNext() --Start the fight, teleport them into the ring
			
			--Next phase - 5
			while #Participants > 0 do
				SetPhase(5) --There are participants to put into fight
				if not PickNext(1) then error("Error at PickNext") break end --Pick next fighter, print if not
				wait(Timers[5])
				PutNext()
			end
			
			--Next phase - 6
			SetPhase(6) --No more participants, waiting for the game end
			while #Survivors > 1 and IGV:GetAttribute("Timer") > 0 do
				wait(.5)
			end
			
			--Next phase - 7
			SetPhase(7)

			local ToSend = {} --Make sure everyone gets required results viewed
			for i, v in ipairs(Participants) do
				ToSend[v[1]] = true
			end
			for i, v in ipairs(Survivors) do
				ToSend[v[1]] = true
			end
			for i, v in ipairs(Dead) do
				ToSend[v[1]] = true
			end
			for i, v in ipairs(Spectators) do
				ToSend[v[1]] = true
			end
			
			InitializeResults(ToSend) --Initialize and calculate all results. Show the results too.
			for i, v in ipairs(Survivors) do --Make all spectators' stats reset. Dead ones are reseted already in other functions.
				local Player = game.Players:FindFirstChild(v[1])
				if Player then
					if Player.Character then
						Player.Character.HumanoidRootPart.CFrame = game.Workspace.TeleportTo.Grassland.CFrame
						Player.Character.Humanoid.Health = Player.Character.Humanoid.MaxHealth	--Max the health
						Player.hiddenStats.IsBrawling.Value = false 							--Player is not brawling
						Player.hiddenStats.IsWaiting.Value = false								--Player is not waiting in participant area
						Player.hiddenStats.IsSpectating.Value = false							--Player is not spectating the brawl
						Remotes.BrawlBackpack:FireClient(Player, false)		 					--Turn exercises back on
						Remotes.Spectate:FireClient(Player, -1, nil, "No Active Brawl", false) 	--No active brawl message
					end
				end
			end
			wait(Timers[8])
			
			Remotes.ShowResults:FireAllClients()
		else
			SetPhase(3) --Set phase to not enough players
			wait(Timers[3])
			CancelBrawl()
			return
		end
	end