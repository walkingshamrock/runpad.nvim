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

-- Evaluate the content of the current runpad buffer
function M.eval_runpad()
    local buf_name = vim.api.nvim_buf_get_name(0)
    if not buf_name:match("runpad:") then
        print("Error: Current buffer is not a runpad.")
        return
    end

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local content = table.concat(lines, "\n")
    local filetype = vim.bo.filetype

    if filetype == "lua" then
        local chunk, err = load(content)
        if not chunk then
            print("Error: " .. err)
        else
            local success, result = pcall(chunk)
            if success then
                print("Result: " .. tostring(result))
            else
                print("Error: " .. result)
            end
        end
    elseif filetype == "python" then
        local handle = io.popen("python3 -c \"" .. content:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. "\"")
        local result = handle:read("*a")
        handle:close()
        print((result or ""):gsub("%s+$", ""))
    elseif filetype == "javascript" then
        local handle = io.popen("node -e \"" .. content:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. "\"")
        local result = handle:read("*a")
        handle:close()
        print((result or ""):gsub("%s+$", ""))
    elseif filetype == "r" then
        local handle = io.popen("Rscript -e \"" .. content:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. "\"")
        local result = handle:read("*a")
        handle:close()
        print((result or ""):gsub("%s+$", ""))
    else
        print("Error: Evaluation is not supported for filetype: " .. filetype)
    end
end

-- Clear the content of the current runpad buffer
function M.clear_runpad()
    local buf_name = vim.api.nvim_buf_get_name(0)
    if not buf_name:match("runpad:") then
        print("Error: Current buffer is not a runpad.")
        return
    end

    vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
    print("Runpad buffer cleared.")
end

-- Close the current runpad buffer
function M.close_runpad()
    local buf_name = vim.api.nvim_buf_get_name(0)
    if not buf_name:match("runpad:") then
        print("Error: Current buffer is not a runpad.")
        return
    end

    vim.api.nvim_buf_delete(0, { force = true })
    print("Runpad buffer closed.")
end

-- Toggle the visibility of the default runpad buffer
function M.toggle_runpad()
    local buf_name = "runpad:default"
    local buf = vim.fn.bufnr(buf_name)

    if buf == -1 then
        buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(buf, buf_name)
        vim.api.nvim_set_current_buf(buf)
    else
        local win = vim.fn.bufwinnr(buf)
        if win == -1 then
            vim.api.nvim_set_current_buf(buf)
        else
            vim.api.nvim_win_close(win, true)
        end
    end
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

-- Register additional commands
vim.api.nvim_create_user_command('RunpadEval', M.eval_runpad, {})
vim.api.nvim_create_user_command('RunpadClear', M.clear_runpad, {})
vim.api.nvim_create_user_command('RunpadClose', M.close_runpad, {})
vim.api.nvim_create_user_command('RunpadToggle', M.toggle_runpad, {})

return M