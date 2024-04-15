return function(ap_link)
    local function ask_for_credentials()
        modApi.events.onMainMenuEntered:unsubscribe(ask_for_credentials)

        local font_title = sdlext.font("fonts/JustinFont12Bold.ttf", 16)
        local text_setttings_title = deco.uifont.default.set

        local server = UiInputField()
        local slot = UiInputField()
        local password = UiInputField()
        local button = Ui()
        local deathlink = UiCheckbox()
        local hint = UiCheckbox()

        local root = Ui()
            :width(0.5)
            :height(0.5)
            :posCentered()
            :decorate { DecoSolid(deco.colors.framebg) }
            :beginUi(server)
            :height(0.15)
            :width(0.95)
            :pos(0.025, 0.025)
            :format(function(self) self:setGroupOwner(self.parent) end)
            :settooltip("Server adress", nil, true)
            :decorate {
                DecoButton(),
                DecoInputField {
                    font = font_title,
                    textset = text_setttings_title,
                    alignH = "center",
                    alignV = "center",
                }
            }
            :endUi()
            :beginUi(slot)
            :height(0.15)
            :width(0.95)
            :pos(0.025, 0.225)
            :format(function(self) self:setGroupOwner(self.parent) end)
            :settooltip("Slot name", nil, true)
            :decorate {
                DecoButton(),
                DecoInputField {
                    font = font_title,
                    textset = text_setttings_title,
                    alignH = "center",
                    alignV = "center",
                }
            }
            :endUi()
            :beginUi(password)
            :height(0.15)
            :width(0.95)
            :pos(0.025, 0.425)
            :format(function(self) self:setGroupOwner(self.parent) end)
            :settooltip("Password", nil, true)
            :decorate {
                DecoButton(),
                DecoInputField {
                    font = font_title,
                    textset = text_setttings_title,
                    alignH = "center",
                    alignV = "center",
                }
            }
            :endUi()
            :beginUi(deathlink)
            :height(0.15)
            :width(0.45)
            :pos(0.025, 0.625)
            :decorate({
                DecoButton(),
                DecoCheckbox(),
                DecoCAlignedText("Deathlink", font_title, text_setttings_title)
            })
            :endUi()
            --:beginUi(hint) -- Waiting for item scouting to exist
            --    :height(0.15)
            --    :width(0.45)
            --    :pos(0.525, 0.625)
            --    :decorate({
            --        DecoButton(),
            --        DecoCheckbox(),
            --        DecoCAlignedText("Hint mode", font_title, text_setttings_title)
            --    })
            --:endUi()
            :beginUi(button)
            :height(0.15)
            :width(0.95)
            :pos(0.025, 0.825)
            :decorate {
                DecoButton(),
                DecoCAlignedText("Connect", font_title, text_setttings_title)
            }
            :endUi()
            :addTo(sdlext.getUiRoot())
            :bringToTop()

        server.textfield = modApi:readProfileData("server") or "archipelago.gg:38281"
        slot.textfield = modApi:readProfileData("slot") or "Player1"
        button.onclicked = function(self, button)
            if button == 1 then
                ap_link.server = server.textfield
                ap_link.slot = slot.textfield
                ap_link.password = password.textfield
                ap_link.deathlink = deathlink.checked
                ap_link.hint = hint.checked

                modApi:writeProfileData("server", ap_link.server)
                modApi:writeProfileData("slot", ap_link.slot)

                root:detach()
                ap_link.initializing = false

                local connection_font = sdlext.font("fonts/JustinFont12Bold.ttf", 25)

                ap_link.ui = Ui():height(0.5)
                    :width(0.5)
                    :posCentered()
                    :decorate {
                        DecoCAlignedText("Connecting...", font_title, text_setttings_title)
                    }
                    :addTo(sdlext.getUiRoot())
                return true
            end

            return false
        end
    end
    return ask_for_credentials
end
