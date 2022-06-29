local window = require("sticky.window")

local M = {}

local config = {
    enable = {
        "TSFunction",
        "TSMethod",
    },
}

function M.run()
    local cursor = vim.api.nvim_win_get_cursor(0)
    -- 1,0 index -> 0,0 index
    cursor[1] = cursor[1] - 1
    local ranges = M.get_treesitter_syntax_groups(cursor)
    local cols = M.get_cols(ranges)
    window.open(cols)
end

function M.init()
    config._enable = {}
    for _, v in ipairs(config.enable) do
        config._enable[v] = true
    end
end

---Get tree-sitter's syntax groups for specified position.
---NOTE: This function accepts 0-origin cursor position.
---@param cursor number[]
---@return string[]
function M.get_treesitter_syntax_groups(cursor)
    M.init()

    local bufnr = vim.api.nvim_get_current_buf()
    local highlighter = vim.treesitter.highlighter.active[bufnr]
    if not highlighter then
        return {}
    end

    local contains = function(node)
        local row_s, col_s, row_e, col_e = node:range()
        local contains = true
        contains = contains and (row_s < cursor[1] or (row_s == cursor[1] and col_s <= cursor[2]))
        contains = contains and (cursor[1] < row_e or (row_e == cursor[1] and cursor[2] < col_e))
        return contains
    end

    local ranges = {}
    highlighter.tree:for_each_tree(function(tstree, ltree)
        if not tstree then
            return
        end

        local root = tstree:root()
        if contains(root) then
            local query = highlighter:get_query(ltree:lang()):query()
            for id, node in query:iter_captures(root, bufnr, cursor[1], cursor[1] + 1) do
                local name = vim.treesitter.highlighter.hl_map[query.captures[id]]
                if config._enable[name] then
                    local pos = { node:range() }
                    table.insert(ranges, pos)
                end
            end
        end
    end)

    return ranges
end

function M.get_cols(ranges)
    local top = vim.fn.line("w0")

    local cols = {}
    for _, pos in ipairs(ranges) do
        for i = pos[1], pos[3] do
            if i < top then
                table.insert(cols, i)
                top = top + 1
            end
        end
    end
    return cols
end

function M.setup(opt)
    opt = opt or {}
    for key, value in pairs(opt) do
        config[key] = value
    end
end

return M
