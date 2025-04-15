local M = {}

-- Setup function for user configuration
function M.setup(user_config)
    -- Currently, no configurable options are available.
    -- This function is a placeholder for future configurations.
    print("Runpad setup called.")
end

-- Open a new tab with the specified filetype and set the tab name
function M.open_runpad(filetype)
    if not filetype or filetype == "" then
        print("Error: Filetype is required.")
        return
    end

    vim.cmd("tabnew")
    local buf = vim.api.nvim_get_current_buf() -- Get the current buffer number
    vim.bo.filetype = filetype
    vim.cmd("file runpad:" .. filetype .. ":" .. buf) -- Set the tab name
end

-- Command registration
vim.api.nvim_create_user_command('RunpadOpen', function(opts)
    M.open_runpad(opts.args)
end, {
    nargs = 1,
    complete = function()
        return { "lua", "python", "javascript", "r" } -- Example filetypes
    end
})

return M