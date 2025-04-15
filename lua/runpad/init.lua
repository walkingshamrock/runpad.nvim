local M = {}

-- Add a configuration table for user customization
M.config = {
    supported_filetypes = { lua = true, python = true, r = true, javascript = true },
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
        r = function(content)
            local handle = io.popen("Rscript -e \"" .. content:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. "\"")
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
    },
}

-- Helper function to check if a filetype is supported
local function is_supported_filetype(filetype)
    return M.config.supported_filetypes[filetype] or false
end

-- Function to update the configuration
function M.setup(user_config)
    M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
end

-- Create a new runpad buffer with a unique name
local function create_runpad_buffer(filetype)
    local buf = vim.api.nvim_create_buf(false, true)
    local buf_name = "runpad:" .. filetype .. ":" .. tostring(buf)
    vim.api.nvim_buf_set_name(buf, buf_name)
    vim.api.nvim_buf_set_option(buf, "filetype", filetype)
    return buf
end

-- Toggle the visibility of the default runpad buffer (legacy simple one)
function M.toggle_runpad()
    local buf_name = "runpad"
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

-- Open a runpad buffer with the specified filetype
function M.open_runpad(filetype)
    if not filetype or filetype == "" then
        print("Error: Filetype is required.")
        return
    end

    if not is_supported_filetype(filetype) then
        print("Error: Unsupported filetype for evaluation.")
        return
    end

    -- Always create a new buffer with a unique name
    local buf = create_runpad_buffer(filetype)
    vim.cmd("tabnew")
    vim.api.nvim_win_set_buf(0, buf)
end

-- Evaluate the content of the current runpad buffer
function M.eval_runpad()
    local buf = vim.api.nvim_get_current_buf()
    local buf_name = vim.api.nvim_buf_get_name(buf)

    if not buf_name:match("runpad:") then
        print("Current buffer is not a runpad.")
        return
    end

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local content = table.concat(lines, "\n")
    local filetype = vim.api.nvim_buf_get_option(buf, "filetype")

    local evaluator = M.config.evaluators[filetype]
    if evaluator then
        local result = evaluator(content)
        print(result)
    else
        print("Evaluation is not supported for filetype: " .. filetype)
    end
end

-- Clear the content of the current runpad buffer
function M.clear_runpad()
    local buf = vim.api.nvim_get_current_buf()
    local buf_name = vim.api.nvim_buf_get_name(buf)

    if not buf_name:match("runpad:") then
        print("Current buffer is not a runpad.")
        return
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
end

-- Close the current runpad buffer
function M.close_runpad()
    local buf = vim.api.nvim_get_current_buf()
    local buf_name = vim.api.nvim_buf_get_name(buf)

    if not buf_name:match("runpad:") then
        print("Current buffer is not a runpad.")
        return
    end

    vim.api.nvim_buf_delete(buf, { force = true })
end

-- Command registration
vim.api.nvim_create_user_command('RunpadToggle', M.toggle_runpad, {})

vim.api.nvim_create_user_command('RunpadOpen', function(opts)
    M.open_runpad(opts.args)
end, {
    nargs = 1,
    complete = function()
        local filetypes = {}
        for ft, _ in pairs(M.config.supported_filetypes) do
            table.insert(filetypes, ft)
        end
        return filetypes
    end
})

vim.api.nvim_create_user_command('RunpadEval', M.eval_runpad, {})
vim.api.nvim_create_user_command('RunpadClear', M.clear_runpad, {})
vim.api.nvim_create_user_command('RunpadClose', M.close_runpad, {})

return M