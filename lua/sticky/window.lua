local M = {}

local options = {
    relative = "win",
    col = 0,
    height = 1,
    style = "",
    border = "none",
}

---@type number[]
local current_win = {}

function M.open(rows)
    M.close()

    for i = 1, #rows do
        options.row = i - 1
        options.width = vim.api.nvim_win_get_width(0)

        local win = vim.api.nvim_open_win(0, false, options)
        vim.api.nvim_win_call(win, function()
            vim.cmd("normal! " .. rows[i] + 1 .. "G")
        end)

        table.insert(current_win, win)
    end
end

function M.close()
    if #current_win > 0 then
        for _, win in ipairs(current_win) do
            vim.api.nvim_win_close(win, false)
        end
        current_win = {}
    end
end

return M
