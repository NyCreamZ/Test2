local version = "10"
util.keep_running() --ceci fait que le script ne s'arrête pas après avoir fait son travail

--===============--
-- Core Functions
--===============--

local Commands = menu.trigger_commands
local GetOn = function(on) if on then return "on" else return "off" end end
local InSession = function() return util.is_session_started() and not util.is_session_transition_active() end
local GetPathVal = function(path) return menu.get_value(menu.ref_by_path(path)) end
local SetPathVal = function(path,state) local path_ref = menu.ref_by_path(path) if menu.is_ref_valid(path_ref) then menu.set_value(path_ref,state) end end
local ClickPath = function(path) local path_ref = menu.ref_by_path(path) if menu.is_ref_valid(path_ref) then menu.trigger_command(path_ref) end end
local Notify = function(str) if notifications_enabled or update_available then if notifications_mode == 2 then util.show_corner_help("~p~mehScript~s~~n~"..str ) else util.toast("= mehScript =\n"..str) end end end

--===============--
-- Translation
--===============--

    user_lang = lang.get_current()
    local en_table = {"en","en-us"}
    local english
    local supported_lang
    for _,lang in pairs(en_table) do
        if user_lang == lang then
            english = true
            supported_lang = true
            break
        end
    end

    if not supported_lang then
        local SupportedLang = function()
            local supported_lang_table = {"fr"}
            for _,tested_lang in pairs(supported_lang_table) do
                if tested_lang == user_lang then
                    supported_lang = true
                    return
                end
            end
            english = true
            util.toast("= test =\nSorry your language isn't supported. Script language set to English.")
        end

        SupportedLang()
    end

    local translation_table = {
        fr = {
            ["Self"] = "Soi",
            ["Detections"] = "Détections",

            ["Immortality"] = "Invunérable",
            ["Auto Heal"] = "Guérison Auto",
            ["Collision"] = "Collision",
            ["Drowning"] = "Noyade",
            ["Steam"] = "Vapeur",
            ["Bullets"] = "Balle",
            ["Melee"] = "Mêlée",
            ["Explosions"] = "Explosions",
            ["Fire"] = "Feu",

            ['GOD'] = "DIEU",

            
            ["Version"] = "Version",
            ["available.\nPress Update to get it."] = "disponible.\nAppui sur Mettre à jour pour l'obtenir.",
            ["Update to"] = "Mettre à Jour vers",
            ["Script failed to download. Please try again later. If this continues to happen then manually update via github."] = "Téléchargement échoué. Réessayez plus tard. Si cela continu d'arriver,mettez à jour via le github.",
            
        }
    }

    local Translate = function(str)
        if english then
            return str
        else
            local translated_str = translation_table[user_lang][str]
            if translated_str == nil or translated_str == "" then
                return "* "..str
            end
            return translated_str
        end
    end

--===============--
-- Roots
--===============--

local main = menu.my_root()
local self = main:list(Translate("Self"))
local detex = main.list(Translate("Detections"))
--[[local vehicle = main:list(Translate("Vehicle"))
local online = main:list(Translate("Online"))
local game = main:list(Translate("Game"))
local stand = main:list("Stand")
local misc = main:list(Translate("Misc"))
]]--

--===============--
-- Update
--===============--

    local update_available
    async_http.init("raw.githubusercontent.com","/NyCreamZ/test2/main/version",function(output)
        if tonumber(version) < tonumber(output) then
            update_available = true
            Notify(Translate("Version").." "..string.gsub(output,"\n","",1).." "..Translate("available.\nPress Update to get it."))
            update_button = menu.action(menu.my_root(),Translate("Update to").." "..output,{},"",function()
                async_http.init('raw.githubusercontent.com','/NyCreamZ/test2/main/test2.lua',function(a)
                    if select(2,load(a)) then
                        Notify(Translate("Script failed to download. Please try again later. If this continues to happen then manually update via github."))
                        return
                    end
                    local f = io.open(filesystem.scripts_dir()..SCRIPT_RELPATH,"wb")
                    f:write(a)
                    f:close()
                    util.restart_script()
                end)
                async_http.dispatch()
            end)
            menu.attach_before(self,menu.detach(update_button))
        elseif tonumber(version)>tonumber(output) then
            dev_build = main:divider("Dev Build",{},"",function() end)
            menu.attach_before(self,menu.detach(dev_build))
        end
    end)
    async_http.dispatch()

--===============--
-- Main
--===============--

    --local add_block_join_reaction = true
    local stand_edition = menu.get_edition()
    local lua_path = "Stand>Lua Scripts>"..string.gsub(string.gsub(SCRIPT_RELPATH,".lua",""),"\\",">")

    --===============--
    -- Self
    --===============--
        --lua_path..">"..Translate("Self")..">"..Translate("Auto Armor after Death"),

        --Self
        local immortality_command = menu.ref_by_path('Self>Immortality')
        local immortality = menu.get_value(immortality_command)

        local autoHeal_command = menu.ref_by_path('Self>Auto Heal')
        local autoHeal = menu.get_value(autoHeal_command)

        local gracefulness_command = menu.ref_by_path('Self>Gracefulness')
        local gracefulness = menu.get_value(gracefulness_command)

        local gluedToSeats_command = menu.ref_by_path('Self>Glued To Seats')
        local gluedToSeats = menu.get_value(gluedToSeats_command)

        local lockWantedLevel_command = menu.ref_by_path('Self>Lock Wanted Level')
        local lockWantedLevel = menu.get_value(lockWantedLevel_command)

        local infiniteStamina_command = menu.ref_by_path('Self>Infinite Stamina')
        local infiniteStamina = menu.get_value(infiniteStamina_command)

        --Stand>Lua Scripts>JinxScript
        local collision_command = menu.ref_by_path('Stand>Lua Scripts>JinxScript>Self>Invulnerabilities>Collision')
        local drowning_command = menu.ref_by_path('Stand>Lua Scripts>JinxScript>Self>Invulnerabilities>Drowning')
        local steam_command = menu.ref_by_path('Stand>Lua Scripts>JinxScript>Self>Invulnerabilities>Steam')
        local bullets_command = menu.ref_by_path('Stand>Lua Scripts>JinxScript>Self>Invulnerabilities>Bullets')
        local melee_command = menu.ref_by_path('Stand>Lua Scripts>JinxScript>Self>Invulnerabilities>Melee')
        local explosions_command = menu.ref_by_path('Stand>Lua Scripts>JinxScript>Self>Invulnerabilities>Explosions')
        local fire_command = menu.ref_by_path('Stand>Lua Scripts>JinxScript>Self>Invulnerabilities>Fire')

        self:toggle(Translate("GOD"),{},Translate("Immortality")..", "..Translate("Collision")..", "..Translate("Drowning")..", "..Translate("Steam")..", "..Translate("Bullets")..", "..Translate("Melee")..", "..Translate("Explosions")..", "..Translate("Fire"),function(on)
            
            if on then

                immortality = menu.get_value(immortality_command)
                autoHeal = menu.get_value(autoHeal_command)
                gracefulness = menu.get_value(gracefulness_command)
                gluedToSeats = menu.get_value(gluedToSeats_command)
                lockWantedLevel = menu.get_value(lockWantedLevel_command)
                infiniteStamina = menu.get_value(infiniteStamina_command)

                menu.trigger_command(immortality_command, "on")
                menu.trigger_command(autoHeal_command, "on")
                menu.trigger_command(gracefulness_command, "on")
                menu.trigger_command(gluedToSeats_command, "on")
                menu.trigger_command(lockWantedLevel_command, "on")
                menu.trigger_command(infiniteStamina_command, "on")

                menu.trigger_command(collision_command, "on")
                menu.trigger_command(drowning_command, "on")
                menu.trigger_command(steam_command, "on")
                menu.trigger_command(bullets_command, "on")
                menu.trigger_command(melee_command, "on")
                menu.trigger_command(explosions_command, "on")
                menu.trigger_command(fire_command, "on")

            else
                if not immortality then
                    menu.trigger_command(immortality_command, "off")
                end
                if not autoHeal then
                    menu.trigger_command(autoHeal_command, "off")
                end
                if not gracefulness then
                    menu.trigger_command(gracefulness_command, "off")
                end
                if not gluedToSeats then
                    menu.trigger_command(gluedToSeats_command, "off")
                end
                if not lockWantedLevel then
                    menu.trigger_command(lockWantedLevel_command, "off")
                end
                if not infiniteStamina then
                    menu.trigger_command(infiniteStamina_command, "off")
                end

                menu.trigger_command(collision_command, "off")
                menu.trigger_command(drowning_command, "off")
                menu.trigger_command(steam_command, "off")
                menu.trigger_command(bullets_command, "off")
                menu.trigger_command(melee_command, "off")
                menu.trigger_command(explosions_command, "off")
                menu.trigger_command(fire_command, "off")


            end
            
        end)