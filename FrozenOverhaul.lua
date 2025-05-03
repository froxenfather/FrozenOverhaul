--[[
------------------------------Basic Table of Contents------------------------------
Line 17, Atlas ---------------- Explains the parts of the atlas.
Line 29, Joker 2 -------------- Explains the basic structure of a joker
Line 88, Runner 2 ------------- Uses a bit more complex contexts, and shows how to scale a value.
Line 127, Golden Joker 2 ------ Shows off a specific function that's used to add money at the end of a round.
Line 163, Merry Andy 2 -------- Shows how to use add_to_deck and remove_from_deck.
Line 207, Sock and Buskin 2 --- Shows how you can retrigger cards and check for faces
Line 240, Perkeo 2 ------------ Shows how to use the event manager, eval_status_text, randomness, and soul_pos.
Line 310, Walkie Talkie 2 ----- Shows how to look for multiple specific ranks, and explains returning multiple values
Line 344, Gros Michel 2 ------- Shows the no_pool_flag, sets a pool flag, another way to use randomness, and end of round stuff.
Line 418, Cavendish 2 --------- Shows yes_pool_flag, has X Mult, mainly to go with Gros Michel 2.
Line 482, Castle 2 ------------ Shows the use of reset_game_globals and colour variables in loc_vars, as well as what a hook is and how to use it.
--]]

--Creates an atlas for cards to use
SMODS.Atlas {
	-- Key for code to find it with
	key = "Froverhaul",
	-- The name of the file, for the code to pull the atlas from
	path = "Froverhaul.png",
	-- Width of each sprite in 1x size
	px = 71,
	-- Height of each sprite in 1x size
	py = 95
}

SMODS.Atlas {
	-- Key for code to find it with
	key = "FroverhaulTag",
	-- The name of the file, for the code to pull the atlas from
	path = "FroverhaulTag.png",
	-- Width of each sprite in 1x size
	px = 34,
	-- Height of each sprite in 1x size
	py = 34
}

SMODS.Atlas {
	-- Key for code to find it with
	key = "FroverhaulConsumable",
	-- The name of the file, for the code to pull the atlas from
	path = "FroverhaulConsumable.png",
	-- Width of each sprite in 1x size
	px = 71,
	-- Height of each sprite in 1x size
	py = 95
}

SMODS.Atlas {
	-- Key for code to find it with
	key = "FroverhaulLegendary",
	-- The name of the file, for the code to pull the atlas from
	path = "FroverhaulLegendary_Eaze.png",
	-- Width of each sprite in 1x size
	px = 71,
	-- Height of each sprite in 1x size
	py = 95
}

SMODS.Atlas {
	-- Key for code to find it with
	key = "FroverhaulEnhancement",
	-- The name of the file, for the code to pull the atlas from
	path = "FroverhaulEnhancement.png",
	-- Width of each sprite in 1x size
	px = 71,
	-- Height of each sprite in 1x size
	py = 95
}


--functions

function flipAllCards(cards)
    local i = 0
    for _, playedCard in ipairs(cards) do
        i = i + 1
        local percent = 1.15 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                playedCard:flip(); play_sound('card1', percent);
                playedCard:juice_up(0.3, 0.3); return true
            end
        }))
    end
end
--thanks fox


---------------------------------------------------------------Decks------------------------------------------------------------------

function randomSelect(table)
    for i = 1, 5 do
        math.random()
    end
    if #table == 0 then
        return nil -- Table is empty
    end
    local randomIndex = math.random(1, #table)
    return table[randomIndex]
end

SMODS.Back{
    name = "Insanity",
    key = "insane",
    pos = {x = 4, y = 3},
    config = {random = true},
    loc_txt = {
        name = "Insanity",
        text ={
            "Start with a Deck",
            "full of",
            "{C:attention}Random{} cards"
        }
    },
    apply = function()
        G.E_MANAGER:add_event(Event({
            func = function()
                local trandom_m = {
                    G.P_CENTERS.m_stone,
                    G.P_CENTERS.m_steel,
                    G.P_CENTERS.m_glass,
                    G.P_CENTERS.m_gold,
                    G.P_CENTERS.m_bonus,
                    G.P_CENTERS.m_mult,
                    G.P_CENTERS.m_wild,
                    G.P_CENTERS.m_lucky,
                    "NOTHING"
                }
                local trandom_e = {
                    {foil = true},
                    {holo = true},
                    {polychrome = true},
					{frover_iridescent = true},

                    "NOTHING"
                }
                local trandom_r = {
                    "A",
                    "K",
                    "Q",
                    "J",
                    "T",
                    "9",
                    "8",
                    "7",
                    "6",
                    "5",
                    "4",
                    "3",
                    "2"
                }
                local trandom_s = {
                    "C",
                    "D",
                    "H",
                    "S"
                }
                local trandom_g = {
                    "Red",
                    "Blue",
                    "Gold",
                    "Purple",
                    "NOTHING"
                }
                for i = #G.playing_cards, 1, -1 do
                    local random_m = randomSelect(trandom_m)
                    local random_e = randomSelect(trandom_e)
                    local random_r = randomSelect(trandom_r)
                    local random_s = randomSelect(trandom_s)
                    local random_g = randomSelect(trandom_g)

                    G.playing_cards[i]:set_base(G.P_CARDS[random_s .. "_" .. random_r])
                    if random_m  ~= "NOTHING" then
                        G.playing_cards[i]:set_ability(random_m)
                    end
                    if random_e ~= "NOTHING" then
                        G.playing_cards[i]:set_edition(random_e, true, true)
                    end
                    if random_g ~= "NOTHING" then
                        G.playing_cards[i]:set_seal(random_g, true, true)
                    end
                end

                return true
            end
        }))
    end
}


SMODS.Back{
    name = "Frozen Deck",
    key = "frozendeck",
    pos = {x = 4, y = 3},
    config = {random = true},
    loc_txt = {
        name = "Frozen Deck",
        text ={
            "Start with an",
            "{C:legendary}Iridescent{} Blueprint"
        }
    },
    
	apply = function()
        G.E_MANAGER:add_event(Event({
            func = function()
                SMODS.add_card({key="j_blueprint", edition="e_frover_iridescent"})
				return true
            end
        }))
    end
}

---------------------------------------------------------------------Jokers--------------------------------------------------------------------------
SMODS.Joker {
	-- How the code refers to the joker.
	key = 'Swag Money',
	blueprint_compat = true,
	eternal_compat = true,
	unlocked = true,
	unlock_card = true,
	discovered = true,
	-- loc_text is the actual name and description that show in-game for the card.
	loc_txt = {
		name = 'Swag Money',
		text = {
			--[[
			The #1# is a variable that's stored in config, and is put into loc_vars.
			The {C:} is a color modifier, and uses the color "mult" for the "+#1# " part, and then the empty {} is to reset all formatting, so that Mult remains uncolored.
				There's {X:}, which sets the background, usually used for XMult.
				There's {s:}, which is scale, and multiplies the text size by the value, like 0.8
				There's one more, {V:1}, but is more advanced, and is used in Castle and Ancient Jokers. It allows for a variable to dynamically change the color. You can find an example in the Castle joker if needed.
				Multiple variables can be used in one space, as long as you separate them with a comma. {C:attention, X:chips, s:1.3} would be the yellow attention color, with a blue chips-colored background,, and 1.3 times the scale of other text.
				You can find the vanilla joker descriptions and names as well as several other things in the localization files.
				]]
			"{C:mult}+#1#{} Mult for",
			"each card held in Hand",
			"{C:inactive}[Currently {C:mult}+#2#{} Mult]{}"
		}
	},
	--[[
		Config sets all the variables for your card, you want to put all numbers here.
		This is really useful for scaling numbers, but should be done with static numbers -mmmmmmm
		If you want to change the static value, you'd only change this number, instead
		of going through all your code to change each instance individually.
		]]
	config = { extra = { mult = 2 } },
	-- loc_vars gives your loc_text variables to work with, in the format of #n#, n being the variable in order.
	-- #1# is the first variable in vars, #2# the second, #3# the third, and so on.
	-- It's also where you'd add to the info_queue, which is where things like the negative tooltip are.
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult, card.ability.extra.total } }
	end,
	-- Sets rarity. 1 common, 2 uncommon, 3 rare, 4 legendary.
	rarity = 1,
	-- Which atlas key to pull from.
	atlas = 'Froverhaul',
	-- This card's position on the atlas, starting at {x=0,y=0} for the very top left.
	pos = { x = 0, y = 0 },
	-- Cost of card in shop.
	cost = 3,
	-- The functioning part of the joker, looks at context to decide what step of scoring the game is on, and then gives a 'return' value if something activates.
	calculate = function(self, card, context)
		-- Tests if context.joker_main == true.
		card.ability.extra.total = card.ability.extra.mult * #G.hand.cards
		-- joker_main is a SMODS specific thing, and is where the effects of jokers that just give +stuff in the joker area area triggered, like Joker giving +Mult, Cavendish giving XMult, and Bull giving +Chips.
		if context.joker_main then

			-- Tells the joker what to do. In this case, it pulls the value of mult from the config, and tells the joker to use that variable as the "mult_mod".
			return {
				mult_mod = card.ability.extra.total,
				-- This is a localize function. Localize looks through the localization files, and translates it. It ensures your mod is able to be translated. I've left it out in most cases for clarity reasons, but this one is required, because it has a variable.
				-- This specifically looks in the localization table for the 'variable' category, specifically under 'v_dictionary' in 'localization/en-us.lua', and searches that table for 'a_mult', which is short for add mult.
				-- In the localization file, a_mult = "+#1#". Like with loc_vars, the vars in this message variable replace the #1#.
				message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult*#G.hand.cards } }
				-- Without this, the mult will stil be added, but it'll just show as a blank red square that doesn't have any text.
			}
		end
	end
}


SMODS.Joker {
    key = 'alecpollard',
    loc_txt = {
        name = 'The Grizzler',
        text = {
            "Each played card has a",
            "{C:green}#2# in #1#{} chance to",
            "become {C:dark_edition}Negative{}",
            "upon scoring"
        }
    },
    config = { extra = { chance = 10 } },
    rarity = 3,
    atlas = 'Froverhaul',

    pos = { x = 1, y = 0 },
    cost = 8,
	blueprint_compat = false,
	eternal_compat = true,
	unlocked = true,
	unlock_card = true,
	discovered = true,

    loc_vars = function(self, info_queue, card)
        return { vars = { self.config.extra.chance, (G.GAME.probabilities.normal or 1) }}
    end,

    calculate = function(self, card, context)
        if context.before then
			local negative_true = false
			for i = 1, #context.scoring_hand do

				if math.random() < G.GAME.probabilities.normal / card.ability.extra.chance then
					--animation
					negative_true = true
					local this_card = context.scoring_hand[i]
					this_card:juice_up(0.3 ,0.3)
					delay(.3)
					play_sound('negative', 1.5, 1)
					--set the actual cards
					this_card:set_edition('e_negative', nil, true)
				end

			end
			if negative_true == true then
				return{
					message = "Oh Yeah!"
				}
			else
				return{
					message = "Nah!"
				}
			end
		end
    end
}


SMODS.Joker {
	key = 'greed',
	loc_txt = {
		name = 'King Kopel',
		text = {
			"This Joker gains {C:mult}+#2#{} Mult",
			"per {C:money}$1{} earned of {C:money}Interest{}",
			"{C:red}Destroys all{} {C:money}Interest{} {C:red}Gained{}",
			"{C:inactive}Currently{} {C:mult}+#1#{} Mult}"
		}
	},
	config = { extra = { mult = 1, multgain = 2} },
	rarity = 1,
	atlas = 'Froverhaul',
	pos = { x = 2, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult, card.ability.extra.multgain } }
	end,
-- 	calculate and return flat mult
	calculate = function(self, card, context)
		if context.joker_main then
			return {
				mult_mod = card.ability.extra.mult,
				message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }
			}
		end
	end,

-- Steal dollar value from interest
	calc_dollar_bonus = function(self, card)
		local bonus =  (G.GAME.interest_amount * math.floor(G.GAME.dollars / 5))
		bonus = math.min(bonus,((G.GAME.interest_cap * G.GAME.interest_amount) / 5))
		card.ability.extra.mult = card.ability.extra.multgain*(bonus) + card.ability.extra.mult

		return -bonus
			--message = "Stolen"
	end
	-- Since there's nothing else to calculate, a calculate function is completely unnecessary.
}
-------------------------------------------------------------------Editions--------------------------------------------------------

SMODS.Shader({ key = 'iridescent', path = 'iridescent.fs' })
SMODS.Sound({key = "iridescent",path = "iridescent.ogg", atlas_table = "ASSET_ATLAS"})

SMODS.Edition({ -- iridescent
	key = "frover_iridescent",
	loc_txt = {
		name = "Iridescent",
		label = "Iridescent",
		text = {
			"{X:chips,C:white}X#1#{} Chips",
			
		}
	},
	discovered = true,
	unlocked = true,
	shader = 'iridescent',
	-- shader=false,
	config = {
		xchips = 1.7,
	},
	in_shop = true,
	weight = 5,
	extra_cost = 6,
	-- disable_base_shader=true,
	apply_to_float = false,
	loc_vars = function(self)
		return { vars = { self.config.xchips } }
	end,
	sound = {
		sound = "frover_iridescent",
		per = 1,
		vol = 0.5,
	},
	calculate = function(self, card, context)
		if context.post_joker or (context.main_scoring and context.cardarea == G.play) then
			return {
				x_chips = self.config.xchips,
				card = card
			}
		end
	end
})


-----------------------------------------------------Tags, misc------------------------------------------------------------------
SMODS.Tag{
	
	atlas = "FroverhaulTag",
	pos = { x = 0, y = 0 },
	name = "Iridescent Tag",
	loc_txt = {
		name = "Iridescent Tag",
		label = "Iridescent Tag",
		text = {
			"Next base edition Joker",
			"in shop is {C:blue}Iridescent{}",
			
		}
	},
	order = 3,
	config = { type = "store_joker_modify", edition = "frover_iridescent" },
	key = "iridescent",
	requires = "e_frover_iridescent",
	min_ante = 1,
	loc_vars = function(self, info_queue)
		info_queue[#info_queue + 1] = G.P_CENTERS.e_frover_iridescent
		return { vars = {} }
	end,
	apply = function(self, tag, context)
		if context.type == "store_joker_modify" then
			local _applied = nil
			if not context.card.edition and not context.card.temp_edition and context.card.ability.set == "Joker" then
				local lock = tag.ID
				G.CONTROLLER.locks[lock] = true
				context.card.temp_edition = true
				tag:yep("+", G.C.DARK_EDITION, function()
					context.card:set_edition({ frover_iridescent = true }, true)
					context.card.ability.couponed = true
					context.card:set_cost()
					context.card.temp_edition = nil
					G.CONTROLLER.locks[lock] = nil
					return true
				end)
				_applied = true
				tag.triggered = true
			end
		end
	end,
}

------------------------------------------------------------------Spectrals----------------------------------------------------------

SMODS.Consumable {
    atlas = 'FroverhaulConsumable',
    key = 'ghost',
    set = 'Spectral',
    discovered = true,
    pos = { x = 0, y = 0 },
	soul_pos = {x = 0, y = 1},
    loc_txt = {
        ['en-us'] = {
            name = 'Ghost',
            text = {
				 "Turns up to 3 selected",
				 "cards {C:dark_edition}Negative{}",
				 "{C:red}-1 discard{}"
				}
        },
    },
    config = { hold = 3, extra = { odds = 1, discard_size = 1 }, max_highlighted = 3 },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.hold, card.ability.extra.odds, card.ability.extra.discard_size, (G.GAME.probabilities.normal or 1) } }
	end,
    use = function(self, card, area)
		--animation and sound
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            play_sound('negative', 1.5, 1)
			return true end }))
		
		--actual turn negative
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
			for i=1, #G.hand.highlighted do
				G.hand.highlighted[i]:set_edition('e_negative', nil, true)
				G.hand.highlighted[i]:juice_up(0.3, 0.5)
				delay(.2)
				G.hand.highlighted[i]:juice_up(0.5, 0.3)
			end
			return true end }))
		
		-- perchance lose a discard yea?
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()

			if math.random() < G.GAME.probabilities.normal / card.ability.extra.odds then
				G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.discard_size
				ease_discard(-card.ability.extra.discard_size)
			end
			return true end }))

		
	end
}


SMODS.Consumable {
    atlas = 'FroverhaulConsumable',
    key = 'graveyard',
    set = 'Spectral',
    discovered = true,
    pos = { x = 1, y = 0 },
	soul_pos = { x = 1, y = 1 },
    loc_txt = {
        ['en-us'] = {
            name = 'Graveyard',
            text = {
				 "Converts entire hand into",
				 "{C:dark_edition}Stone Cards{}",
				 "then applies {C:blue}Iridescent{}",
				 "to a random {C:money}Joker{}"
				}
        },
    },
    config = { irid = 3},
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.irid }}
	end,
	can_use = function(self, card)
        if G.STATE == G.STATES.SELECTING_HAND or G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK then

			return true
		end
		return false
	end,

    use = function(self, card, area, copier)
 
		local cards = G.hand.cards
		flipAllCards(cards)
		
		sendInfoMessage("Flipped all cards, need to implement adding a special boon")
	
		flipAllCards(cards)
		
	end
}

-------------------------------------------------------Editions and Enhancements--------------------------------------------------------



-------------------------------------------------------Vanilla Reworks-----------------------------------------------------------------
-- Buff standard packs overall, add the ability for negative playing cards to appear inside them
SMODS.Booster:take_ownership_by_kind("Standard", {
	
	create_card = function(self, card, i)
		local items = {
			{ name = "e_foil", weight = 5 },
			{ name = "e_holo", weight = 4 },
			{ name = "e_polychrome", weight = 2 },
			{ name = "e_negative", weight = 3 },
			{ name = "e_frover_iridescent", weight = 1 },
		}
		
		
		
		local _edition = poll_edition('standard_edition'..G.GAME.round_resets.ante, 2, false, false, items)
		local _seal = SMODS.poll_seal({mod = 10})
		return {set = (pseudorandom(pseudoseed('stdset'..G.GAME.round_resets.ante)) > 0.5) and "Enhanced" or "Base", edition = _edition, seal = _seal, area = G.pack_cards, skip_materialize = true, soulable = true, key_append = "sta"}
	end
})

-- TODO:
-- Have people proofread, make sure my overly long way of writing is actually legible or cut down to make sure it's legible.
-- Negative Playin Card rework- Negative playing cards ALWAYS score when played
-- Copying negative playing cards do NOT keep the edition (just like jokers)
-- increase spawnrate of neg playing cards overall
-- dont need to nerf mime or baron



----------------------------------------------
------------MOD CODE END----------------------
