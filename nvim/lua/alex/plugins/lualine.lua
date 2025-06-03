return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local colors = {
            bg = '#090F19',
            fg = '#92a1ba',
            yellow = '#c4a500',
            cyan = '#74b9b4',
            darkblue = '#090F19',
            green = '#88ad9c',
            orange = '#ec9a34',
            violet = '#b9a3b7',
            magenta = '#b9a3b7',
            blue = '#9dafc6',
            red = '#db9b9b'
        }

        local mode_color = {
            n = colors.blue,
            i = colors.green,
            v = colors.yellow,
            [''] = colors.yellow,
            V = colors.yellow,
            c = colors.magenta,
            no = colors.red,
            s = colors.orange,
            S = colors.orange,
            [''] = colors.orange,
            ic = colors.yellow,
            R = colors.violet,
            Rv = colors.violet,
            cv = colors.red,
            ce = colors.red,
            r = colors.cyan,
            rm = colors.cyan,
            ['r?'] = colors.cyan,
            ['!'] = colors.red,
            t = colors.red
        }

        local custom_theme = {
            normal = {
                a = { fg = colors.bg, bg = colors.green, gui = 'bold' },
                b = { fg = colors.fg, bg = colors.darkblue },
                c = { fg = colors.fg, bg = colors.bg }
            },
            insert = { a = { fg = colors.bg, bg = colors.blue, gui = 'bold' } },
            visual = { a = { fg = colors.bg, bg = colors.violet, gui = 'bold' } },
            replace = { a = { fg = colors.bg, bg = colors.red, gui = 'bold' } },
            inactive = {
                a = { fg = colors.fg, bg = colors.bg, gui = 'bold' },
                b = { fg = colors.fg, bg = colors.bg },
                c = { fg = colors.fg, bg = colors.bg }
            }
        }

        local lualine = require("lualine")
        local lazy_status = require("lazy.status") -- to configure lazy pending updates count

        local LspProgress = require("lualine.component"):extend()
        local highlight = require("lualine.highlight")

        -- LuaFormatter off
        LspProgress.default = {
            colors = {
                percentage = "#ffffff",
                title = "#ffffff",
                message = "#ffffff",
                spinner = "#008080",
                lsp_client_name = "#c678dd",
                use = false,
            },
            separators = {
                component = " ",
                progress = " | ",
                message = { pre = "(", post = ")" },
                percentage = { pre = "", post = "%% " },
                title = { pre = "", post = ": " },
                lsp_client_name = { pre = "[", post = "]" },
                spinner = { pre = "", post = "" },
            },
            hide = {},
            only_show_attached = false,
            display_components = { "lsp_client_name", "spinner", { "title", "percentage", "message" } },
            timer = { progress_enddelay = 500, spinner = 500, lsp_client_name_enddelay = 1000, attached_delay = 3000 },
            spinner_symbols_dice = { " ", " ", " ", " ", " ", " " }, -- Nerd fonts needed
            spinner_symbols_moon = { "🌑 ", "🌒 ", "🌓 ", "🌔 ", "🌕 ", "🌖 ", "🌗 ", "🌘 " },
            spinner_symbols_square = { "▙ ", "▛ ", "▜ ", "▟ " },
            spinner_symbols = { "▙ ", "▛ ", "▜ ", "▟ " },
            message = { initializing = "Initializing…", commenced = "In Progress", completed = "Completed" },
            max_message_length = 30,
        }

        -- Initializer
        LspProgress.init = function(self, options)
            LspProgress.super.init(self, options)

            self.options.max_message_length = self.options.max_message_length or LspProgress.default.max_message_length
            self.options.colors = vim.tbl_extend("force", LspProgress.default.colors, self.options.colors or {})
            self.options.separators =
                vim.tbl_deep_extend("force", LspProgress.default.separators, self.options.separators or {})
            self.options.display_components = self.options.display_components or LspProgress.default.display_components
            self.options.timer = vim.tbl_extend("force", LspProgress.default.timer, self.options.timer or {})
            self.options.spinner_symbols =
                vim.tbl_extend("force", LspProgress.default.spinner_symbols, self.options.spinner_symbols or {})
            self.options.message = vim.tbl_extend("force", LspProgress.default.message, self.options.message or {})

            self.highlights = { percentage = "", title = "", message = "" }
            if self.options.colors.use then
                self.highlights.title = highlight.create_component_highlight_group(
                    { fg = self.options.colors.title },
                    "lspprogress_title",
                    self.options
                )
                self.highlights.percentage = highlight.create_component_highlight_group(
                    { fg = self.options.colors.percentage },
                    "lspprogress_percentage",
                    self.options
                )
                self.highlights.message = highlight.create_component_highlight_group(
                    { fg = self.options.colors.message },
                    "lspprogress_message",
                    self.options
                )
                self.highlights.spinner = highlight.create_component_highlight_group(
                    { fg = self.options.colors.spinner },
                    "lspprogress_spinner",
                    self.options
                )
                self.highlights.lsp_client_name = highlight.create_component_highlight_group(
                    { fg = self.options.colors.lsp_client_name },
                    "lspprogress_lsp_client_name",
                    self.options
                )
            end
            -- Setup callback to get updates from the lsp to update lualine.

            self:register_progress()
            -- No point in setting spinner callbacks if it is not displayed.
            for _, display_component in pairs(self.options.display_components) do
                if display_component == "spinner" then
                    self:setup_spinner()
                    break
                end
            end
        end

        LspProgress.update_status = function(self)
            self:update_progress()
            return self.progress_message
        end

        LspProgress.suppress_server = function(self, name)
            if vim.tbl_contains(self.options.hide or {}, name) then
                return true
            end
            return false
        end

        LspProgress.register_progress = function(self)
            self.clients = {}

            self.progress_callback = function(msgs)
                for _, msg in ipairs(msgs) do
                    local client_name = msg.name

                    if self:suppress_server(client_name) then
                        self.clients[client_name] = nil
                    else
                        if self.clients[client_name] == nil then
                            self.clients[client_name] = { progress = {}, name = client_name }
                        end

                        if self.clients[client_name].attach_timer then
                            vim.uv.timer_stop(self.clients[client_name].attach_timer)
                        end

                        local progress = self.clients[client_name].progress

                        progress.message = self.options.message.commenced
                        if msg.title then
                            progress.title = msg.title
                        end
                        if msg.percentage then
                            progress.percentage = msg.percentage
                        end
                        if msg.message then
                            if string.len(msg.message) > self.options.max_message_length then
                                progress.message = string.sub(msg.message, 0, self.options.max_message_length) .. "..."
                            else
                                progress.message = msg.message
                            end
                        end
                        if msg.done then
                            if progress.percentage then
                                progress.percentage = "100"
                            end
                            progress.message = self.options.message.completed
                            vim.defer_fn(function()
                                if self.clients[client_name] then
                                    self.clients[client_name].progress = {}
                                end
                                vim.defer_fn(function()
                                    local has_items = false
                                    if self.clients[client_name] and self.clients[client_name].progress then
                                        for _, _ in pairs(self.clients[client_name].progress) do
                                            has_items = true
                                            break
                                        end
                                    end
                                    if has_items == false then
                                        self.clients[client_name] = nil
                                    end
                                end, self.options.timer.lsp_client_name_enddelay)
                            end, self.options.timer.progress_enddelay)
                        end
                    end
                end
            end

            local gid = vim.api.nvim_create_augroup("LualineLspProgressEvent", { clear = true })
            if vim.fn.has("nvim-0.10") == 1 then
                -- vim.api.nvim_create_autocmd("LspProgress", {
                -- 	group = gid,
                -- 	callback = function(data)
                -- 		print(data.data.value)
                -- 		local value = data.data.result.value
                -- 		local msgs = {
                -- 			{
                -- 				message = value.message,
                -- 				percentage = value.percentage,
                -- 				title = value.title,
                -- 				name = vim.lsp.get_client_by_id(data.data.client_id).name,
                -- 				done = value.kind == "end",
                -- 			},
                -- 		}
                -- 		self.progress_callback(msgs)
                -- 	end,
                -- })
            else
                vim.api.nvim_create_autocmd("User", {
                    group = gid,
                    pattern = { "LspProgressUpdate" },
                    callback = function()
                        self.progress_callback(vim.lsp.util.get_progress_messages())
                    end,
                })
            end

            local cached_attached = {}
            vim.api.nvim_create_autocmd("LspAttach", {
                group = gid,
                callback = function(args)
                    local client_id = args.data.client_id
                    if cached_attached[client_id] == nil then
                        cached_attached[client_id] = true
                        local name = vim.lsp.get_client_by_id(client_id).name
                        self.progress_callback({
                            {
                                done = false,
                                name = name,
                                progress = true,
                                title = self.options.message.initializing,
                            },
                        })
                        if self.clients[name] then
                            self.clients[name].attach_timer = vim.defer_fn(function()
                                self.progress_callback({
                                    {
                                        done = true,
                                        name = name,
                                    },
                                })
                            end, self.options.timer.attached_delay)
                        end
                    end
                end,
            })
            vim.api.nvim_create_autocmd("LspDetach", {
                group = gid,
                callback = function(args)
                    local client_id = args.data.client_id
                    cached_attached[client_id] = nil
                end,
            })
        end

        LspProgress.update_progress = function(self)
            local options = self.options
            local result = {}

            local attached = vim.tbl_map(function(c)
                return c.name
            end, vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() }))
            for _, client in pairs(self.clients) do
                for _, display_component in pairs(self.options.display_components) do
                    local display_client = true
                    if self.options.only_show_attached then
                        if not vim.tbl_contains(attached, client.name) then
                            display_client = false
                        end
                    end

                    if display_client then
                        if display_component == "lsp_client_name" then
                            if options.colors.use then
                                table.insert(
                                    result,
                                    highlight.component_format_highlight(self.highlights.lsp_client_name)
                                    .. options.separators.lsp_client_name.pre
                                    .. client.name
                                    .. options.separators.lsp_client_name.post
                                )
                            else
                                table.insert(
                                    result,
                                    options.separators.lsp_client_name.pre
                                    .. client.name
                                    .. options.separators.lsp_client_name.post
                                )
                            end
                        elseif display_component == "spinner" then
                            if options.colors.use then
                                table.insert(
                                    result,
                                    highlight.component_format_highlight(self.highlights.spinner)
                                    .. options.separators.spinner.pre
                                    .. self.spinner.symbol
                                    .. options.separators.spinner.post
                                )
                            else
                                table.insert(
                                    result,
                                    options.separators.spinner.pre
                                    .. self.spinner.symbol
                                    .. options.separators.spinner.post
                                )
                            end
                        elseif type(display_component) == "table" then
                            self:update_progress_components(result, display_component, client.progress)
                        end
                    end
                end
            end
            if #result > 0 then
                self.progress_message = table.concat(result, options.separators.component)
                if not self.timer then
                    self:setup_spinner()
                end
            else
                self.progress_message = ""
                if self.timer then
                    self.timer:stop()
                    self.timer = nil
                end
            end
        end

        LspProgress.update_progress_components = function(self, result, display_components, progress)
            local p = {}
            local options = self.options
            if progress.title then
                local d = {}
                for _, i in pairs(display_components) do
                    if progress[i] and progress[i] ~= "" then
                        if options.colors.use then
                            table.insert(
                                d,
                                highlight.component_format_highlight(self.highlights[i])
                                .. options.separators[i].pre
                                .. progress[i]
                                .. options.separators[i].post
                            )
                        else
                            table.insert(d, options.separators[i].pre .. progress[i] .. options.separators[i].post)
                        end
                    end
                end
                table.insert(p, table.concat(d, ""))
            end
            table.insert(result, table.concat(p, options.separators.progress))
        end

        LspProgress.setup_spinner = function(self)
            self.spinner = {}
            self.spinner.index = 0
            self.spinner.symbol_mod = #self.options.spinner_symbols
            self.spinner.symbol = self.options.spinner_symbols[1]
            self.timer = vim.uv.new_timer()
            self.timer:start(
                0,
                self.options.timer.spinner,
                vim.schedule_wrap(function()
                    self.spinner.index = (self.spinner.index % self.spinner.symbol_mod) + 1
                    self.spinner.symbol = self.options.spinner_symbols[self.spinner.index]
                end)
            )
        end

        local function format(component, text, hl_group)
            if not hl_group then
                return text
            end

            ---@type table<string, string>
            component.hl_cache = component.hl_cache or {}
            local lualine_hl_group = component.hl_cache[hl_group]
            if not lualine_hl_group then
                local utils = require("lualine.utils.utils")
                local mygui = function()
                    local mybold = utils.extract_highlight_colors(hl_group, "bold") and "bold"
                    local myitalic = utils.extract_highlight_colors(hl_group, "italic") and "italic"
                    if mybold and myitalic then
                        return mybold .. "," .. myitalic
                    elseif mybold then
                        return mybold
                    elseif myitalic then
                        return myitalic
                    else
                        return ""
                    end
                end

                lualine_hl_group = component:create_hl({
                    fg = utils.extract_highlight_colors(hl_group, "fg"),
                    gui = mygui(),
                }, "LV_" .. hl_group)
                component.hl_cache[hl_group] = lualine_hl_group
            end
            return component:format_hl(lualine_hl_group) .. text .. component:get_default_hl()
        end

        local function normalize_path(path)
            -- Convert to absolute path
            path = vim.fn.fnamemodify(path, ':p')
            -- Remove trailing slash
            return path:gsub('([^/])/$', '%1')
        end

        local function get_root(opts)
            opts = opts or {}
            local normalize = opts.normalize or false

            -- Try to get root from LSP
            local function from_lsp()
                local buf = vim.api.nvim_get_current_buf()
                local clients = vim.lsp.get_clients({ bufnr = buf })
                if #clients > 0 then
                    return clients[1].config.root_dir
                end
                return nil
            end

            -- Try to get root from git
            local function from_git()
                local git_dir = vim.fn.finddir('.git', vim.fn.getcwd() .. ';')
                return vim.fn.fnamemodify(git_dir, ':h')
            end

            -- Try different methods to get root
            local root = from_lsp() or from_git() or vim.fn.getcwd()

            -- Normalize path if requested
            if normalize then
                root = normalize_path(root)
            end

            return root
        end

        local function pretty_path(opts)
            opts = vim.tbl_extend("force", {
                relative = "cwd",
                modified_hl = "Normal",
                filename_hl = "Bold",
                dirpath_hl = "Normal",
            }, opts or {})

            return function(self)
                local path = vim.fn.expand("%:p") --[[@as string]]
                if path == "" then
                    return ""
                end

                local root = get_root({ normalize = true })
                local cwd = vim.fn.getcwd()

                if opts.relative == "cwd" and path:find(cwd, 1, true) == 1 then
                    path = path:sub(#cwd + 2)
                else
                    path = path:sub(#root + 2)
                end

                local sep = package.config:sub(1, 1)
                local parts = vim.split(path, "[\\/]")

                if #parts > 3 then
                    parts = { parts[1], "…", parts[#parts - 1], parts[#parts] }
                end

                if opts.modified_hl and vim.bo.modified then
                    parts[#parts] = format(self, parts[#parts], opts.modified_hl)
                else
                    parts[#parts] = format(self, parts[#parts], opts.filename_hl)
                end

                local dirpath = ""
                if #parts > 1 then
                    dirpath = table.concat({ unpack(parts, 1, #parts - 1) }, sep)
                    dirpath = format(self, dirpath .. sep, opts.dirpath_hl)
                end
                return dirpath .. parts[#parts]
            end
        end

        lualine.setup({
            extensions = {
                "mason",
                "trouble",
                "toggleterm",
            },
            options = {
                section_separators = { left = "", right = "" },
                component_separators = { left = "", right = "" },
                theme = custom_theme,
            },
            sections = {
                lualine_a = {
                    {
                        "mode"
                    },
                    {
                        color = function()
                            return { fg = mode_color[vim.fn.mode()], bg = colors.bg }
                        end,
                    }
                },
                lualine_c = {
                    pretty_path(),
                },
                -- lualine_y = {
                --     LspProgress,
                -- },
                lualine_x = {
                    {
                        lazy_status.updates,
                        cond = lazy_status.has_updates,
                        color = { fg = "#ff9e64" },
                    },
                    { "fileformat" },
                    { "filetype" },
                },
            },
        })
    end,
}
