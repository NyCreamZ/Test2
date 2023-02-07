util.keep_running()--ceci fait que le script ne s'arrête pas après avoir fait son travail
local scriptStartTime = util.current_time_millis()
local version = "0.1"
local Tree_V = 43
local name_script = "Test2"
--[[
--===============--
-- Auto-Updater Lib Install
--===============--
    -- Auto Updater from https://github.com/hexarobi/stand-lua-auto-updater
    local status, auto_updater = pcall(require, "auto-updater")
    if not status then
        local auto_update_complete = nil util.toast("Installing auto-updater...", TOAST_ALL)
        async_http.init("raw.githubusercontent.com", "/hexarobi/stand-lua-auto-updater/main/auto-updater.lua",
                function(result, headers, status_code)
                    local function parse_auto_update_result(result, headers, status_code)
                        local error_prefix = "Error downloading auto-updater: "
                        if status_code ~= 200 then util.toast(error_prefix..status_code, TOAST_ALL) return false end
                        if not result or result == "" then util.toast(error_prefix.."Found empty file.", TOAST_ALL) return false end
                        filesystem.mkdir(filesystem.scripts_dir() .. "lib")
                        local file = io.open(filesystem.scripts_dir() .. "lib\\auto-updater.lua", "wb")
                        if file == nil then util.toast(error_prefix.."Could not open file for writing.", TOAST_ALL) return false end
                        file:write(result) file:close() util.toast("Successfully installed auto-updater lib", TOAST_ALL) return true
                    end
                    auto_update_complete = parse_auto_update_result(result, headers, status_code)
                end, function() util.toast("Error downloading auto-updater lib. Update failed to download.", TOAST_ALL) end)
        async_http.dispatch() local i = 1 while (auto_update_complete == nil and i < 40) do util.yield(250) i = i + 1 end
        if auto_update_complete == nil then error("Error downloading auto-updater lib. HTTP Request timeout") end
        auto_updater = require("auto-updater")
    end
    if auto_updater == true then error("Invalid auto-updater lib. Please delete your Stand/Lua Scripts/lib/auto-updater.lua and try again") end

    --- Config
    local languages = {
        'french',
        'english',
    }

    --- Auto-Update
    local auto_update_config = {
        source_url="https://raw.githubusercontent.com/NyCreamZ/"..name_script.."/main/"..name_script..".lua",
        script_relpath=SCRIPT_RELPATH,
        --silent_updates=true,
        dependencies={
            {
                name="functions",
                source_url="https://raw.githubusercontent.com/NyCreamZ/"..name_script.."/main/lib/"..name_script.."/functions.lua",
                script_relpath="lib/"..name_script.."/functions.lua",
            },
            {
                name="weapons",
                source_url="https://raw.githubusercontent.com/NyCreamZ/"..name_script.."/main/lib/"..name_script.."/weapons.lua",
                script_relpath="lib/"..name_script.."/weapons.lua",
            },
            {
                name="vehicles",
                source_url="https://raw.githubusercontent.com/NyCreamZ/"..name_script.."/main/lib/"..name_script.."/vehicles.lua",
                script_relpath="lib/"..name_script.."/vehicles.lua",
            },
        }
    }

    for _, language in pairs(languages) do
        local language_config = {
            name=language,
            source_url="https://raw.githubusercontent.com/NyCreamZ/"..name_script.."/main/lib/"..name_script.."/Languages/"..language..".lua",
            script_relpath="lib/"..name_script.."/Languages/"..language..".lua",
        }
        table.insert(auto_update_config.dependencies, language_config)
    end

    auto_updater.run_auto_update(auto_update_config)
--===============--
-- FIN Auto-Updater Lib Install
--===============--
]]
--===============--
-- Fichier
--===============--
    local required <const> = {
    	"lib/natives-1663599433.lua",
    	"lib/"..name_script.."/functions.lua",
    	"lib/"..name_script.."/vehicles.lua",
    	"lib/"..name_script.."/weapons.lua",
    }
    local scriptdir <const> = filesystem.scripts_dir()
    local libDir <const> = scriptdir .. "\\lib\\"..name_script.."\\"
    local languagesDir <const> = libDir .. "\\Languages\\"
    local relative_languagesDir <const> = "./lib/"..name_script.."/Languages/"

    for _, file in ipairs(required) do
    	assert(filesystem.exists(scriptdir .. file), "required file not found: " .. file)
    end

    require "Test2.functions"
    require "Test2.vehicles"
    require "Test2.weapons"
    local Json = require("json")
    --util.require_natives("natives-1672190175-uno")
    util.ensure_package_is_installed('lua/natives-1663599433')
    util.require_natives(1663599433)
    --util.require_natives(1640181023)

    if not filesystem.exists(libDir) then
    	filesystem.mkdir(libDir)
    end

    if not filesystem.exists(languagesDir) then
    	filesystem.mkdir(languagesDir)
    end

    if filesystem.exists(filesystem.resources_dir() .. "NyTextures.ytd") then
        util.register_file(filesystem.resources_dir() .. "NyTextures.ytd")
        notification.txdDict = "NyTextures"
        notification.txdName = "logo"
        --request_streamed_texture_dict("NyTextures")
        util.spoof_script("main_persistent", function()
            GRAPHICS.REQUEST_STREAMED_TEXTURE_DICT("NyTextures", false)
        end)
    else
        error("required file not found: NyTextures.ytd" )
    end
--===============--
-- FIN Fichier
--===============--
--===============--
-- Translation
--===============--
    -- credit http://lua-users.org/wiki/StringRecipes
    local function ends_with(str, ending)
        return ending == "" or str:sub(-#ending) == ending
    end

    Translations = {}
    setmetatable(Translations, {
        __index = function (self, key)
            return key
        end
    })

    local languageDir_files = {}
    local just_language_files = {}
    for i, path in ipairs(filesystem.list_files(languagesDir)) do
        local file_str = path:gsub(languagesDir, '')
        languageDir_files[#languageDir_files + 1] = file_str
        if ends_with(file_str, '.lua') then
            just_language_files[#just_language_files + 1] = file_str
        end
    end

    -- do not play with this unless you want shit breakin!
    local need_default_language

    if not table.contains(languageDir_files, 'english.lua') then
        need_default_language = true
        async_http.init('raw.githubusercontent.com', 'NyCreamZ/'..name_script..'/main/lib/'..name_script..'/Languages/english.lua', function(data)
            local file = io.open(translations_dir .. "/english.lua",'w')
            file:write(data)
            file:close()
            need_default_language = false
        end, function()
            util.toast('!!! Failed to retrieve default translation table. All options that would be translated will look weird. Please check your connection to GitHub.')
        end)
        async_http.dispatch()
    else
        need_default_language = false
    end

    while need_default_language do
        util.toast("Looks like there was an update! Installing default/english translation now.")
        util.yield()
    end

    local selected_lang_path = languagesDir .. 'selected_language.txt'
    if not table.contains(languageDir_files, 'selected_language.txt') then
        local file = io.open(selected_lang_path, 'w')
        file:write('english.lua')
        file:close()
    end

    -- read selected language 
    local selected_lang_file = io.open(selected_lang_path, 'r')
    local selected_language = selected_lang_file:read()
    if not table.contains(languageDir_files, selected_language) then
        notification.stand(selected_language .. ' was not found. Defaulting to English.')
        Translations = require(relative_languagesDir .. "english")
    else
        Translations = require(relative_languagesDir .. '\\' .. selected_language:gsub('.lua', ''))
    end

--===============--
-- COMPTEUR D'UTilisation
--===============--
-- BEGIN ANONYMOUS USAGE TRACKING 
async_http.init('pastebin.com', '89Js2RDM', function() end)
async_http.dispatch()
-- END ANONYMOUS USAGE TRACKING 

--===============--
-- Local
--===============--

    local interior_stuff = {0, 233985, 169473, 169729, 169985, 170241, 177665, 177409, 185089, 184833, 184577, 163585, 167425, 167169}
    local commands = menu.trigger_commands
    local stand_edition = menu.get_edition()
    local lua_path = "Stand>Lua Scripts>"..string.gsub(string.gsub(SCRIPT_RELPATH,".lua",""),"\\",">")
        --lua_path..">"..Translations.self_root..">"..Translations.self_cleanloop,

    -------------
    -- JOIN
    -------------
        --Language JOIN
            --local lang = {'en-US','fr-FR','de-DE','it-IT','es-ES','pt-BR','pl-PL','ru-RU','ko-KR','zh-TW','ja-JP','es-MX','zh-CN'}
            local nation_lang2 = {"EN", "FR", "DE", "IT", "ES", "BR", "PL", "RU", "KR", "TW", "JP", "MX", "CN"}
            local nation_lang = {Translations.nation_us, Translations.nation_fr, Translations.nation_de, Translations.nation_it, Translations.nation_es, Translations.nation_br, Translations.nation_pl, Translations.nation_ru, Translations.nation_kr, Translations.nation_tw, Translations.nation_jp, Translations.nation_mx, Translations.nation_cn}
            local nation_notify = false
            local nation_save = false
            local nation_select = 1
    -------------
    -- SELF
    -------------
        --GOD
            local self_list = {
                god = {
                    "Self>Immortality",
                    "Self>Auto Heal",
                    "Self>Gracefulness",
                    "Self>Glued To Seats",
                    "Self>Lock Wanted Level",
                    "Self>Infinite Stamina",
                    "Self>Appearance>No Blood",
                },
            }

            local self_value = {god = {}, ghost = {}}

    ---AIMBOT SILENCIEUX
    local handle_ptr = memory.alloc(13*8)
    local function pid_to_handle(pid)
        NETWORK.NETWORK_HANDLE_FROM_PLAYER(pid, handle_ptr, 13)
        return handle_ptr
    end

    local aimbot_mode = "closest"
    local aimbot_options_damage, aimbot_options_use_fov, aimbot_options_fov, aimbot_options_mode, aimbot_options_cible = 100, true, 60, 1, 1
    local aimbot_target_players, aimbot_target_friends, aimbot_target_godmode, aimbot_target_npcs, aimbot_target_vehicles = true, false, true, false, false
    local aimbot_show_target = true
    local aimbot_custom_type = 1
    local aimbot_custom_colour = {r = 1, g = 0.0, b = 0.0, a = 1.0}

    local function get_aimbot_target()
        local dist = 1000000000
        local cur_tar = 0
        -- an aimbot should have immaculate response time so we shouldnt rely on the other entity pools for this data
        for k,v in pairs(entities.get_all_peds_as_handles()) do
            local target_this = true
            local player_pos = players.get_position(players.user())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(v, true)
            local this_dist = MISC.GET_DISTANCE_BETWEEN_COORDS(player_pos['x'], player_pos['y'], player_pos['z'], ped_pos['x'], ped_pos['y'], ped_pos['z'], true)
            if players.user_ped() ~= v and not ENTITY.IS_ENTITY_DEAD(v) then
                if not aimbot_target_players then
                    if PED.IS_PED_A_PLAYER(v) then
                        target_this = false
                    end
                end
                if not aimbot_target_npcs then
                    if not PED.IS_PED_A_PLAYER(v) then
                        target_this = false
                    end
                end
                if not ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(players.user_ped(), v, 17) then
                    target_this = false
                end
                if aimbot_options_use_fov then
                    if not PED.IS_PED_FACING_PED(players.user_ped(), v, aimbot_options_fov) then
                        target_this = false
                    end
                end
                if aimbot_target_vehicles then
                    if PED.IS_PED_IN_ANY_VEHICLE(v, true) then
                        target_this = false
                    end
                end
                if aimbot_target_godmode then
                    if not ENTITY.GET_ENTITY_CAN_BE_DAMAGED(v) then
                        target_this = false
                    end
                end
                if not aimbot_target_friends --[[and aimbot_target_players]] then
                    if PED.IS_PED_A_PLAYER(v) then
                        local pid = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(v)
                        local hdl = pid_to_handle(pid)
                        if NETWORK.NETWORK_IS_FRIEND(hdl) then
                            target_this = false
                        end
                    end
                end
                if aimbot_mode == "closest" then
                    if this_dist <= dist then
                        if target_this then
                            dist = this_dist
                            cur_tar = v
                        end
                    end
                end
            end
        end
        return cur_tar
    end

    ---ANTI AGRESSEURS
    local anti_muggers_options = {}
    anti_muggers_options["myself"] = {}
    anti_muggers_options["myself"]["block"] = false
    anti_muggers_options["myself"]["notif"] = true
    anti_muggers_options["someone_else"] = {}
    anti_muggers_options["someone_else"]["block"] = false
    anti_muggers_options["someone_else"]["notif"] = true

    ---ANTI VEHICULES
    Menus = {}
    Anti_vehicles_list = {}
    local anti_vehicles_model
    local anti_vehicles_options = {}
    anti_vehicles_options["remove"] = false
    anti_vehicles_options["notif"] = true
    local anti_vehicles_file = scriptdir.."lib/"..name_script.."/anti_vehicles.json"
    if not filesystem.exists(anti_vehicles_file) then
        local filehandle = io.open(anti_vehicles_file, "w")
        if filehandle then
            filehandle:write(Json.encode(Anti_vehicles_list))
            filehandle:close()
        end
    else
        local filehandle = io.open(anti_vehicles_file, "r")
        if filehandle then
            Anti_vehicles_list = Json.decode(filehandle:read())
            filehandle:close()
        end
    end
    ---FIN ANTI VEHICLES
--===============--
-- FIN Local
--===============--

players.on_join(function (pid)
    if pid == players.user() then return end
    while not util.is_session_started() or util.is_session_transition_active() do
        util.yield()
    end
    if nation_notify or nation_save then
        local player_language = players.get_language(pid) + 1
        if nation_select == player_language then
            local player_name = players.get_name(pid):lower()
            if nation_notify then
                notification.stand(player_name .. Translations.nation_notify_arg .. nation_lang[player_language] .. ".")
            end
            if nation_save and menu.ref_by_command_name("historynote"..player_name:lower()).value == "" then
                --menu.ref_by_path("Online>Player History>"..players.get_name(pid).." [Publique]>Note", Tree_V).value
                --menu.ref_by_command_name("historynote"..players.get_name(pid):lower()).value
                commands("historynote" .. player_name .. " " .. nation_lang2[player_language])
            end
        end
    end
end)

--===============--
--[[ Main ]] local main_root = menu.my_root()
--===============--

    main_root:action("test", {}, "", function ()
        --AUDIO.STOP_SOUND(-1)
        --AUDIO.STOP_PED_RINGTONE(PLAYER.PLAYER_PED_ID())
        --util.yield(1000)
        --AUDIO.PLAY_SOUND(-1, "Event_Message_Purple", "GTAO_FM_Events_Soundset", 0, 0, 0)
	    --AUDIO.PLAY_SOUND(-1, "Boss_Message_Orange", "GTAO_Biker_FM_Soundset", 0, 0, 0)
	    --AUDIO.PLAY_SOUND(-1, "Boss_Message_Orange", "GTAO_Boss_Goons_FM_Soundset", 0, 0, 0)
	    --AUDIO.PLAY_SOUND(-1, "FestiveGift", "Feed_Message_Sounds", 0, 0, 0)
    end)

    --===============--
    --[[ Self ]] local self_root = main_root:list(Translations.self_root, {}, Translations.self_root_desc)
    --===============--

        ---God
        self_root:toggle(Translations.self_godmode,{},Translations.self_godmode_desc, function(on)
            for _,path in pairs(self_list.god) do
                if on then
                    self_value.god[path] = menu.ref_by_path(path, Tree_V).value
                    menu.set_value(menu.ref_by_path(path, Tree_V), true)
                elseif not self_value.god[path] then
                    menu.set_value(menu.ref_by_path(path, Tree_V), false)
                end
            end
        end)

        ---Respiration infinie
        self_root:toggle(Translations.self_unlimair, {}, Translations.self_unlimair_desc, function(on)
        	PED.SET_PED_DIES_IN_SINKING_VEHICLE(PLAYER.PLAYER_PED_ID(), not on)
            PED.SET_PED_DIES_IN_WATER(PLAYER.PLAYER_PED_ID(), not on)
            --PED.SET_PED_MAX_TIME_IN_WATER(PLAYER.PLAYER_PED_ID(), -1)
            --PED.SET_PED_MAX_TIME_UNDERWATER(PLAYER.PLAYER_PED_ID(), -1)
        end, false)

        ---Sang-Froid
        self_root:toggle(Translations.self_cold_blood, {}, Translations.self_cold_blood_desc, function(on)
            PED.SET_PED_HEATSCALE_OVERRIDE(players.user_ped(), (on and 0 or 1.0))
        end, false)

        ---Ninja
        self_root:toggle(Translations.self_ninja, {}, Translations.self_ninja_desc, function(on)
            AUDIO.SET_PED_FOOTSTEPS_EVENTS_ENABLED(players.user_ped(), not on)
            AUDIO.SET_PED_CLOTH_EVENTS_ENABLED(players.user_ped(), not on)
        end, false)

        ---Fantôme
        self_root:toggle(Translations.self_ghost, {}, Translations.self_ghost_desc, function(on)
            --Invisibility: 0=Disabled | 1=Locally Visible | 2=Enabled
            local path1 = "Self>Appearance>Invisibility"
            local path2 = "Online>Off The Radar"
            if on then
                self_value.ghost[path1] = menu.ref_by_path(path1, Tree_V).value
                self_value.ghost[path2] = menu.ref_by_path(path2, Tree_V).value
                menu.set_value(menu.ref_by_path(path1, Tree_V), 1)
                menu.set_value(menu.ref_by_path(path2, Tree_V), true)
            else
                if self_value.ghost[path1] ~= 1 or self_value.ghost[path1] ~= menu.ref_by_path(path1, Tree_V).value then
                    menu.set_value(menu.ref_by_path(path1, Tree_V), self_value.ghost[path1])
                end
                if not self_value.ghost[path2] then
                    menu.set_value(menu.ref_by_path(path2, Tree_V), on)
                end
            end
        end, false)

    --===============--
    -- FIN Self
    --===============--

    --===============--
    --[[ Weapon ]] local weapon_root = main_root:list(Translations.weapon_root, {}, Translations.weapon_root_desc)
    --===============--

        -------------------
        --- AIMBOT SILENCIEUX
        -------------------
        local aimbot_root = weapon_root:list(Translations.weapon_aimbot_root, {}, Translations.weapon_aimbot_root_desc)

            aimbot_root:toggle_loop(Translations.weapon_aimbot, {"nyaimbot"}, Translations.weapon_aimbot_desc, function(toggle)
                local target = get_aimbot_target()
                if target ~= 0 then
                    ---ARME
                    local weaponped = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(players.user_ped(), true)
                    local min, max = v3.new(), v3.new()
                    --Obtient les dimensions d'un modèle. Calculez (maximum - minimum) pour obtenir la taille, auquel cas, Y sera la longueur du modèle.
                    MISC.GET_MODEL_DIMENSIONS(ENTITY.GET_ENTITY_MODEL(weaponped), min, max)
                    --Les valeurs de décalage sont relatives à l'entité. x = left/right, y = forward/backward, z = up/down
                    --x max= avant(embout), x min= arriere(crosse) y max= droite(vue de face), y min = gauche (vue de face)
                    local startLine = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(weaponped,  max.x, 0, 0.04)

                    ---POSITION
                    local t_pos
                    local t_pos2
                    local t_pos_target = ENTITY.GET_ENTITY_COORDS(target, true)
                    --HEAD, TORSO, RANDOM
                    local t_pos_search = {
                        --PED.GET_PED_BONE_COORDS(target, 31086, 0.05, 0.25, 0),-- 0.01, 0, 0
                        PED.GET_PED_BONE_COORDS(target, 27474, 0.25, 0.04, 0),
                        PED.GET_PED_BONE_COORDS(target, 24818, 0, 0.25, 0),-- 0.01, 0, 0
                    }
                    local t_pos2_search = {
                        --PED.GET_PED_BONE_COORDS(target, 31086, 0.125, 0, 0),-- -0.01, 0, 0.00
                        PED.GET_PED_BONE_COORDS(target, 27474, 0, 0.04, 0),
                        PED.GET_PED_BONE_COORDS(target, 24818, 0, 0, 0),
                    }
                    local aimbot_options_cible_random = math.random(2)

                    --Cheat, Legit
                    if aimbot_options_mode == 1 then
                        if aimbot_options_cible ~= 3 then
                            t_pos = t_pos_search[aimbot_options_cible]
                        else
                            t_pos = t_pos_search[aimbot_options_cible_random]
                        end
                    else
                        t_pos = startLine
                    end

                    if aimbot_options_cible ~= 3 then
                        t_pos2 = t_pos2_search[aimbot_options_cible]
                    else
                        t_pos2 = t_pos2_search[aimbot_options_cible_random]
                    end

                    if aimbot_show_target then
                        if aimbot_custom_type == 1 then
                            GRAPHICS.DRAW_MARKER(0, t_pos_target.x, t_pos_target.y, t_pos_target.z+2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 1, math.floor(aimbot_custom_colour.r*255), math.floor(aimbot_custom_colour.g*255), math.floor(aimbot_custom_colour.b*255), math.floor(aimbot_custom_colour.a*255), false, true, 2, false, 0, 0, false)
                        elseif aimbot_custom_type == 2 then
                            GRAPHICS.DRAW_MARKER(2, t_pos_target.x, t_pos_target.y, t_pos_target.z+2, 0, 0, 0, 0.0, 180, 0.0, 1, 1, 1, math.floor(aimbot_custom_colour.r*255), math.floor(aimbot_custom_colour.g*255), math.floor(aimbot_custom_colour.b*255), math.floor(aimbot_custom_colour.a*255), false, true, 2, false, 0, 0, false)
                        else
                            GRAPHICS.DRAW_LINE(startLine.x, startLine.y, startLine.z, t_pos2.x, t_pos2.y, t_pos2.z, math.floor(aimbot_custom_colour.r*255), math.floor(aimbot_custom_colour.g*255), math.floor(aimbot_custom_colour.b*255), math.floor(aimbot_custom_colour.a*255))
                        end
                    end
                    if PED.IS_PED_SHOOTING(players.user_ped()) then
                        local wep = WEAPON.GET_SELECTED_PED_WEAPON(players.user_ped())
                        local dmg = WEAPON.GET_WEAPON_DAMAGE(wep, 0) * aimbot_options_damage / 100
                        local veh = PED.GET_VEHICLE_PED_IS_IN(target, false)
                        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(t_pos['x'], t_pos['y'], t_pos['z'], t_pos2['x'], t_pos2['y'], t_pos2['z'], dmg, true, wep, players.user_ped(), true, false, 10000, veh)
                    end
                end
            end)
            --commands("nyaimbot", true)

            ---OPTIONS
            local aimbot_options_root = aimbot_root:list(Translations.weapon_aimbot_options_root, {}, Translations.weapon_aimbot_options_root_desc)

                aimbot_options_root:slider(Translations.weapon_aimbot_options_damage, {}, Translations.weapon_aimbot_options_damage_desc, 1, 1000, aimbot_options_damage, 10, function(s)
                    aimbot_options_damage = s
                end)

                aimbot_options_root:toggle(Translations.weapon_aimbot_options_use_fov, {}, Translations.weapon_aimbot_options_use_fov_desc, function(on)
                    aimbot_options_use_fov = on
                end, aimbot_options_use_fov)

                aimbot_options_root:slider(Translations.weapon_aimbot_options_fov, {}, Translations.weapon_aimbot_options_fov_desc, 1, 270, aimbot_options_fov, 1, function(s)
                    aimbot_options_fov = s
                end)

                aimbot_options_root:list_select(Translations.weapon_aimbot_options_mode, {}, Translations.weapon_aimbot_options_mode_desc, {"Cheat", "Legit"}, aimbot_options_mode, function (index)
                    aimbot_options_mode = index
                end)

                aimbot_options_root:list_select(Translations.weapon_aimbot_options_cible, {}, Translations.weapon_aimbot_options_cible_desc, {"Head", "Torso", "Random"}, aimbot_options_cible, function (index)
                    aimbot_options_cible = index
                end)

            aimbot_root:toggle(Translations.weapon_aimbot_players, {}, Translations.weapon_aimbot_players_desc, function(on)
                aimbot_target_players = on
            end, aimbot_target_players)

            aimbot_root:toggle(Translations.weapon_aimbot_friends, {}, Translations.weapon_aimbot_friends_desc, function(on)
                aimbot_target_friends = on
            end, aimbot_target_friends)

            aimbot_root:toggle(Translations.weapon_aimbot_godmode, {}, Translations.weapon_aimbot_godmode_desc, function(on)
                aimbot_target_godmode = on
            end, aimbot_target_godmode)

            aimbot_root:toggle(Translations.weapon_aimbot_npcs, {}, Translations.weapon_aimbot_npcs_desc, function(on)
                aimbot_target_npcs = on
            end, aimbot_target_npcs)

            aimbot_root:toggle(Translations.weapon_aimbot_vehicles, {}, Translations.weapon_aimbot_vehicles_desc, function(on)
                aimbot_target_vehicles = on
            end, aimbot_target_vehicles)

            aimbot_root:toggle(Translations.weapon_aimbot_display, {}, Translations.weapon_aimbot_display_desc, function(on)
                aimbot_show_target = on
            end, aimbot_show_target)

            ---CUSTOM
            local aimbot_custom_root = aimbot_root:list(Translations.weapon_aimbot_custom_root, {}, Translations.weapon_aimbot_custom_root_desc)

                --type
                aimbot_custom_root:slider(Translations.weapon_aimbot_custom_type, {}, Translations.weapon_aimbot_custom_type_desc, 1, 3, aimbot_custom_type, 1, function (s)
                    aimbot_custom_type = s
                end)

                --color
                local aimbot_custom_colour_root = aimbot_custom_root:colour(Translations.weapon_aimbot_custom_colour_root, {"nyaimbotmarkcolor"}, Translations.weapon_aimbot_custom_colour_root_desc, aimbot_custom_colour, true, function (newColour)
                    aimbot_custom_colour = newColour
                end)
                aimbot_custom_colour_root:rainbow()

        --- FIN AIMBOT

    --===============--
    -- FIN Weapon
    --===============--

    --===============--
    --[[ VEHICULES ]] local vehicle_root = main_root:list(Translations.vehicle_root, {}, Translations.vehicle_root_desc)
    --===============--

        --Auto-flip vehicle
        vehicle_root:toggle_loop("Auto-flip Vehicle", {}, "Automatically flips your car the right way if you land upside-down or sideways.", function()
            local player_vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
            local rotation = CAM.GET_GAMEPLAY_CAM_ROT(2)
            local heading = v3.getHeading(v3.new(rotation))
            local vehicle_distance_to_ground = ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(player_vehicle)
            local am_i_on_ground = vehicle_distance_to_ground < 2 --and true or false
            local speed = ENTITY.GET_ENTITY_SPEED(player_vehicle)
            if not VEHICLE.IS_VEHICLE_ON_ALL_WHEELS(player_vehicle) and ENTITY.IS_ENTITY_UPSIDEDOWN(player_vehicle) and am_i_on_ground then
                VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(player_vehicle, 5.0)
                ENTITY.SET_ENTITY_HEADING(player_vehicle, heading)
                util.yield()
                VEHICLE.SET_VEHICLE_FORWARD_SPEED(player_vehicle, speed)
            end
        end)

        --[[
        easyenter = off
        menu.toggle(vehmenu, EASY_ENTER, {}, "", function(on)
        	easyenter = on
        	while easyenter do
        		if not (PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(plyped()) == 0) then
        			requestControlLoop(PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(plyped()))
        			VEHICLE.BRING_VEHICLE_TO_HALT(PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(plyped()), 0, 1)
        		end
        		util.yield()
        	end
        end)

        menu.toggle_loop(vehmenu, ANTI_CARJACKING, {}, "", function()
        	if not (veh == 0) then
        		plyseat = 0
        		for i = -1, 30 do
        			if (VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, i) == plyped()) then
        				plyseat = i
        			end
        		end
        		if PED.IS_PED_BEING_JACKED(plyped()) then
        			PED.SET_PED_INTO_VEHICLE(plyped(), veh, plyseat)
        		end
        	end
        end)

        menu.toggle_loop(vehmenu, KEEP_ON, {}, KEEP_ON_DESC, function()
        	if VEHICLE.IS_THIS_MODEL_A_HELI(ENTITY.GET_ENTITY_MODEL(vehlast)) or VEHICLE.IS_THIS_MODEL_A_PLANE(ENTITY.GET_ENTITY_MODEL(vehlast)) then
        		VEHICLE.SET_HELI_BLADES_FULL_SPEED(vehlast)
        	else
        		VEHICLE.SET_VEHICLE_ENGINE_ON(vehlast, true, true, true)
        	end
        end)

        -----------------------------------
        -- Speed and handling
        -----------------------------------
        JSlang.list(_LR['Vehicle'], 'Speed and handling', {'JSspeedHandling'}, '')

        JSlang.toggle(_LR['Speed and handling'], 'Low traction', {'JSlowTraction'}, 'Makes your vehicle have low traction, I recommend setting this to a hotkey.', function(toggle)
            carSettings.lowTraction.on = toggle
            carSettings.lowTraction.setOption(toggle)
        end)

        JSlang.toggle(_LR['Speed and handling'], 'Launch control', {'JSlaunchControl'}, 'Limits how much force your car applies when accelerating so it doesn\'t burnout, very noticeable in a Emerus.', function(toggle)
            carSettings.launchControl.on = toggle
            carSettings.launchControl.setOption(toggle)
        end)

        local my_torque = 100
        JSlang.slider_float(_LR['Speed and handling'], 'Set torque', {'JSsetSelfTorque'}, 'Modifies the speed of your vehicle.', -1000000, 1000000, my_torque, 1, function(value)
            my_torque = value
            util.create_tick_handler(function()
                VEHICLE.SET_VEHICLE_CHEAT_POWER_INCREASE(my_cur_car, my_torque/100)
                return (my_torque != 100)
            end)
        end)

        local quickBrakeLvL = 1.5
        JSlang.toggle_loop(_LR['Speed and handling'], 'Quick brake', {'JSquickBrake'}, 'Slows down your speed more when pressing "S".', function(toggle)
            if JSkey.is_control_just_pressed(2, 'INPUT_VEH_BRAKE') and ENTITY.GET_ENTITY_SPEED(my_cur_car) >= 0 and not ENTITY.IS_ENTITY_IN_AIR(my_cur_car) and VEHICLE.GET_PED_IN_VEHICLE_SEAT(my_cur_car, -1, false) == players.user_ped() then
                VEHICLE.SET_VEHICLE_FORWARD_SPEED(my_cur_car, ENTITY.GET_ENTITY_SPEED(my_cur_car) / quickBrakeLvL)
                util.yield(250)
            end
        end)

        JSlang.slider_float(_LR['Speed and handling'], 'Quick brake force', {'JSquickBrakeForce'}, '1.00 is ordinary brakes.', 100, 999, 150, 1,  function(value)
            quickBrakeLvL = value / 100
        end)


        JSlang.toggle_loop(_LR['Vehicle doors'], 'Shut doors when driving', {'JSautoClose'}, 'Closes all the vehicle doors when you start driving.', function()
            if not (is_user_driving_vehicle() and ENTITY.GET_ENTITY_SPEED(my_cur_car) > 1) then return end  --over a speed of 1 because car registers as moving then doors move

            if ENTITY.GET_ENTITY_SPEED(my_cur_car) < 10 then
                util.yield(800)
            else
                util.yield(600)
            end

            local closed = false
            for i, door in ipairs(carDoors) do
                if VEHICLE.GET_VEHICLE_DOOR_ANGLE_RATIO(my_cur_car, i - 1) > 0 and not VEHICLE.IS_VEHICLE_DOOR_DAMAGED(my_cur_car, i - 1) then
                    VEHICLE.SET_VEHICLE_DOOR_SHUT(my_cur_car, i - 1, false)
                    closed = true
                end
            end
            if notifications and closed then
                JSlang.toast('Closed your car doors.')
            end
        end)
        ]]

    --===============--
    --[[ Online ]] local online_root = main_root:list(Translations.online_root, {}, Translations.online_root_desc)
    --===============--

        -------------------
        --- SESSION
        -------------------
        local session_root = online_root:list(Translations.online_session_root, {}, Translations.online_session_root_desc)

            session_root:toggle(Translations.online_session_nation_notify, {}, Translations.online_session_nation_notify_desc, function(on)
                nation_notify = on
            end, nation_notify)

            session_root:toggle(Translations.online_session_nation_save, {}, Translations.online_session_nation_save_desc, function(on)
                nation_save = on
            end, nation_save)

            session_root:list_select(Translations.online_session_nation_select, {}, Translations.online_session_nation_select_desc, nation_lang, nation_select, function (index)
                nation_select = index
            end)

    --===============--
    -- FIN Online
    --===============--
    --===============--
    --[[ Détections ]] local detex_root = main_root:list(Translations.detection_root, {}, Translations.detection_root_desc)
    --===============--

        -- PED
        menu.divider(detex_root, Translations.detection_divider_ped)

        detex_root:toggle_loop(Translations.detection_godmode, {}, Translations.detection_godmode_desc, function()
            for _, pid in ipairs(players.list(false, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
                for _, id in ipairs(interior_stuff) do
                    if players.is_godmode(pid) and not players.is_in_interior(pid) and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(ped) and Get_spawn_state(pid) == 99 and Get_interior_player_is_in(pid) == id then
                        notification.draw_debug_text(Translations.detection_godmode_draw, players.get_name(pid))
                        break
                    end
                end
            end
        end)

        detex_root:toggle_loop(Translations.detection_glitched_godmode, {}, Translations.detection_glitched_godmode_desc, function()
            for _, pid in ipairs(players.list(false, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
                for _, id in ipairs(interior_stuff) do
                    if players.is_in_interior(pid) and players.is_godmode(pid) and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(ped) and Get_spawn_state(pid) == 99 and Get_interior_player_is_in(pid) == id then
                        notification.draw_debug_text(Translations.detection_glitched_godmode_draw, players.get_name(pid))
                        break
                    end
                end
            end
        end)

        detex_root:toggle_loop(Translations.detection_super_run, {}, Translations.detection_super_run_desc, function()
            for _, pid in ipairs(players.list(false, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local ped_speed = (ENTITY.GET_ENTITY_SPEED(ped)* 2.236936)
                if not util.is_session_transition_active() and Get_interior_player_is_in(pid) == 0 and Get_spawn_state(pid) ~= 0 and not PED.IS_PED_DEAD_OR_DYING(ped) 
                and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(ped) and not PED.IS_PED_IN_ANY_VEHICLE(ped, false)
                and not TASK.IS_PED_STILL(ped) and not PED.IS_PED_JUMPING(ped) and not ENTITY.IS_ENTITY_IN_AIR(ped) and not PED.IS_PED_CLIMBING(ped) and not PED.IS_PED_VAULTING(ped)
                and v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), players.get_position(pid)) <= 300.0 and ped_speed > 30 then
                    notification.stand(Translations.detection_super_run_toast, players.get_name(pid))
                    break
                end
            end
        end)

        detex_root:toggle_loop(Translations.detection_tp, {}, Translations.detection_tp_desc, function()
            for _, pid in ipairs(players.list(true, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                if not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(ped) and not PED.IS_PED_DEAD_OR_DYING(ped) then
                    local oldpos = players.get_position(pid)
                    util.yield(50) --250
                    local currentpos = players.get_position(pid)
                    local distance_between_tp = v3.distance(oldpos, currentpos)
                    if distance_between_tp > 500.0 then
                        for i, interior in ipairs(interior_stuff) do
                            if Get_interior_player_is_in(pid) == interior  and Get_spawn_state(pid) ~= 0 and players.exists(pid) then
                                util.yield(100)
                                notification.stand(Translations.detection_tp_toast, players.get_name(pid), SYSTEM.ROUND(distance_between_tp))
                            end
                        end
                    end
                end
            end
        end)

        detex_root:toggle_loop(Translations.detection_tp_v2, {}, Translations.detection_tp_v2_desc, function()
            for _, pid in ipairs(players.list(true, true, true)) do
                local old_pos = players.get_position(pid)
                util.yield(50)
                local cur_pos = players.get_position(pid)
                local distance_between_tp = v3.distance(old_pos, cur_pos)
                for _, id in ipairs(interior_stuff) do
                    if Get_interior_player_is_in(pid) == id and Get_spawn_state(pid) ~= 0 and players.exists(pid) then
                        util.yield(100)
                        if distance_between_tp > 300.0 then
                            notification.stand(Translations.detection_tp_v2_toast, players.get_name(pid), SYSTEM.ROUND(distance_between_tp))
                        end
                    end
                end
            end
        end)

        --[[detex_root:toggle_loop(Translations.detection_no_clip, {}, Translations.detection_no_clip_desc, function()
            for _, pid in ipairs(players.list(false, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local ped_ptr = entities.handle_to_pointer(ped)
                local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)
                local oldpos = players.get_position(pid)
                util.yield()
                local currentpos = players.get_position(pid)
                local vel = ENTITY.GET_ENTITY_VELOCITY(ped)
                if not util.is_session_transition_active() and players.exists(pid)
                and Get_interior_player_is_in(pid) == 0 and Get_spawn_state(pid) ~= 0
                and not PED.IS_PED_IN_ANY_VEHICLE(ped, false)
                and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(ped) and not PED.IS_PED_DEAD_OR_DYING(ped)
                and not PED.IS_PED_CLIMBING(ped) and not PED.IS_PED_VAULTING(ped) and not PED.IS_PED_USING_SCENARIO(ped)
                and not TASK.GET_IS_TASK_ACTIVE(ped, 160) and not TASK.GET_IS_TASK_ACTIVE(ped, 2)
                and v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), players.get_position(pid)) <= 395.0 
                and ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(ped) > 5.0 and not ENTITY.IS_ENTITY_IN_AIR(ped) and entities.player_info_get_game_state(ped_ptr) == 0
                and oldpos.x ~= currentpos.x and oldpos.y ~= currentpos.y and oldpos.z ~= currentpos.z 
                and vel.x == 0.0 and vel.y == 0.0 and vel.z == 0.0 then
                    notification.stand(Translations.detection_no_clip_toast, players.get_name(pid))
                    break
                end
            end
        end)]]--

        --[[detex_root:toggle_loop("Modded Animation", {}, "", function()
            for _, pid in ipairs(players.list(false, true, true)) do
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                if PED.IS_PED_USING_ANY_SCENARIO(player) then
                    notification.stand(players.get_name(pid).."\nIs In A Modded Scenario")
                end
            end 
        end)]]--

        -- WEAPON
        menu.divider(detex_root, Translations.detection_divider_weapon)

        detex_root:toggle_loop(Translations.detection_mod_weapon, {}, Translations.detection_mod_weapon_desc, function()
            for _, pid in ipairs(players.list(true, true, true)) do
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                for i, hash in ipairs(Modded_weapons) do
                    local weapon_hash = util.joaat(hash)
                    local weapon_player_hash = WEAPON.GET_SELECTED_PED_WEAPON(player)
                    --si le joueur possède une arme moddé et (a une arme a la main ou vise avec une arme ou vise avec une arme )
                    --WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX
                    --if WEAPON.HAS_PED_GOT_WEAPON(player, weapon_hash, false) and (WEAPON.IS_PED_ARMED(player, 7) or TASK.GET_IS_TASK_ACTIVE(player, 8) or TASK.GET_IS_TASK_ACTIVE(player, 9)) then
                    if weapon_player_hash == weapon_hash then
                        if Weapon_from_hash(weapon_player_hash) then
                            notification.stand(Translations.detection_mod_weapon_toast1, players.get_name(pid), Weapon_from_hash(weapon_player_hash))
                        else
                            notification.stand(Translations.detection_mod_weapon_toast2, players.get_name(pid), util.reverse_joaat(weapon_player_hash))
                        end
                        break
                    end
                end
            end
        end)

        --[[detex_root:toggle_loop("Weapon In Interior", {}, "", function()
            for _, pid in ipairs(players.list(false, true, true)) do
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                if players.is_in_interior(pid) and WEAPON.IS_PED_ARMED(player, 7) then
                    notification.stand(players.get_name(pid).."\nHas A Weapon In An Interior")
                    break
                end
            end
        end)]]--

        -- VEHICULE
        menu.divider(detex_root, Translations.detection_divider_veh)

        detex_root:toggle_loop(Translations.detection_veh_godmode, {}, Translations.detection_veh_godmode_desc, function()
            for _, pid in ipairs(players.list(false, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                --local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
                local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)
                if PED.IS_PED_IN_ANY_VEHICLE(ped, false) and VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1) ~= 0 then
                    for _, id in ipairs(interior_stuff) do
                        if not ENTITY.GET_ENTITY_CAN_BE_DAMAGED(vehicle) and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(ped) and Get_spawn_state(pid) == 99 and Get_interior_player_is_in(pid) == id then
                            notification.draw_debug_text(Translations.detection_veh_godmode_draw, players.get_name(pid))
                            break
                        end
                    end
                end
            end
        end)

        detex_root:toggle_loop(Translations.detection_unreleased_vehicle, {}, Translations.detection_unreleased_vehicle_desc, function()
            for _, pid in ipairs(players.list(false, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)
                --PED.IS_PED_IN_ANY_VEHICLE(ped, false) return true si le ped est dans un vehicle
                if vehicle ~= 0 then
                    local driver = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1))
                    if driver == pid then
                        local modelHash = players.get_vehicle_model(pid)
                        for i, name in ipairs(Unreleased_vehicles) do
                            if modelHash == util.joaat(name) then
                                notification.stand(Translations.detection_unreleased_vehicle_toats, players.get_name(pid), util.get_label_text(modelHash))
                                --notification.draw_debug_text(Translations.detection_unreleased_vehicle_draw, players.get_name(pid), name)
                            end
                        end
                    end
                end
            end
        end)

        detex_root:toggle_loop(Translations.detection_mod_veh, {}, Translations.detection_mod_veh_desc, function()
            for _, pid in ipairs(players.list(true, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)
                local driver = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1))
                if driver == pid then
                    local modelHash = players.get_vehicle_model(pid)
                    for i, name in ipairs(Modded_vehicles) do
                        if modelHash == util.joaat(name) then
                            if util.get_label_text(modelHash) == "NULL" then
                                notification.stand(Translations.detection_mod_veh_toast, players.get_name(pid), util.reverse_joaat(modelHash))
                            else
                                notification.stand(Translations.detection_mod_veh_toast, players.get_name(pid), util.get_label_text(modelHash))
                            end
                            --notification.draw_debug_text(Translations.detection_mod_veh_draw, players.get_name(pid), name)
                            break
                        end
                    end
                end
            end
        end)

        detex_root:toggle_loop(Translations.detection_super_drive, {}, Translations.detection_super_drive_desc, function()
            for _, pid in ipairs(players.list(false, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)
                local driver = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1))
                if driver == pid then
                    local veh_speed = (ENTITY.GET_ENTITY_SPEED(vehicle)* 3.6)
                    local class = VEHICLE.GET_VEHICLE_CLASS(vehicle)
                    --veh_speed >= 180
                    if class ~= 15 and class ~= 16 and veh_speed >= 245 and (players.get_vehicle_model(pid) ~= util.joaat("oppressor") or players.get_vehicle_model(pid) ~= util.joaat("oppressor2")) then -- not checking opressor mk1 cus its stinky
                        notification.stand(Translations.detection_super_drive_toast, players.get_name(pid))
                        break
                    end
                end
            end
        end)

        -- PLAYER
        menu.divider(detex_root, Translations.detection_divider_player)

        --Ne fonctionne pas ?
        detex_root:toggle_loop(Translations.detection_spectate, {}, Translations.detection_spectate_desc, function()
            for _, pid in ipairs(players.list(false, true, true)) do
                for i, interior in ipairs(interior_stuff) do
                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    if not util.is_session_transition_active() and Get_spawn_state(pid) ~= 0 and Get_interior_player_is_in(pid) == interior
                    and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(ped) and not PED.IS_PED_DEAD_OR_DYING(ped) then
                        if v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), players.get_cam_pos(pid)) < 15.0 and v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), players.get_position(pid)) > 20.0 then
                            notification.stand(Translations.detection_spectate_toast, players.get_name(pid))
                            break
                        end
                    end
                end
            end
        end)

        detex_root:toggle_loop(Translations.detection_watch_you, {}, Translations.detection_watch_you_desc, function()
            for _, pid in ipairs(players.list(false, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                if not PED.IS_PED_DEAD_OR_DYING(ped) then
                    if v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), players.get_cam_pos(pid)) < 15.0 and v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), players.get_position(pid)) > 20.0 then
                        notification.stand(Translations.detection_watch_you_toast, players.get_name(pid))
                        break
                    end
                end
            end
        end)

        detex_root:toggle_loop(Translations.detection_thunder_join, {}, Translations.detection_thunder_join_desc, function()
            for _, pid in ipairs(players.list(false, true, true)) do
                if Get_spawn_state(players.user()) == 0 then return end
                local old_sh = players.get_script_host()
                util.yield(100)
                local new_sh = players.get_script_host()
                if old_sh ~= new_sh then
                    if Get_spawn_state(pid) == 0 and players.get_script_host() == pid then
                        notification.stand(Translations.detection_thunder_join_toast, players.get_name(pid))
                    end
                end
            end
        end)

        -- ORBITAL CANNON
        menu.divider(detex_root, Translations.detection_divider_orbital_cannon)

        detex_root:toggle_loop(Translations.detection_mod_orbital_cannon, {}, Translations.detection_mod_orbital_cannon_desc, function()
            for _, pid in ipairs(players.list(false, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                if IsPlayerUsingOrbitalCannon(pid) and not TASK.GET_IS_TASK_ACTIVE(ped, 135) then
                    notification.stand(Translations.detection_mod_orbital_cannon_toast, players.get_name(pid))
                end
            end
        end)

        detex_root:toggle_loop(Translations.detection_orbital_canon, {}, Translations.detection_orbital_canon_desc, function()
            for _, pid in ipairs(players.list(false, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                if IsPlayerUsingOrbitalCannon(pid) and TASK.GET_IS_TASK_ACTIVE(ped, 135)then
                    notification.draw_debug_text(Translations.detection_orbital_canon_draw, players.get_name(pid))
                end
            end
        end)

        --[[
        JSlang.toggle_loop(_LR['Players'], 'Orbital cannon detection', {'JSorbDetection'}, 'Tells you when anyone starts using the orbital cannon', function()
            local playerList = players.list(false, true, true)
            for i = 1, #playerList do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(playerList[i])
                if TASK.GET_IS_TASK_ACTIVE(ped, 135) and ENTITY.GET_ENTITY_SPEED(ped) == 0 then
                    local pos = NETWORK._NETWORK_GET_PLAYER_COORDS(playerList[i])
                    for j = 1, #orbitalTableCords do
                        if roundDecimals(pos.x, 1) == roundDecimals(orbitalTableCords[j].x, 1) and roundDecimals(pos.y, 1) == roundDecimals(orbitalTableCords[j].y, 1) and roundDecimals(pos.z, 1) == roundDecimals(orbitalTableCords[j].z, 1) then
                            util.toast(players.get_name(playerList[i]) ..' '.. JSlang.str_trans('is using the orbital cannon'))
                        end
                    end
                end
            end
        end)


        menu.toggle_loop(detections, "High-Money", {}, "Detects people with over 600 million", function()
            for _, pid in ipairs(players.list(false, true, true)) do
                if players.get_money(pid) > 600000000 then 
                    util.draw_debug_text(players.get_name(pid) .. " has modded money")
                end
            end
        end)

        menu.toggle_loop(detections, "High-Level", {}, "Detects people over level 4000", function()
            for _, pid in ipairs(players.list(false, true, true)) do
                if players.get_rank(pid) > 4000 then 
                    util.draw_debug_text(players.get_name(pid) .. " has a moddel level")
                end
            end
        end)


        ]]

    --===============--
    -- FIN Détections
    --===============--

    --===============--
    --[[ Protections ]] local protex_root = main_root:list(Translations.protection_root, {}, Translations.protection_root_desc)
    --===============--

        local protections_list = {
            mission = { -- on = 4
                "Online>Protections>Events>Crash Event",
                "Online>Protections>Events>Kick Event",
                "Online>Protections>Events>Modded Event",
                "Online>Protections>Events>Trigger Business Raid",
                "Online>Protections>Events>Start Freemode Mission",
                "Online>Protections>Events>Start Freemode Mission (Not My Boss)",
                "Online>Protections>Events>Teleport To Interior",
                "Online>Protections>Events>Teleport To Interior (Not My Boss)",
                "Online>Protections>Events>Give Collectible",
                "Online>Protections>Events>Give Collectible (Not My Boss)",
                "Online>Protections>Events>CEO/MC Kick",
                "Online>Protections>Events>Infinite Loading Screen",
                "Online>Protections>Events>Infinite Phone Ringing",
                "Online>Protections>Events>Teleport To Cayo Perico",
                "Online>Protections>Events>Cayo Perico Invite",
                "Online>Protections>Events>Apartment Invite",
                "Online>Protections>Events>Send To Cutscene",
                "Online>Protections>Events>Send To Job",
                "Online>Protections>Events>Transaction Error Event",
                "Online>Protections>Events>Vehicle Takeover",
                "Online>Protections>Events>Disable Driving Vehicles",
                "Online>Protections>Events>Kick From Vehicle",
                "Online>Protections>Events>Kick From Interior",
                "Online>Protections>Events>Freeze",
                "Online>Protections>Events>Force Camera Forward",
                "Online>Protections>Events>Love Letter Kick Blocking Event",
                "Online>Protections>Events>Camera Shaking Event",
                "Online>Protections>Events>Explosion Spam",
                "Online>Protections>Events>Ragdoll Event",

                    "Online>Protections>Events>Raw Network Events>Any Event",
                    "Online>Protections>Events>Raw Network Events>Script Event",
                    "Online>Protections>Events>Raw Network Events>OBJECT_ID_FREED_EVENT",
                    "Online>Protections>Events>Raw Network Events>OBJECT_ID_REQUEST_EVENT",
                    "Online>Protections>Events>Raw Network Events>ARRAY_DATA_VERIFY_EVENT",
                    "Online>Protections>Events>Raw Network Events>SCRIPT_ARRAY_DATA_VERIFY_EVENT",
                    "Online>Protections>Events>Raw Network Events>REQUEST_CONTROL_EVENT",
                    "Online>Protections>Events>Raw Network Events>GIVE_CONTROL_EVENT",
                    "Online>Protections>Events>Raw Network Events>WEAPON_DAMAGE_EVENT",
                    "Online>Protections>Events>Raw Network Events>REQUEST_PICKUP_EVENT",
                    "Online>Protections>Events>Raw Network Events>REQUEST_MAP_PICKUP_EVENT",
                    "Online>Protections>Events>Raw Network Events>RESPAWN_PLAYER_PED_EVENT",
                    "Online>Protections>Events>Raw Network Events>Give Weapon Event",
                    "Online>Protections>Events>Raw Network Events>Remove Weapon Event",
                    "Online>Protections>Events>Raw Network Events>Remove All Weapons Event",
                    "Online>Protections>Events>Raw Network Events>VEHICLE_COMPONENT_CONTROL_EVENT",
                    "Online>Protections>Events>Raw Network Events>Fire",
                    "Online>Protections>Events>Raw Network Events>Explosion",
                    "Online>Protections>Events>Raw Network Events>START_PROJECTILE_EVENT",
                    "Online>Protections>Events>Raw Network Events>UPDATE_PROJECTILE_TARGET_EVENT",
                    "Online>Protections>Events>Raw Network Events>BREAK_PROJECTILE_TARGET_LOCK_EVENT",
                    "Online>Protections>Events>Raw Network Events>REMOVE_PROJECTILE_ENTITY_EVENT",
                    "Online>Protections>Events>Raw Network Events>ALTER_WANTED_LEVEL_EVENT",
                    "Online>Protections>Events>Raw Network Events>CHANGE_RADIO_STATION_EVENT",
                    "Online>Protections>Events>Raw Network Events>RAGDOLL_REQUEST_EVENT",
                    "Online>Protections>Events>Raw Network Events>PLAYER_TAUNT_EVENT",
                    "Online>Protections>Events>Raw Network Events>PLAYER_CARD_STAT_EVENT",
                    "Online>Protections>Events>Raw Network Events>DOOR_BREAK_EVENT",
                    "Online>Protections>Events>Raw Network Events>REMOTE_SCRIPT_INFO_EVENT",
                    "Online>Protections>Events>Raw Network Events>REMOTE_SCRIPT_LEAVE_EVENT",
                    "Online>Protections>Events>Raw Network Events>MARK_AS_NO_LONGER_NEEDED_EVENT",
                    "Online>Protections>Events>Raw Network Events>CONVERT_TO_SCRIPT_ENTITY_EVENT",
                    "Online>Protections>Events>Raw Network Events>SCRIPT_WORLD_STATE_EVENT",
                    "Online>Protections>Events>Raw Network Events>INCIDENT_ENTITY_EVENT",
                    "Online>Protections>Events>Raw Network Events>CLEAR_AREA_EVENT",
                    "Online>Protections>Events>Raw Network Events>CLEAR_RECTANGLE_AREA_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_REQUEST_SYNCED_SCENE_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_START_SYNCED_SCENE_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_UPDATE_SYNCED_SCENE_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_STOP_SYNCED_SCENE_EVENT",
                    "Online>Protections>Events>Raw Network Events>GIVE_PED_SCRIPTED_TASK_EVENT",
                    "Online>Protections>Events>Raw Network Events>GIVE_PED_SEQUENCE_TASK_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_CLEAR_PED_TASKS_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_START_PED_ARREST_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_START_PED_UNCUFF_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_SOUND_CAR_HORN_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_ENTITY_AREA_STATUS_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_GARAGE_OCCUPIED_STATUS_EVENT",
                    "Online>Protections>Events>Raw Network Events>PED_CONVERSATION_LINE_EVENT",
                    "Online>Protections>Events>Raw Network Events>SCRIPT_ENTITY_STATE_CHANGE_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_PLAY_SOUND_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_STOP_SOUND_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_PLAY_AIRDEFENSE_FIRE_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_BANK_REQUEST_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_AUDIO_BARK_EVENT",
                    "Online>Protections>Events>Raw Network Events>REQUEST_DOOR_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_TRAIN_REQUEST_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_TRAIN_REPORT_EVENT",
                    "Online>Protections>Events>Raw Network Events>MODIFY_VEHICLE_LOCK_WORD_STATE_DATA",
                    "Online>Protections>Events>Raw Network Events>MODIFY_PTFX_WORD_STATE_DATA_SCRIPTED_EVOLVE_EVENT",
                    "Online>Protections>Events>Raw Network Events>REQUEST_PHONE_EXPLOSION_EVENT",
                    "Online>Protections>Events>Raw Network Events>REQUEST_DETACHMENT_EVENT",
                    "Online>Protections>Events>Raw Network Events>KICK_VOTES_EVENT",
                    "Online>Protections>Events>Raw Network Events>GIVE_PICKUP_REWARDS_EVENT",
                    --"Online>Protections>Events>Raw Network Events>NETWORK_CRC_HASH_CHECK_EVENT",
                    "Online>Protections>Events>Raw Network Events>BLOW_UP_VEHICLE_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_SPECIAL_FIRE_EQUIPPED_WEAPON",
                    "Online>Protections>Events>Raw Network Events>NETWORK_RESPONDED_TO_THREAT_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_SHOUT_TARGET_POSITION",
                    "Online>Protections>Events>Raw Network Events>VOICE_DRIVEN_MOUTH_MOVEMENT_FINISHED_EVENT",
                    "Online>Protections>Events>Raw Network Events>PICKUP_DESTROYED_EVENT",
                    "Online>Protections>Events>Raw Network Events>UPDATE_PLAYER_SCARS_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_CHECK_EXE_SIZE_EVENT",
                    "Online>Protections>Events>Raw Network Events>PTFX",
                    "Online>Protections>Events>Raw Network Events>NETWORK_PED_SEEN_DEAD_PED_EVENT",
                    "Online>Protections>Events>Raw Network Events>REMOVE_STICKY_BOMB_EVENT",
                    --"Online>Protections>Events>Raw Network Events>NETWORK_CHECK_CODE_CRCS_EVENT",
                    "Online>Protections>Events>Raw Network Events>INFORM_SILENCED_GUNSHOT_EVENT",
                    "Online>Protections>Events>Raw Network Events>PED_PLAY_PAIN_EVENT",
                    "Online>Protections>Events>Raw Network Events>CACHE_PLAYER_HEAD_BLEND_DATA_EVENT",
                    "Online>Protections>Events>Raw Network Events>REMOVE_PED_FROM_PEDGROUP_EVENT",
                    --"Online>Protections>Events>Raw Network Events>REPORT_MYSELF_EVENT",
                    "Online>Protections>Events>Raw Network Events>REPORT_CASH_SPAWN_EVENT",
                    "Online>Protections>Events>Raw Network Events>ACTIVATE_VEHICLE_SPECIAL_ABILITY_EVENT",
                    "Online>Protections>Events>Raw Network Events>BLOCK_WEAPON_SELECTION",
                    "Online>Protections>Events>Raw Network Events>NETWORK_CHECK_CATALOG_CRC",

                "Online>Protections>Detections>Spoofed Host Token (Aggressive)",
                "Online>Protections>Detections>Spoofed Host Token (Sweet Spot)",
                "Online>Protections>Detections>Spoofed Host Token (Handicap)",
                "Online>Protections>Detections>Spoofed Host Token (Other)",

                "Online>Protections>Syncs>World Object Sync",
                "Online>Protections>Syncs>Invalid Model Sync",
                    "Online>Protections>Syncs>Incoming>Any Incoming Sync",
                    "Online>Protections>Syncs>Incoming>Clone Create",
                    "Online>Protections>Syncs>Incoming>Clone Update",
                    "Online>Protections>Syncs>Incoming>Clone Delete",
                    "Online>Protections>Syncs>Incoming>Acknowledge Clone Create",
                    "Online>Protections>Syncs>Incoming>Acknowledge Clone Update",
                    "Online>Protections>Syncs>Incoming>Acknowledge Clone Delete",

                    "Online>Protections>Syncs>Outgoing>Clone Create",
                    "Online>Protections>Syncs>Outgoing>Clone Update",
                    "Online>Protections>Syncs>Outgoing>Clone Delete",

                "Online>Protections>Text Messages>Any Message",
                "Online>Protections>Text Messages>Advertisement",
                "Online>Protections>Text Messages>Bypassed Message Filter",

                "Online>Protections>Session Script Start>Any Script",
                "Online>Protections>Session Script Start>Uncategorised",
                "Online>Protections>Session Script Start>Freemode Activity",
                "Online>Protections>Session Script Start>Arcade Game",
                "Online>Protections>Session Script Start>Removed Freemode Activity",
                "Online>Protections>Session Script Start>Session Breaking",
                "Online>Protections>Session Script Start>Service",
                "Online>Protections>Session Script Start>Open Interaction Menu",
                "Online>Protections>Session Script Start>Flight School",
                "Online>Protections>Session Script Start>Lightning Strike For Random Player",
                "Online>Protections>Session Script Start>Disable Passive Mode",
                "Online>Protections>Session Script Start>Darts",
                "Online>Protections>Session Script Start>Impromptu Deathmatch",
                "Online>Protections>Session Script Start>Slasher",
                "Online>Protections>Session Script Start>Cutscene",

                "Online>Protections>Pickups>Any Pickup Collected",
                "Online>Protections>Pickups>Cash Pickup Collected",
                "Online>Protections>Pickups>RP Pickup Collected",
                "Online>Protections>Pickups>Invalid Pickup Collected",

                --"Online>Protections>Block Blaming",

                --"Online>Protections>Script Error Recovery",
            }
        }

        local protections_value = {mission = {}}

        protex_root:toggle(Translations.protection_mission, {}, Translations.protection_mission_desc, function(on)
            for _, path in pairs(protections_list.mission) do
                if on then
                    protections_value.mission[path..">Block"] = menu.ref_by_path(path..">Block", Tree_V).value
                    menu.ref_by_path(path..">Block", Tree_V):applyDefaultState()
                    --print(path .. ">Block : " .. protections_value.mission[path..">Block"])
                elseif menu.ref_by_path(path..">Block", Tree_V).value == menu.ref_by_path(path..">Block", Tree_V):getDefaultState() then
                    SetPathVal(path..">Block", protections_value.mission[path..">Block"])
                end
            end
        end)

        -------------------
        --- ANTI-AGRESSEURS
        -------------------
        local anti_muggers_root = protex_root:list(Translations.protection_anti_mugger_root, {}, Translations.protection_anti_mugger_root_desc)

            --MYSELF
            local anti_muggers_myself_root = anti_muggers_root:list(Translations.protection_anti_mugger_myself_root, {}, Translations.protection_anti_mugger_myself_root_desc)

                anti_muggers_myself_root:toggle_loop(Translations.protection_anti_mugger_myself_active, {}, Translations.protection_anti_mugger_myself_active_desc, function() -- thx nowiry for improving my method :D
                    if NETWORK.NETWORK_IS_SCRIPT_ACTIVE("am_gang_call", 0, true, 0) then
                        local ped_netId = memory.script_local("am_gang_call", 63 + 10 + (0 * 7 + 1))
                        local sender = memory.script_local("am_gang_call", 287)
                        local target = memory.script_local("am_gang_call", 288)
                        local player = players.user()

                        util.spoof_script("am_gang_call", function()
                            if (memory.read_int(sender) ~= player and memory.read_int(target) == player 
                            and NETWORK.NETWORK_DOES_NETWORK_ID_EXIST(memory.read_int(ped_netId)) 
                            and NETWORK.NETWORK_REQUEST_CONTROL_OF_NETWORK_ID(memory.read_int(ped_netId))) then
                                if anti_muggers_options["myself"]["block"] then
                                    local mugger = NETWORK.NET_TO_PED(memory.read_int(ped_netId))
                                    entities.delete_by_handle(mugger)
                                    if anti_muggers_options["myself"]["notif"] then
                                        notification.stand(Translations.protection_anti_mugger_myself_active_toast1, players.get_name(memory.read_int(sender)))
                                    end
                                else
                                    notification.stand(Translations.protection_anti_mugger_myself_active_toast2, players.get_name(memory.read_int(sender)))
                                end
                            end
                        end)
                    end
                end)

                --OPTIONS
                menu.divider(anti_muggers_myself_root, Translations.protection_anti_mugger_divider_options)

                anti_muggers_myself_root:toggle(Translations.protection_anti_mugger_options_block, {}, "", function (on)
                    anti_muggers_options["myself"]["block"] = on
                end)

                anti_muggers_myself_root:toggle(Translations.protection_anti_mugger_options_notif, {}, "", function (on)
                    anti_muggers_options["myself"]["notif"] = on
                end, true)

            --SOMEONE ELSE
            local anti_muggers_someone_else_root = anti_muggers_root:list(Translations.protection_anti_mugger_someone_else_root, {}, Translations.protection_anti_mugger_someone_else_root_desc)

                anti_muggers_someone_else_root:toggle_loop(Translations.protection_anti_mugger_someone_else_active, {}, Translations.protection_anti_mugger_someone_else_active_desc, function()
                    if NETWORK.NETWORK_IS_SCRIPT_ACTIVE("am_gang_call", 0, true, 0) then
                        local ped_netId = memory.script_local("am_gang_call", 63 + 10 + (0 * 7 + 1))
                        local sender = memory.script_local("am_gang_call", 287)
                        local target = memory.script_local("am_gang_call", 288)
                        local player = players.user()

                        util.spoof_script("am_gang_call", function()
                            if memory.read_int(target) ~= player and memory.read_int(sender) ~= player
                            and NETWORK.NETWORK_DOES_NETWORK_ID_EXIST(memory.read_int(ped_netId)) 
                            and NETWORK.NETWORK_REQUEST_CONTROL_OF_NETWORK_ID(memory.read_int(ped_netId)) then
                                if anti_muggers_options["someone_else"]["block"] then
                                    local mugger = NETWORK.NET_TO_PED(memory.read_int(ped_netId))
                                    entities.delete_by_handle(mugger)
                                    if anti_muggers_options["someone_else"]["notif"] then
                                        notification.stand(Translations.protection_anti_mugger_someone_else_active_toast1, players.get_name(memory.read_int(sender)), players.get_name(memory.read_int(target)))
                                    end
                                else
                                    notification.stand(Translations.protection_anti_mugger_someone_else_active_toast2, players.get_name(memory.read_int(sender)), players.get_name(memory.read_int(target)))
                                end
                            end
                        end)
                    end
                end)

                --OPTIONS
                menu.divider(anti_muggers_someone_else_root, Translations.protection_anti_mugger_divider_options)

                anti_muggers_someone_else_root:toggle(Translations.protection_anti_mugger_options_block, {}, "", function (on)
                    anti_muggers_options["someone_else"]["block"] = on
                end)

                anti_muggers_someone_else_root:toggle(Translations.protection_anti_mugger_options_notif, {}, "", function (on)
                    anti_muggers_options["someone_else"]["notif"] = on
                end, true)

        --- FIN ANTI-AGRESSEURS

        ------------------
        --- ANTI-VEHICULES
        ------------------
        local anti_vehicles_root = protex_root:list(Translations.protection_anti_veh_root, {}, Translations.protection_anti_veh_root_desc)

            anti_vehicles_root:toggle_loop(Translations.protection_anti_vehicles_active, {}, Translations.protection_anti_vehicles_active_desc, function ()

                local vehall = entities.get_all_vehicles_as_handles()
                for k, vid in pairs(vehall) do
                    local veh = ENTITY.GET_VEHICLE_INDEX_FROM_ENTITY_INDEX(vid)
                    local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1)
                    if PED.IS_PED_A_PLAYER(ped) then
                        local pid = PED.GET_PLAYER_PED_IS_FOLLOWING(ped)
                        if pid != players.user() then
                            local hash = ENTITY.GET_ENTITY_MODEL(vid)
                            if Anti_vehicles_list[hash] and Request_control(veh, 1000) then
                                if VEHICLE.GET_VEHICLE_ENGINE_HEALTH(veh) > -4000 then
                                    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(veh, -4000)
                                    VEHICLE.SET_VEHICLE_ENGINE_ON(veh, false, true, true)
                                    VEHICLE.BRING_VEHICLE_TO_HALT(veh, 100.0, 1)
                                    VEHICLE.SET_HELI_BLADES_SPEED(veh, 0.0)
                                    if anti_vehicles_options["notif"] and not anti_vehicles_options["remove"] then
                                        notification.stand(Translations.protection_anti_vehicles_active_toast2, util.reverse_joaat(hash))
                                    end
                                end
                                if anti_vehicles_options["remove"] then
                                    entities.delete_by_handle(veh)
                                    if anti_vehicles_options["notif"] then
                                        notification.stand(Translations.protection_anti_vehicles_active_toast1, util.reverse_joaat(hash))
                                    end
                                end
                            end
                        end
                    end
                end
                util.yield(10)
            end)

            --MANAGE
            menu.divider(anti_vehicles_root, Translations.protection_anti_vehicles_divider_manage)

            anti_vehicles_root:text_input(Translations.protection_anti_vehicles_model, {"nyantivehicleadd"}, Translations.protection_anti_vehicles_model_desc, function(on_input)
                if anti_vehicles_model ~= on_input then
                    if on_input ~= nil then
                        local i = util.joaat(on_input)
                        if Anti_vehicles_list[i] then
                            -- util.get_label_text(modelHash)
                            notification.stand(Translations.protection_anti_vehicles_model_toast1)
                        elseif VEHICLE.GET_VEHICLE_CLASS_FROM_NAME(i) ~= 0 then
                            Anti_vehicles_list[i] = on_input
                            notification.stand(Translations.protection_anti_vehicles_model_toast2)
                        else
                            notification.stand(Translations.protection_anti_vehicles_model_toast3)
                        end
                    else
                        notification.stand(Translations.protection_anti_vehicles_model_toast4)
                    end
                    anti_vehicles_model = on_input
                end
            end, '')

            anti_vehicles_root:action(Translations.protection_anti_vehicles_save, {}, Translations.protection_anti_vehicles_save_desc, function()
                --sauvegarde de la liste
                local filehandle = io.open(anti_vehicles_file, "w")
                if filehandle then
                    filehandle:write(Json.encode(Anti_vehicles_list))
                    filehandle:flush()
                    filehandle:close()
                end
            end)

            Menus.vehlist = anti_vehicles_root:list(Translations.protection_anti_vehicles_list, {}, Translations.protection_anti_vehicles_list_desc, function()
                Build_vehicles_list()
            end)

            --OPTIONS
            menu.divider(anti_vehicles_root, Translations.protection_anti_vehicles_divider_options)

            anti_vehicles_root:toggle(Translations.protection_anti_vehicles_delete, {}, Translations.protection_anti_vehicles_delete_desc, function (on)
                anti_vehicles_options["remove"] = on
            end)

            anti_vehicles_root:toggle(Translations.protection_anti_vehicles_notif, {}, Translations.protection_anti_vehicles_notif_desc, function (on)
                anti_vehicles_options["notif"] = on
            end,true)

            anti_vehicles_root:action("test", {}, "", function ()
                local vehall = entities.get_all_vehicles_as_handles()
                for k, vid in pairs(vehall) do
                    local veh = ENTITY.GET_VEHICLE_INDEX_FROM_ENTITY_INDEX(vid)
                    local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1)
                    if PED.IS_PED_A_PLAYER(ped) then
                        local pid = PED.GET_PLAYER_PED_IS_FOLLOWING(ped)
                        if pid != players.user() then
                            local hash = ENTITY.GET_ENTITY_MODEL(vid)
                            if Anti_vehicles_list[hash] and Request_control(veh, 1000) then
                                notification.stand("test"..k..": "..VEHICLE.GET_VEHICLE_ENGINE_HEALTH(veh))
                                local pos = ENTITY.GET_ENTITY_COORDS(pid)
                                HUD.SET_NEW_WAYPOINT(pos.x, pos.y)
                                --VEHICLE.SET_VEHICLE_ENGINE_ON(veh, false, true, true)
                            end
                        end
                    end
                end
            end)
        --- FIN ANTI-VEHICULES

    --===============--
    -- FIN Protections
    --===============--

    --===============--
    --[[ Misc ]] local misc_root = main_root:list("Misc")
    --===============--

        local testnotif_root = misc_root:list("testnotif")
            testnotif_root:action("help",{},"", function ()
                notification:help("format0" .. ".\n" .. "format1" .. '.', HudColour.red)
            end)
            testnotif_root:toggle_loop("normal",{},"", function ()
                --notification:normal(name_script.." ~q~est ~u~le ~o~meilleur script!")
                notification.draw_debug_text("un petit %s du script", "test")
            end)
            testnotif_root:action("stand",{},"", function ()
                notification.stand("un petit %s du script", "test")
            end)

        misc_root:slider("Change seat", {}, "DriverSeat = -1 Passenger = 0 Left Rear = 1 RightRear = 2", -1, 2, -1, 1, function(seatnumber)
            local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
            local vehicle = entities.get_user_vehicle_as_handle()
            --PED.SET_PED_INTO_VEHICLE(ped, vehicle, seatnumber)
            PED.SET_PED_INTO_VEHICLE(ped, vehicle, -2)
        end)

        misc_root:toggle_loop("Unlock Vehicle that you try to get into", {"unlockvehget"}, "Unlocks a vehicle that you try to get into. This will work on locked player cars.", function ()
            ::start::
            local localPed = players.user_ped()
            --obtenir le véhicule où le ped essaie d'entrer
            local veh = PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(localPed)
            --Obtient une valeur indiquant si le ped spécifié se trouve dans un véhicule. Si le 2ème argument est faux, la fonction ne retournera pas vrai jusqu'à ce que le ped soit assis dans le véhicule et soit sur le point de fermer la porte.
            if PED.IS_PED_IN_ANY_VEHICLE(localPed, false) then
                --Obtient le véhicule dans lequel se trouve le piéton spécifié. Renvoie 0 si le piéton est/n'était pas dans un véhicule. True recupère le dernier vehicle.
                local v = PED.GET_VEHICLE_PED_IS_IN(localPed, false)
                --VERROUILLER LES PORTES DU VÉHICULE {VEHICLELOCK_NONE, VEHICLELOCK_UNLOCKED, VEHICLELOCK_LOCKED, VEHICLELOCK_LOCKOUT_PLAYER_ONLY, VEHICLELOCK_LOCKED_PLAYER_INSIDE, VEHICLELOCK_LOCKED_INITIALLY, VEHICLELOCK_FORCE_SHUT_DOORS, VEHICLELOCK_LOCKED_BUT_CAN_BE_DAMAGED, VEHICLELOCK_LOCKED_BUT_BOOT_UNLOCKED, VEHICLELOCK_LOCKED_NO_PASSENGERS, VEHICLELOCK_CANNOT_ENTER}
                VEHICLE.SET_VEHICLE_DOORS_LOCKED(v, 0)
                --DÉFINIR LES PORTES DU VÉHICULE VERROUILLÉES POUR TOUS LES JOUEURS
                --VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(v, false)
                --DÉFINIR LES PORTES DU VÉHICULE VERROUILLÉES POUR LE JOUEUR
                --VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_PLAYER(v, players.user(), false)
                --VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(veh, false)
                util.yield()
            else
                if veh ~= 0 then
                    --RÉSEAU DEMANDE DE CONTRÔLE DE L'ENTITÉ
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
                    --LE RÉSEAU A PAS LE CONTRÔLE DE L'ENTITÉ
                    if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) then
                        for i = 1, 20 do
                            --RÉSEAU DEMANDE DE CONTRÔLE DE L'ENTITÉ
                            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
                            util.yield(100)
                        end
                    end
                    --LE RÉSEAU A PAS LE CONTRÔLE DE L'ENTITÉ
                    if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) then
                        notification.stand("Waited 2 secs, couldn't get control!")
                        goto start
                    else
                        --if SE_Notifications then
                            notification.stand("Has control.")
                        --end
                    end
                    VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 0)
                    --VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(veh, false)
                    --VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_PLAYER(veh, players.user(), false)
                    --DÉFINIR LE VÉHICULE APPARTIENT AU JOUEUR
                    --VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(veh, false)
                end
            end
        end)

        misc_root:toggle_loop("Turn Car On Instantly", {"turnvehonget"}, "Turns the car engine on instantly when you get into it, so you don't have to wait.", function ()
            local localped = players.user_ped()
            if PED.IS_PED_GETTING_INTO_A_VEHICLE(localped) then
                local veh = PED.GET_VEHICLE_PED_IS_ENTERING(localped)
                if not VEHICLE.GET_IS_VEHICLE_ENGINE_RUNNING(veh) then
                    VEHICLE.SET_VEHICLE_FIXED(veh)
                    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(veh, 1000)
                    VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, false)
                end
                if VEHICLE.GET_VEHICLE_CLASS(veh) == 15 then --15 is heli
                    VEHICLE.SET_HELI_BLADES_FULL_SPEED(veh)
                end
            end
        end)
--[[
        menu.slider(miscwindmenu, WIND_SPEED, {"windspeed"}, WIND_SPEED_DESC, -1, 12, -1, 1, function(s)
        	MISC.SET_WIND_SPEED(s)
        end)
        menu.slider(miscwindmenu, WIND_DIRECTION, {"winddir"}, WIND_DIRECTION_DESC, -1, 360, -1, 1, function(s)
        	MISC.SET_WIND_DIRECTION(s)
        end)

        menu.slider(miscrainmenu, RAIN_LEVEL, {"rainlevel"}, RAIN_LEVEL_DESC, -1, 10, -1, 1, function(s)
        	sf = s/10
        	MISC.SET_RAIN(sf)
        end)
        menu.slider(miscrainmenu, SNOW_LEVEL, {"snowlevel"}, SNOW_LEVEL_DESC, -1, 10, -1, 1, function(s)
        	sf = s/10
        	MISC.SET_SNOW(sf)
        end)

        menu.toggle_loop(miscmenu, FORCE_VISIBLE, {}, "", function()
            for _, player in ipairs(players.list(false, true, true)) do
                ENTITY.SET_ENTITY_VISIBLE(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player), true, false)
            end
        end)

]]
        --[[ NE FONCTIONNE PAS
        misc_root:toggle_loop('Increase Kosatka Missile Range', {'nykrange'}, 'You can use it anywhere in the map now', function ()
            if util.is_session_started() then
                memory.write_float(memory.script_global(262145 + 30176), 200000.0)
            end
        end)
        ]]--


        --consistent freeze clock
        --[[local function read_time(file_path)
            local filehandle = io.open(file_path, "r")
            if filehandle then
                local time = filehandle:read()
                filehandle:close()
                return tostring(time)
            else
                return false
            end
        end

        local function save_current_time(file_path, time)
            filehandle = io.open(file_path, "w")
            filehandle:write(time)
            filehandle:flush()
            filehandle:close()
        end

        local function get_clock()
            return tostring(CLOCK.GET_CLOCK_HOURS() .. ":" .. CLOCK.GET_CLOCK_MINUTES() .. ":".. CLOCK.GET_CLOCK_SECONDS())
        end

        local time_path = filesystem.store_dir() .. "AndyScript\\time.txt"
        local is_freeze_clock_on = false
        misc_root:toggle("Consistent Freeze Clock", {}, "Freezes the clock using Stand's function, then saves the time for next execution. Change the current time using the \"time\" command, or in \"World > Atmosphere > Clock > Time\".",
        function(state)
            is_freeze_clock_on = state
            if state then
                if filesystem.exists(time_path) then
                    local time = read_time(time_path)
                    menu.trigger_command(menu.ref_by_path("World>Atmosphere>Clock>Time", Tree_V), time)
                else
                    save_current_time(time_path, get_clock())
                end
            else
                menu.trigger_command(menu.ref_by_path("World>Atmosphere>Clock>Lock Time", Tree_V), "false")
            end
            while is_freeze_clock_on do
                menu.trigger_command(menu.ref_by_path("World>Atmosphere>Clock>Lock Time", Tree_V), "true")
                save_current_time(time_path, get_clock())
                util.yield(1000)
            end
        end)
        -- end of freeze clock
        ]]--
    --===============--
    -- FIN Misc
    --===============--

    --===============--
    --[[ PARAMETRES ]] local settings_root = main_root:list("Paramètres")
    --===============--

        settings_root:list_action("Langue", {}, "", just_language_files, function(index, value, click_type)
            local file = io.open(selected_lang_path, 'w')
            if file then
                file:write(value)
                file:close()
            end
            util.restart_script()
        end, selected_language)
    --[[ 
        settings_root:toggle("debug", "debug", {}, "", function(on)
            ls_debug = on
        end)

        -- check online version
        local online_v = tonumber(NETWORK.GET_ONLINE_VERSION())
        if online_v > ocoded_for and outdated_notif then
            notify(translations.outdated_script_1 .. online_v .. translations.outdated_script_2 .. ocoded_for .. translations.outdated_script_3)
        end
    ]]--

    --LanceScript by lance#8213
    --WiriScript by Nowiry#2663
    --fun_menu esay_enter :Arrêtez le véhicule dans lequel vous essayez de monter
    --fun_menu Anti carjacking
        -- CREDITS
        local settings_credits_root = settings_root:list("Credits", {}, "")

            settings_credits_root:readonly("LanceScript", "Aimbot")
            settings_credits_root:readonly("LanceScript", "Translation")
            settings_credits_root:readonly("WiriScript", "Anti-mugger")
            settings_credits_root:readonly("WiriScript", "Notification")
            settings_credits_root:readonly("Hexarobi", "Auto-Update")
            settings_credits_root:readonly("AndyScript", "Auto-flip")
            --settings_credits_root:action("Ayim#7708", {}, "", function() end)

--===============--
-- FIN Main
--===============--

util.log(name_script.." loaded in %d millis", util.current_time_millis() - scriptStartTime)