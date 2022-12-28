local M = {}

vim.g.delaytrain_delay_ms = 1000
vim.g.delaytrain_grace_period = 1

-- Map of keys to their individual current grace period
-- This keeps track of how many times a key has been pressed
local current_grace_period_intervals = {}
local ignore_filetypes = {}

local keymaps = {
    ['nv'] = {'h', 'j', 'k', 'l'},
    ['nvi'] = {'<Left>', '<Down>', '<Up>', '<Right>'},
}

local is_enabled = false

local custom_mappings = {}

function M.try_delay_keypress(key, keypress)
    current_interval = current_grace_period_intervals[key]

    -- ignore user defined patterns
    for _,ign_ft in ipairs(ignore_filetypes) do
        if vim.o.filetype:match(ign_ft) then
            M.send_keypress(keypress)
            return
        end
    end

    -- Ingore on macro execution
    if vim.fn.reg_executing() ~= "" then
        M.send_keypress(keypress)
        return
    end

    -- Start a timer on the first keypress to reset the interval
    if current_interval == 0 then
        vim.loop.new_timer():start(vim.g.delaytrain_delay_ms, 0, function()
            current_grace_period_intervals[key] = 0
        end)
    end

    -- Pass the key through only if we haven't reached the grace period
    if current_interval < vim.g.delaytrain_grace_period then
        current_grace_period_intervals[key] = current_interval + 1
        M.send_keypress(keypress)
    end
end

function M.send_keypress(keypress)
    vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes(keypress, true, false, true),
        'n', 
        false
    )
end

function M.setup(opts)
    if opts then
        if opts.delay_ms then
            vim.g.delaytrain_delay_ms = opts.delay_ms
        end

        if opts.grace_period then
            vim.g.delaytrain_grace_period = opts.grace_period
        end

        ignore_filetypes = opts.ignore_filetypes or {}

        if opts.keys then
            keymaps = opts.keys
        end
    end

    M.enable()
end

function M.enable()
    is_enabled = true

    -- Get an array of all the keys we want to delay regardless of remap status
    local function get_key_mappings (key, mode_array)
        local key_mappings = {}
        for _, mode in ipairs(mode_array) do
            local keypress = key
            local remapped = vim.fn.maparg(key, mode, false, true).rhs
            if remapped then
                keypress = remapped
            end

            -- If keypress values differ across modes, add the new value here
            if key_mappings[keypress] then
                table.insert(key_mappings[keypress].modes, mode)
            else
                key_mappings[keypress] = {modes = {mode}, isremap = remapped ~= nil}
            end
        end

      return key_mappings
    end

    -- Preserve old keymap so it can be restored after calling M.disable()
    local function preserve_custom_mappings(lhs, rhs, modes)
        if custom_mappings[lhs] then
            table.insert(custom_mappings[lhs], {rhs = rhs, modes = modes})
        else
            custom_mappings[lhs] = {{rhs = rhs, modes = modes}}
        end
    end

    for modes, keys in pairs(keymaps) do
        mode_array = {}
        for mode in modes:gmatch"."  do
            table.insert(mode_array, mode)
        end

        for _, key in ipairs(keys) do
            local key_mappings = get_key_mappings(key, mode_array)
            for keypress, key_data in pairs(key_mappings) do
                if key_data.isremap then
                  preserve_custom_mappings(key, keypress, key_data.modes)
                end
                -- Set the current grace period for the given key
                current_grace_period_intervals[key] = 0
                vim.keymap.set(key_data.modes, key, function() M.try_delay_keypress(key, keypress) end, {expr = true})
            end
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
            -- Re-enable custom mappings
            if custom_mappings[key] then
                for _, map_values in pairs(custom_mappings[key]) do
                  vim.keymap.set(map_values.modes, key, map_values.rhs)
                end
            end
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
