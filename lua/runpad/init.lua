local M = {}

-- Add a configuration table for user customization
M.config = {
    evaluators = {
        lua = function(content)
            local chunk, err = load(content)
            if not chunk then
                return "Error: " .. err
            end
            local success, result = pcall(chunk)
            if success then
                return "Result: " .. tostring(result)
            else
                return "Error: " .. result
            end
        end,
        python = function(content)
            local handle = io.popen("python3 -c \"" .. content:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. "\"")
            local result = handle:read("*a")
            handle:close()
            return (result or ""):gsub("%s+$", "")
        end,
        javascript = function(content)
            local handle = io.popen("node -e \"" .. content:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. "\"")
            local result = handle:read("*a")
            handle:close()
            return (result or ""):gsub("%s+$", "")
        end,
        r = function(content)
            local handle = io.popen("Rscript -e \"" .. content:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. "\"")
            local result = handle:read("*a")
            handle:close()
            return (result or ""):gsub("%s+$", "")
        end,
    },
}

-- Update the setup function to allow user customization
function M.setup(user_config)
    M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
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

-- Update the eval_runpad function to use custom evaluators
function M.eval_runpad()
    local buf_name = vim.api.nvim_buf_get_name(0)
    if not buf_name:match("runpad:") then
        print("Error: Current buffer is not a runpad.")
        return
    end

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local content = table.concat(lines, "\n")
    local filetype = vim.bo.filetype

    local evaluator = M.config.evaluators[filetype]
    if evaluator then
        local result = evaluator(content)
        print(result)
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

-- Update the completion function to dynamically fetch filetypes from the configuration
vim.api.nvim_create_user_command('RunpadOpen', function(opts)
    M.open_runpad(opts.args)
end, {
    nargs = 1,
    complete = function()
        local filetypes = {}
        for ft, _ in pairs(M.config.evaluators) do
            table.insert(filetypes, ft)
        end
        return filetypes
    end
})

-- Register additional commands
vim.api.nvim_create_user_command('RunpadEval', M.eval_runpad, {})
vim.api.nvim_create_user_command('RunpadClear', M.clear_runpad, {})
vim.api.nvim_create_user_command('RunpadClose', M.close_runpad, {})
vim.api.nvim_create_user_command('RunpadToggle', M.toggle_runpad, {})

return M