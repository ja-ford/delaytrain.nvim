local M = {}

vim.g.delaytrain_delay_ms = 1000
vim.g.delaytrain_grace_period = 1

-- Map of keys to their individual current grace period
-- This keeps track of how many times a key has been pressed
local current_grace_period_intervals = {}

local keymaps = {
    ['nv'] = {'h', 'j', 'k', 'l'},
    ['nvi'] = {'<Left>', '<Down>', '<Up>', '<Right>'},
}

local is_enabled = false

function M.try_delay_keypress(key)
    current_interval = current_grace_period_intervals[key]

    -- Start a timer on the first keypress to reset the interval
    if current_interval == 0 then
        vim.loop.new_timer():start(vim.g.delaytrain_delay_ms, 0, function()
            current_grace_period_intervals[key] = 0
        end)
    end

    -- Pass the key through only if we haven't reached the grace period
    if current_interval < vim.g.delaytrain_grace_period then
        current_grace_period_intervals[key] = current_interval + 1

        vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes(key, true, false, true),
        'n', 
        false
        )
    end
end

function M.setup(opts)
    if opts then
        if opts.delay_ms then
            vim.g.delaytrain_delay_ms = opts.delay_ms
        end

        if opts.grace_period then
            vim.g.delaytrain_grace_period = opts.grace_period
        end

        if opts.keys then
            keymaps = opts.keys
        end
    end

    M.enable()
end

function M.enable()
    is_enabled = true

    for modes, keys in pairs(keymaps) do
        mode_array = {}
        for mode in modes:gmatch"."  do
            table.insert(mode_array, mode)
        end
        for _, key in ipairs(keys) do
            -- Set the current grace period for the given key
            current_grace_period_intervals[key] = 0

            vim.keymap.set(mode_array, key, function() M.try_delay_keypress(key) end, {expr = true})
        end
    end
end

function M.disable()
    is_enabled = false

    for modes, keys in pairs(keymaps) do
        mode_array = {}
        for mode in modes:gmatch"."  do
            table.insert(mode_array, mode)
        end
        for _, key in ipairs(keys) do
            vim.keymap.del(mode_array, key)
        end
    end
end

function M.toggle()
    if is_enabled then
        M.disable()
    else
        M.enable()
    end
end

return M
