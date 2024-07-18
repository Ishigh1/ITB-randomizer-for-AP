return {
    init = function(self, ap_link)
        self.ap_link = ap_link

        local font_title = sdlext.font("fonts/JustinFont12Bold.ttf", 10)
        local text_settings_title = deco.uifont.default.set

        local root = Ui()
            :width(1)
            :height(0.02)
            :pos(0, 0.98)
            :decorate { DecoSolid(deco.colors.framebg) }
            :addTo(sdlext.getUiRoot())

        self.progress_bar = root:beginUi()
            :width(1)
            :height(1)
            :decorate { DecoSolid(sdl.rgb(255, 0, 255)) }

        self.progress_text = DecoCAlignedText("", font_title, text_settings_title)
        root
            :beginUi()
            :width(1)
            :height(1)
            :posCentered(0.5, 0.5)
            :decorate {
                self.progress_text
            }
        self:update()
    end,

    update = function(self)
        local current_achievements = self.ap_link:achievement_count()
        local max_achievements = self.ap_link.required_achievements
        local progress = math.min(1, current_achievements / max_achievements)

        self.progress_bar:width(progress)

        if self.ap_link.profile_manager:get_data("Victory") then
            self.progress_text:setsurface("You won!")
        elseif progress < 1 then
            self.progress_text:setsurface("Not enough achievements to win (" .. current_achievements .. "/"
                .. max_achievements .. ")")
        elseif Game == nil then
            self.progress_text:setsurface("Enough achievements to win (" .. current_achievements .. "/"
                .. max_achievements .. ")")
        elseif GetDifficulty() >= self.ap_link.difficulty then
            self.progress_text:setsurface("Difficulty too low to win")
        else
            self.progress_text:setsurface("Beat the final island to win!")
        end
    end
}
