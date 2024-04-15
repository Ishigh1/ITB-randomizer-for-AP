local module = {}

local position_to_name = {
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

local open_ui = {}

local function add_lock(page, id)
    if page == 0 or page == nil then
        return
    end

    if module.ap_link.custom then
        if page == 1 and id == 1 then
            return
        end
    else
        local unlock_name = position_to_name[page][id]
        if module.ap_link.unlocked_items[unlock_name] then
            return
        end
    end

    local x = (id % 2) * (635 + 315 - 455 - 50 + 20 + 5)
    local y = math.floor(id / 2) * (69 + 20 + 20 - 10)
    local ui = Ui()
        :widthpx(455)
        :heightpx(100)
        :setxpx(Boxes.hangar_select_big.x + 25 + x)
        :setypx(Boxes.hangar_select_big.y + 30 + y)
        :decorate { DecoSolid(deco.colors.framebg) }
        :beginUi()
        :width(1)
        :height(1)
        :decorate {
            DecoFrame(),
            DecoAlign(-3, -4),
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
    table.insert(open_ui, ui)
end

local function destroy_ui()
    if (#open_ui > 0) then
        for _, ui in ipairs(open_ui) do
            ui:detach()
        end
        open_ui = {}
    end
end

local function lock_squads(current_page)
    if Game == nil then -- Also happens when the inventory has pages
        destroy_ui()

        for i = 0, 7, 1 do
            add_lock(current_page, i)
        end
    end
end

local current_tab = "Prime"
local mouse_down

local function lock_custom()
    local left = Boxes.hangar_select_big.x + 70
    local top = Boxes.hangar_select_big.y + 30
    for i, j in ipairs(module.squad_randomizer.squads[current_tab]) do
        if not module.ap_link.unlocked_items[j] then
            local ui = Ui()
                :widthpx(125)
                :heightpx(100)
                :setxpx(left)
                :setypx(top)
                :decorate { DecoSolid(deco.colors.framebg) }
                :beginUi()
                :width(1)
                :height(1)
                :decorate {
                    DecoFrame(),
                    DecoAlign(-3, -4),
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
            table.insert(open_ui, ui)
        end
        if i % 6 == 0 then
            top = top + 130
            left = Boxes.hangar_select_big.x + 70
        else
            left = left + 135
        end
    end
end

local function squad_shown()
    local root = sdlext.getUiRoot()
    lock_custom()
    mouse_down = root.mousedown
    function root:mousedown(mx, my, button)
        if my > Boxes.hangar_select_big.y + Boxes.hangar_select_big.h - 277
            and my < Boxes.hangar_select_big.y + Boxes.hangar_select_big.h - 217
            and mx > Boxes.hangar_select_big.x
            and mx < Boxes.hangar_select_big.x + Boxes.hangar_select_big.w then
            if mx < Boxes.hangar_select_big.x + 176 then
                current_tab = "Prime"
            elseif mx < Boxes.hangar_select_big.x + 356 then
                current_tab = "Brute"
            elseif mx < Boxes.hangar_select_big.x + 558 then
                current_tab = "Ranged"
            elseif mx < Boxes.hangar_select_big.x + 770 then
                current_tab = "Science"
            else
                current_tab = "TechnoVek"
            end
            destroy_ui()
            lock_custom()
        end
        return mouse_down(self, mx, my, button)
    end
end

local function squad_hidden()
    sdlext.getUiRoot().mousedown = mouse_down
    mouse_down = nil
    destroy_ui()
end

function module.initialize(ap_link)
    module.ap_link = ap_link
    module.squad_randomizer = ap_link.squad_randomizer

    modApi.events.onSquadSelectionPageChanged:subscribe(lock_squads)
    modApi.events.onSquadSelectionWindowHidden:subscribe(destroy_ui)

    modApi.events.onCustomizeSquadWindowShown:subscribe(squad_shown)
    modApi.events.onCustomizeSquadWindowHidden:subscribe(squad_hidden)
end

return module
