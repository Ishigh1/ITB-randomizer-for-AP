return {
    price = 5e9,
    efficiency = .75,

    init = function(self, ap_link)
        self.ap_link = ap_link
        local font_title = sdlext.font("fonts/JustinFont12Bold.ttf", 16)
        local text_setttings_title = deco.uifont.default.set

        local send_button = Ui()
        local get_button = Ui()
        self.energylink_content = DecoCAlignedText("0", font_title, text_setttings_title)
        self.energylink_name = "EnergyLink" .. ap_link.AP:get_team_number()
        self.slot = ap_link.AP:get_player_number()
        local reputation = sdlext.getSurface({
            path = "img/ui/strategy/icon_stars.png"
        })

        self.root = Ui()
            :width(0.15)
            :height(0.5)
            :pos(0.8, 0.25)
            :decorate { DecoSolid(deco.colors.framebg) }

            :beginUi()
            :height(0.2)
            :width(0.9)
            :posCentered(0.5, 0.1)
            :decorate {
                DecoCAlignedText("Energylink", font_title, text_setttings_title)
            }
            :endUi()

            :beginUi(send_button)
            :height(0.2)
            :width(0.9)
            :posCentered(0.5, 0.325)
            :format(function(self) self:setGroupOwner(self.parent) end)
            :settooltip("Send 1 reputation to energylink", nil, true)
            :decorate {
                DecoButton(),
                DecoCAlignedText("Send 1 reputation", font_title, text_setttings_title)
            }
            :endUi()

            :beginUi(get_button)
            :height(0.2)
            :width(0.9)
            :posCentered(0.5, 0.55)
            :format(function(self) self:setGroupOwner(self.parent) end)
            :settooltip("Get 1 reputation from energylink", nil, true)
            :decorate {
                DecoButton(),
                DecoCAlignedText("Get 1 reputation", font_title, text_setttings_title)
            }
            :endUi()

            :beginUi()
            :height(0.15)
            :width(0.9)
            :posCentered(0.5, 0.75)
            :decorate {
                DecoCAlignedText("Energylink content :", font_title, text_setttings_title)
            }
            :endUi()

            :beginUi()
            :height(0.2)
            :width(0.75)
            :posCentered(0.425, 0.875)
            :decorate {
                self.energylink_content
            }
            :endUi()

            :beginUi()
            :height(0.2)
            :width(0.2)
            :posCentered(0.75, 0.875)
            :decorate {
                DecoSurfaceAligned(reputation, "center", "center"),
            }
            :endUi()

        self.ap_link.AP:Get(
            { self.energylink_name },
            {
                id = self.ap_link.id,
                action = "get rep",
            })

        send_button.onclicked = function(ui_button, mouse_button)
            local rep = randomizer_helper.memedit.get_rep()
            if mouse_button == 1 and rep > 0 then
                randomizer_helper.memedit.set_rep(rep - 1)
                local amount_added = self.price * self.efficiency
                self.ap_link.AP:Set(self.energylink_name, 0, true, {
                        { "add", amount_added },
                        { "floor", 0 },
                    },
                    {
                        id = self.ap_link.id,
                        action = "give rep",
                        slot = self.slot,
                    })
                return true
            end

            return false
        end

        get_button.onclicked = function(ui_button, mouse_button)
            if mouse_button == 1 then
                self.ap_link.AP:Set(self.energylink_name, 0, true, {
                        { "add", -self.price },
                        { "max", 0 },
                    },
                    {
                        id = self.ap_link.id,
                        action = "take rep",
                        slot = self.slot,
                    })
                return true
            end
            return false
        end

        self.showing_shop = false
    end,

    update_energylink = function(self, amount)
        local available_rep = (amount or 0) / self.price
        self.energylink_content:setsurface(available_rep)
    end,

    show = function(self)
        if not self.showing_shop then
            self.root
                :addTo(sdlext.getUiRoot())
                :bringToTop()
            self.showing_shop = true
        elseif self.ap_link.frame % 300 ~= 0 then
            return
        end
        self.ap_link.AP:Get(
            { self.energylink_name },
            {
                id = self.ap_link.id,
                action = "get rep",
            })
    end,

    hide = function(self)
        if self.showing_shop then
            self.root:detach()
            self.showing_shop = false
        end
    end,
}
