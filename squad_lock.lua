local module = {}

module.position_to_name = {
    [1] = {
        [0] = "Random Squad",
        [1] = "Custom Squad",
        [2] = "Rift Walkers",
        [3] = "Rusting Hulks",
        [4] = "Zenith Guard",
        [5] = "Blitzkrieg",
        [6] = "Steel Judoka",
        [7] = "Flame Behemoths",
    },
    [2] = {
        [0] = "Frozen Titans",
        [1] = "Hazardous Mechs",
        [2] = "Bombermechs",
        [3] = "Arachnophiles",
        [4] = "Mist Eaters",
        [5] = "Heat Sinkers",
        [6] = "Cataclysm",
        [7] = "Secret Squad",
    }
}

local function add_lock(page, id)
    if page == 0 or page == nil then
        return
    end
    
    if module.ap_link.custom then
        if page == 1 and id == 1 then
            return
        end
    else
        local unlock_name = module.position_to_name[page][id]
        if module.ap_link.unlocked_items[unlock_name] then
            return
        end
    end
    
    local x = (id % 2) * (635 + 315 - 455 - 50 + 20 + 5)
    local y =  math.floor(id / 2) * (69 + 20 + 20 - 10)
    local ui = Ui()
        :widthpx(455)
        :heightpx(100)
        :setxpx(Boxes.hangar_select_big.x + 25 + x)
        :setypx(Boxes.hangar_select_big.y + 30 + y)
        :decorate{DecoSolid(deco.colors.framebg) }
        :beginUi()
            :width(1)
            :height(1)
            :decorate{
                DecoFrame(),
                DecoAlign(-3,-4),
                DecoAlignedText(
                    "Not unlocked",
                    deco.fonts.labelfont,
                    deco.textset(deco.colors.buttonborder),
                    "center", 
                    "center"
                )
            }
        :endUi()
        :addTo(sdlext.getUiRoot())
        :bringToTop()
    table.insert(module.ui, ui)
end

local function destroy_ui()
    if (module.ui ~= nil) then
        for _, ui in ipairs(module.ui) do
            ui:detach()
        end
        module.ui = nil
    end
end

local function lock_squads(current_page)
    if Game == nil then -- Also happens when the inventory has pages
        destroy_ui()
        module.ui = {}

        for i = 0, 7, 1 do
            --add_lock(current_page, i)
        end
    end
end

function module.initialize(mod)
    module.ap_link = mod.ap_link
    modApi.events.onSquadSelectionPageChanged:subscribe(lock_squads)
    modApi.events.onSquadSelectionWindowHidden:subscribe(destroy_ui)
end

return module