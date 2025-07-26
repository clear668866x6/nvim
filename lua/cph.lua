-- ~/.config/nvim/lua/cph.lua
local M = {}

-- 延迟初始化的变量

local fn, api, uv
local function init_vim_vars()
if not fn then
fn, api, uv = vim.fn, vim.api, vim.uv or vim.loop
end
end

-- 配置 & 状态

local CFG = {
cmd = {
cpp = 'g++ -std=c++23 -O2 -Wall -Wextra -o %s %s', -- 仅编译
py = 'python3 %s',
java = 'javac -d %s %s', -- 仅编译
c = 'gcc -std=c99 -O2 -Wall -Wextra -o %s %s', -- 仅编译
},
ext_map = {
cpp = 'cpp',
py = 'py',
java = 'java',
c = 'c'
},
panel_width = 40,
test_height = 8,
timeout = 4000,
}

M.state = {
is_open = false,
current_test_idx = 1,
tests = {},
source_win = nil,
source_buf = nil,
source_file = nil,
handles = {
panel_win = nil,
panel_buf = nil,
input_win = nil,
input_buf = nil,
output_win = nil,
output_buf = nil,
expected_win = nil,
expected_buf = nil,
},
running_job = nil,
is_new_test = false, -- 标记是否是新增的测试用例
}

-- 工具函数

local function notify(msg, level)
init_vim_vars()
-- vim.notify("[FastOlympicCoding] " .. msg, level or vim.log.levels.INFO)
end

local function get_project_root()
init_vim_vars()
if M.state.source_file and M.state.source_file ~= '' then
return fn.fnamemodify(M.state.source_file, ':h')
end
local current_file = fn.expand('%:p')
if current_file ~= '' then
	return fn.fnamemodify(current_file, ':h')
end
return fn.getcwd()
end

local function get_data_dir()
init_vim_vars()
local dir = get_project_root() .. '/.fastolympiccoding'
if fn.isdirectory(dir) == 0 then
fn.mkdir(dir, 'p')
end
return dir
end

local function get_tests_file()
    init_vim_vars()
    if not M.state.source_file or M.state.source_file == '' then
        return nil
    end
    local source_name_no_ext = fn.fnamemodify(M.state.source_file, ':t:r')
    return get_data_dir() .. '/' .. source_name_no_ext .. '.tests.json'
end

local function get_file_ext(filepath)
init_vim_vars()
return fn.fnamemodify(filepath, ':e')
end

local function get_file_name_no_ext(filepath)
init_vim_vars()
return fn.fnamemodify(filepath, ':t:r')
end

-- 生成唯一的缓冲区名称
local function get_unique_buf_name(base_name)
    init_vim_vars()
    local counter = 1
    local name = base_name

    while true do
        local existing_buf = fn.bufnr(name)
        if existing_buf == -1 then
            return name
        end
        counter = counter + 1
        name = base_name .. '_' .. counter
    end
end

-- 数据管理

local function load_tests()
init_vim_vars()
local file = get_tests_file()

-- 默认情况
M.state.is_new_test = true -- 默认是新测试

if not file or fn.filereadable(file) == 0 then
	M.state.tests = {
		{ input = "", expected_output = "", actual_output = "", status = "not_run" }
	}
	M.state.current_test_idx = 1
	return
end

local content = fn.readfile(file)
local ok, data = pcall(vim.json.decode, table.concat(content, '\n'))
if ok and type(data) == 'table' and #data > 0 then
	M.state.tests = data
	M.state.is_new_test = false -- 有数据，不是新测试
	for _, test in ipairs(M.state.tests) do
		test.actual_output = ""
		test.status = "not_run"
        test.runtime = nil
	end
else
	M.state.tests = {
		{ input = "", expected_output = "", actual_output = "", status = "not_run" }
	}
end
if M.state.current_test_idx > #M.state.tests then
    M.state.current_test_idx = #M.state.tests
end
if M.state.current_test_idx < 1 then M.state.current_test_idx = 1 end
end

local function save_tests()
init_vim_vars()
local idx = M.state.current_test_idx
local test = M.state.tests[idx]
if test and M.state.is_open then
	if M.state.handles.input_buf and api.nvim_buf_is_valid(M.state.handles.input_buf) then
		test.input = table.concat(api.nvim_buf_get_lines(M.state.handles.input_buf, 0, -1, false), '\n')
	end
	if M.state.handles.expected_buf and api.nvim_buf_is_valid(M.state.handles.expected_buf) then
		test.expected_output = table.concat(api.nvim_buf_get_lines(M.state.handles.expected_buf, 0, -1, false), '\n')
	end
end

local file = get_tests_file()
if not file then return end

local tests_to_save = {}
for _, t in ipairs(M.state.tests) do
    table.insert(tests_to_save, {
        input = t.input,
        expected_output = t.expected_output,
    })
end

local json_str = vim.json.encode(tests_to_save)
local formatted_json = json_str:gsub(',', ',\n  '):gsub('{', '{\n  '):gsub('}', '\n}')
local f = io.open(file, 'w')
if not f then
	notify('无法保存测试用例到文件: ' .. file, vim.log.levels.ERROR)
	return
end
f:write(formatted_json)
f:close()
end

-- UI 创建和管理
local function create_test_panel()
init_vim_vars()
M.state.source_win = api.nvim_get_current_win()
M.state.source_buf = api.nvim_get_current_buf()
M.state.source_file = api.nvim_buf_get_name(M.state.source_buf)

if M.state.source_file == '' then
	notify("Please save the current file first", vim.log.levels.ERROR)
	return false
end
local filetype = api.nvim_buf_get_option(M.state.source_buf, 'filetype')
if not CFG.ext_map[filetype] then
	notify("Unsupported file type: " .. filetype, vim.log.levels.WARN)
	return false
end

-- 创建主面板
vim.cmd('botright vsplit')
vim.cmd('vertical resize ' .. CFG.panel_width)
local panel_buf = api.nvim_create_buf(false, true)
local panel_name = get_unique_buf_name('FastOlympicCoding://Tests')
api.nvim_buf_set_name(panel_buf, panel_name)
api.nvim_buf_set_option(panel_buf, 'buftype', 'nofile')
api.nvim_buf_set_option(panel_buf, 'swapfile', false)
api.nvim_buf_set_option(panel_buf, 'bufhidden', 'hide')
api.nvim_buf_set_option(panel_buf, 'modifiable', false)
local panel_win = api.nvim_get_current_win()
api.nvim_win_set_buf(panel_win, panel_buf)
api.nvim_win_set_option(panel_win, 'number', false)
api.nvim_win_set_option(panel_win, 'relativenumber', false)
api.nvim_win_set_option(panel_win, 'wrap', false)
api.nvim_win_set_option(panel_win, 'signcolumn', 'no')
api.nvim_win_set_option(panel_win, 'foldcolumn', '0')
api.nvim_win_set_option(panel_win, 'winbar', ' FastOlympicCoding Tests ')
M.state.handles.panel_win = panel_win
M.state.handles.panel_buf = panel_buf

-- 创建输入框
vim.cmd('split')
vim.cmd('resize ' .. CFG.test_height)
local input_buf = api.nvim_create_buf(false, true)
local input_name = get_unique_buf_name('FastOlympicCoding://Input')
api.nvim_buf_set_name(input_buf, input_name)
api.nvim_buf_set_option(input_buf, 'buftype', 'acwrite')
api.nvim_buf_set_option(input_buf, 'swapfile', false)
api.nvim_buf_set_option(input_buf, 'bufhidden', 'hide')
local input_win = api.nvim_get_current_win()
api.nvim_win_set_buf(input_win, input_buf)
api.nvim_win_set_option(input_win, 'number', false)
api.nvim_win_set_option(input_win, 'relativenumber', false)
api.nvim_win_set_option(input_win, 'winbar', ' Input ')
M.state.handles.input_win = input_win
M.state.handles.input_buf = input_buf

-- 创建期望输出框
vim.cmd('split')
vim.cmd('resize ' .. CFG.test_height)
local expected_buf = api.nvim_create_buf(false, true)
local expected_name = get_unique_buf_name('FastOlympicCoding://Expected')
api.nvim_buf_set_name(expected_buf, expected_name)
api.nvim_buf_set_option(expected_buf, 'buftype', 'acwrite')
api.nvim_buf_set_option(expected_buf, 'swapfile', false)
api.nvim_buf_set_option(expected_buf, 'bufhidden', 'hide')
local expected_win = api.nvim_get_current_win()
api.nvim_win_set_buf(expected_win, expected_buf)
api.nvim_win_set_option(expected_win, 'number', false)
api.nvim_win_set_option(expected_win, 'relativenumber', false)
api.nvim_win_set_option(expected_win, 'winbar', ' Expected Output ')
M.state.handles.expected_win = expected_win
M.state.handles.expected_buf = expected_buf

-- 创建实际输出框（不可修改）
vim.cmd('split')
local output_buf = api.nvim_create_buf(false, true)
local output_name = get_unique_buf_name('FastOlympicCoding://Output')
api.nvim_buf_set_name(output_buf, output_name)
api.nvim_buf_set_option(output_buf, 'buftype', 'nofile')
api.nvim_buf_set_option(output_buf, 'swapfile', false)
api.nvim_buf_set_option(output_buf, 'bufhidden', 'hide')
api.nvim_buf_set_option(output_buf, 'modifiable', false)
local output_win = api.nvim_get_current_win()
api.nvim_win_set_buf(output_win, output_buf)
api.nvim_win_set_option(output_win, 'number', false)
api.nvim_win_set_option(output_win, 'relativenumber', false)
api.nvim_win_set_option(output_win, 'winbar', ' Actual Output ')
M.state.handles.output_win = output_win
M.state.handles.output_buf = output_buf

-- 设置按键映射
local test_keymaps = {
	['<CR>'] = ':lua require("cph").run_current_test()<CR>',
	['j'] = ':lua require("cph").next_test()<CR>',
	['k'] = ':lua require("cph").prev_test()<CR>',
	['a'] = ':lua require("cph").add_test()<CR>',
	['d'] = ':lua require("cph").delete_test()<CR>',
	['<C-c>'] = ':lua require("cph").kill_process()<CR>',
}
for key, cmd in pairs(test_keymaps) do
	api.nvim_buf_set_keymap(panel_buf, 'n', key, cmd, { noremap = true, silent = true })
end

local save_and_normal = function()
	save_tests()
	vim.cmd('stopinsert')
	notify("Saved and switched to normal mode")
end

local edit_buffers = { input_buf, expected_buf }
for _, buf in ipairs(edit_buffers) do
	api.nvim_buf_set_keymap(buf, 'i', '<Tab>', '', { noremap = true, silent = true, callback = save_and_normal })
	api.nvim_buf_set_keymap(buf, 'n', '<Tab>', ':lua require("cph").save_and_stay()<CR>', { noremap = true, silent = true })
	api.nvim_buf_set_keymap(buf, 'i', '<C-s>', '', { noremap = true, silent = true, callback = save_and_normal })
	api.nvim_buf_set_keymap(buf, 'n', '<C-s>', ':lua require("cph").save_and_stay()<CR>', { noremap = true, silent = true })
end

-- 聚焦到输入框，根据是否是新测试决定是否进入插入模式
vim.schedule(function()
    if api.nvim_win_is_valid(input_win) then
        api.nvim_set_current_win(input_win)
        if M.state.is_new_test then
            vim.cmd('startinsert')
        end
    end
end)

return true
end

-- 你的渲染和加载函数
local function render_test_list()
init_vim_vars()
local buf = M.state.handles.panel_buf
if not buf or not api.nvim_buf_is_valid(buf) then return end
local lines = {}
table.insert(lines, "Tests:")
table.insert(lines, "")
for i, test in ipairs(M.state.tests) do
	local status_symbol = ""
	if test.status == "running" then status_symbol = "⏳"
    elseif test.status == "compiling" then status_symbol = "⚙️"
	elseif test.status == "passed" then status_symbol = "✅"
	elseif test.status == "failed" then status_symbol = "❌"
	elseif test.status == "tle" then status_symbol = "⏱"
    elseif test.status == "ce" then status_symbol = "⚠️"
	else status_symbol = "⚪"
	end
	local prefix = (i == M.state.current_test_idx) and "▶ " or "  "
    local runtime_str = ""
    if test.runtime then
        runtime_str = string.format(" (%dms)", test.runtime)
    end
	local line = string.format("%s%s Test %d%s", prefix, status_symbol, i, runtime_str)
	table.insert(lines, line)
end
table.insert(lines, "")
table.insert(lines, "Keybindings:")
table.insert(lines, "  <CR> - Run test")
table.insert(lines, "  a - Add test")
table.insert(lines, "  d - Delete test")
table.insert(lines, "  j/k - Navigate")
table.insert(lines, "  <C-c> - Kill process")
api.nvim_buf_set_option(buf, 'modifiable', true)
api.nvim_buf_set_lines(buf, 0, -1, false, lines)
api.nvim_buf_set_option(buf, 'modifiable', false)
end

local function load_current_test()
local test = M.state.tests[M.state.current_test_idx]
if not test then return end
init_vim_vars()
local function set_buf_lines(buf_handle, content)
	if buf_handle and api.nvim_buf_is_valid(buf_handle) then
		api.nvim_buf_set_option(buf_handle, 'modifiable', true)
		api.nvim_buf_set_lines(buf_handle, 0, -1, false, vim.split(content or "", '\n', { plain = true }))
	end
end
set_buf_lines(M.state.handles.input_buf, test.input)
set_buf_lines(M.state.handles.expected_buf, test.expected_output)
set_buf_lines(M.state.handles.output_buf, test.actual_output)
if M.state.handles.output_buf and api.nvim_buf_is_valid(M.state.handles.output_buf) then
	api.nvim_buf_set_option(M.state.handles.output_buf, 'modifiable', false)
end
end

-- 清理旧的缓冲区
local function cleanup_old_buffers()
    init_vim_vars()
    local buf_patterns = {
        'FastOlympicCoding://Tests',
        'FastOlympicCoding://Input',
        'FastOlympicCoding://Expected',
        'FastOlympicCoding://Output'
    }

    for _, pattern in ipairs(buf_patterns) do
        local counter = 1
        while true do
            local buf_name = counter == 1 and pattern or (pattern .. '_' .. counter)
            local buf_num = fn.bufnr(buf_name)
            if buf_num == -1 then
                break
            end
            if api.nvim_buf_is_valid(buf_num) then
                pcall(api.nvim_buf_delete, buf_num, { force = true })
            end
            counter = counter + 1
        end
    end
end

-- 你的 close_panel 函数
local function close_panel()
init_vim_vars()
if M.state.is_open then save_tests() end

-- 停止正在运行的任务
if M.state.running_job then
    M.kill_process()
end

local wins_to_close = {
	M.state.handles.panel_win, M.state.handles.input_win,
	M.state.handles.expected_win, M.state.handles.output_win,
}
for _, win in ipairs(wins_to_close) do
	if win and api.nvim_win_is_valid(win) then pcall(api.nvim_win_close, win, true) end
end

-- 延迟清理缓冲区，避免立即清理导致的问题
vim.schedule(function()
    cleanup_old_buffers()
end)

M.state.handles = {
	panel_win = nil, panel_buf = nil, input_win = nil, input_buf = nil,
	output_win = nil, output_buf = nil, expected_win = nil, expected_buf = nil,
}
M.state.is_open = false
if M.state.source_win and api.nvim_win_is_valid(M.state.source_win) then
	pcall(api.nvim_set_current_win, M.state.source_win)
end
end

-- 聚焦到输入框的辅助函数
local function focus_input(enter_insert)
    init_vim_vars()
    if M.state.is_open and M.state.handles.input_win and api.nvim_win_is_valid(M.state.handles.input_win) then
        vim.schedule(function()
            api.nvim_set_current_win(M.state.handles.input_win)
            if enter_insert then
                vim.cmd('startinsert')
            end
        end)
    end
end

-- 测试用例管理
function M.next_test()
if M.state.current_test_idx < #M.state.tests then
save_tests()
M.state.current_test_idx = M.state.current_test_idx + 1
render_test_list()
load_current_test()
focus_input(false) -- 切换测试用例时不进入插入模式
end
end
function M.prev_test()
if M.state.current_test_idx > 1 then
save_tests()
M.state.current_test_idx = M.state.current_test_idx - 1
render_test_list()
load_current_test()
focus_input(false) -- 切换测试用例时不进入插入模式
end
end
function M.add_test()
if not M.state.is_open then M.toggle(); return end
save_tests()
table.insert(M.state.tests, {
	input = "", expected_output = "", actual_output = "", status = "not_run"
})
M.state.current_test_idx = #M.state.tests
render_test_list()
load_current_test()
focus_input(true) -- 新增测试用例时进入插入模式
notify("Added new test case")
end
function M.delete_test()
if not M.state.is_open then return end
if #M.state.tests <= 1 then
	notify("Cannot delete the last test case", vim.log.levels.WARN)
	return
end
table.remove(M.state.tests, M.state.current_test_idx)
if M.state.current_test_idx > #M.state.tests then
	M.state.current_test_idx = #M.state.tests
end
render_test_list()
load_current_test()
save_tests()
notify("Deleted test case")
end

-- 编译和运行
function M.kill_process()
if M.state.running_job then
	if M.state.running_job.handle and not M.state.running_job.handle:is_closing() then
		M.state.running_job.handle:kill(9)
	end
	M.state.running_job = nil
	local test = M.state.tests[M.state.current_test_idx]
	if test then test.status = "not_run" end
	render_test_list()
	notify("Process killed")
end
end

function M.run_current_test()
    init_vim_vars()
    if not M.state.is_open then notify("Panel is not open", vim.log.levels.WARN); return end
    if M.state.running_job then notify("Process is already running", vim.log.levels.WARN); return end
    save_tests()

    local source_file = M.state.source_file
    if not source_file or source_file == '' or fn.filereadable(source_file) == 0 then
        notify("Source file is not valid.", vim.log.levels.ERROR)
        return
    end

    local ext = get_file_ext(source_file)
    local test = M.state.tests[M.state.current_test_idx]
    test.status = "compiling"
    test.actual_output = ""
    test.runtime = nil
    render_test_list()
    load_current_test()

    local project_root = fn.fnamemodify(source_file, ':h')
    local data_dir = get_data_dir()
    local exe_file = data_dir .. '/' .. get_file_name_no_ext(source_file)
    if fn.has('win32') then exe_file = exe_file .. '.exe' end

    local function execute_program()
        test.status = "running"
        render_test_list()

        -- [[ 核心修正开始 ]]
        local command_to_run
        local args_for_run

        if ext == 'py' then
            command_to_run = "python3"
            args_for_run = { source_file }
        elseif ext == 'java' then
            command_to_run = "java"
            args_for_run = { "-cp", data_dir, get_file_name_no_ext(source_file) }
        else -- C, C++, etc.
            command_to_run = exe_file
            args_for_run = {}
        end
        -- [[ 核心修正结束 ]]

        local stdin, stdout, stderr = uv.new_pipe(false), uv.new_pipe(false), uv.new_pipe(false)
        local output_chunks, error_chunks = {}, {}
        local start_time = uv.hrtime()
        local timeout_timer = uv.new_timer()
        local job_finished = false

        local function cleanup_handles(process_handle)
            if timeout_timer and not timeout_timer:is_closing() then timeout_timer:stop(); timeout_timer:close() end
            if process_handle and not process_handle:is_closing() then process_handle:close() end
            if stdin and not stdin:is_closing() then stdin:close() end
            if stdout and not stdout:is_closing() then stdout:close() end
            if stderr and not stderr:is_closing() then stderr:close() end
        end

        local handle = uv.spawn(command_to_run, {
            args = args_for_run, -- 使用修正后的参数
            stdio = { stdin, stdout, stderr },
            cwd = project_root,
        }, function(code, signal)
            if job_finished then return end; job_finished = true
            local duration_ms = math.floor((uv.hrtime() - start_time) / 1000000)
            cleanup_handles(handle)
            M.state.running_job = nil

            vim.schedule(function()
                local current_test = M.state.tests[M.state.current_test_idx]
                if not current_test then return end
                current_test.runtime = duration_ms

                if code ~= 0 then
                    current_test.status = "failed"
                    current_test.actual_output = "Runtime Error:\n" .. table.concat(error_chunks)
                else
                    local actual = table.concat(output_chunks):gsub('\r\n', '\n'):gsub('%s*$', '')
                    local expected = (current_test.expected_output or ""):gsub('\r\n', '\n'):gsub('%s*$', '')
                    current_test.actual_output = actual
                    if actual == expected then
                        current_test.status = "passed"
                    else
                        current_test.status = "failed"
                    end
                end
                render_test_list()
                load_current_test()
            end)
        end)

        if not handle then
            test.status = "failed"; notify("Failed to start running process", vim.log.levels.ERROR); render_test_list(); return
        end

        timeout_timer:start(CFG.timeout, 0, function()
            if job_finished then return end; job_finished = true
            handle:kill(9)
            cleanup_handles(handle)
            M.state.running_job = nil
            vim.schedule(function()
                local current_test = M.state.tests[M.state.current_test_idx]
                if not current_test then return end
                current_test.status = "tle"
                current_test.runtime = CFG.timeout
                current_test.actual_output = string.format("Time Limit Exceeded (> %dms)", CFG.timeout)
                render_test_list()
                load_current_test()
            end)
        end)

        M.state.running_job = { handle = handle }
        stdout:read_start(function(err, data) if data then table.insert(output_chunks, data) end end)
        stderr:read_start(function(err, data) if data then table.insert(error_chunks, data) end end)
        local input_data = (test.input or "") .. '\n'
        stdin:write(input_data, function(err) if not err then stdin:shutdown() end end)
    end

    local compile_cmd_template = CFG.cmd[ext]
    if ext == 'cpp' or ext == 'c' or ext == 'java' then
        local compile_cmd
        if ext == 'java' then
            compile_cmd = string.format(compile_cmd_template, data_dir, source_file)
        else
            compile_cmd = string.format(compile_cmd_template, exe_file, source_file)
        end

        local stderr_compile = uv.new_pipe(false)
        local compile_error_chunks = {}
        local compile_handle

        compile_handle = uv.spawn('sh', {
            args = { '-c', compile_cmd }, stdio = { nil, nil, stderr_compile }, cwd = project_root,
        }, function(code, signal)
            stderr_compile:close()
            if compile_handle then compile_handle:close() end
            M.state.running_job = nil
            if code == 0 then
                vim.schedule(execute_program)
            else
                test.status = "ce"
                test.actual_output = "Compilation Error:\n" .. table.concat(compile_error_chunks)
                vim.schedule(function()
                    render_test_list()
                    load_current_test()
                end)
            end
        end)

        if not compile_handle then
            test.status = "ce"; notify("Failed to start compiler", vim.log.levels.ERROR); render_test_list(); return
        end
        M.state.running_job = { handle = compile_handle }
        stderr_compile:read_start(function(err, data) if data then table.insert(compile_error_chunks, data) end end)
    else
        execute_program()
    end
end


-- 公开 API
function M.save_and_stay() save_tests(); notify("Tests saved") end
function M.toggle()
init_vim_vars()
if M.state.is_open then
	close_panel()
	notify("Panel closed")
else
	local current_buf = api.nvim_get_current_buf()
	local current_file = api.nvim_buf_get_name(current_buf)
	if current_file == '' then notify("Please save the current file first", vim.log.levels.ERROR); return end
	local filetype = api.nvim_buf_get_option(current_buf, 'filetype')
	if not CFG.ext_map[filetype] then notify("Unsupported file type: " .. filetype, vim.log.levels.WARN); return end
    M.state.source_file = current_file
	load_tests()
	if create_test_panel() ~= false then
		render_test_list()
		load_current_test()
		M.state.is_open = true
		notify("Panel opened")
	end
end
end

function M.run_all_tests()
if not M.state.is_open then notify("Panel is not open", vim.log.levels.WARN); return end
local first_failed_test = nil

local function run_next_test(idx)
	if idx > #M.state.tests then
		-- 所有测试完成，定位到第一个失败的测试
		if first_failed_test then
			M.state.current_test_idx = first_failed_test
			render_test_list()
			load_current_test()
			focus_input(false)
			notify("All tests completed. Focused on first failed test: " .. first_failed_test)
		else
			notify("All tests completed successfully!")
		end
		return
	end

	M.state.current_test_idx = idx
	render_test_list()
	load_current_test()
	M.run_current_test()
	init_vim_vars()
	local timer = uv.new_timer()
	timer:start(100, 100, function()
		if not M.state.running_job then
			timer:stop(); timer:close()
			vim.schedule(function()
				-- 检查当前测试是否失败，记录第一个失败的测试
				local current_test = M.state.tests[idx]
				if current_test and (current_test.status == "failed" or current_test.status == "ce" or current_test.status == "tle") then
					if not first_failed_test then
						first_failed_test = idx
					end
				end
				run_next_test(idx + 1)
			end)
		end
	end)
end
run_next_test(1)
end

function M.setup()
init_vim_vars()
local augroup = api.nvim_create_augroup("FastOlympicCoding", { clear = true })
api.nvim_create_autocmd("VimLeavePre", {
	group = augroup,
	callback = function() if M.state.is_open then close_panel() end end
})
api.nvim_create_autocmd("BufEnter", {
    group = augroup,
    pattern = "*",
    callback = function(opts)
        if not M.state.is_open or api.nvim_buf_get_name(opts.buf):match("^FastOlympicCoding://") then return end
        local new_file = api.nvim_buf_get_name(opts.buf)
        if new_file == '' or new_file == M.state.source_file then return end
        local filetype = api.nvim_buf_get_option(opts.buf, 'filetype')
        if CFG.ext_map[filetype] then
            vim.schedule(function()
                notify("Switching tests to " .. fn.fnamemodify(new_file, ':t'))
                save_tests()
                M.state.source_file = new_file
                M.state.source_buf = opts.buf
                M.state.source_win = api.nvim_get_current_win()
                load_tests()
                render_test_list()
                load_current_test()
            end)
        end
    end
})
api.nvim_create_autocmd("WinClosed", {
	group = augroup,
	callback = function(opts)
		if not M.state.is_open then return end
		local closed_win = tonumber(opts.match)
		for name, win in pairs(M.state.handles) do
			if type(win) == "number" and win == closed_win then
				vim.schedule(function()
					if name == "panel_win" then close_panel() end
				end)
				break
			end
		end
	end
})
api.nvim_create_user_command('CphToggle', M.toggle, { desc = 'Toggle FastOlympicCoding panel' })
api.nvim_create_user_command('CphRun', M.run_current_test, { desc = 'Run current test' })
api.nvim_create_user_command('CphRunAll', M.run_all_tests, { desc = 'Run all tests' })
api.nvim_create_user_command('CphAdd', M.add_test, { desc = 'Add new test case' })
api.nvim_create_user_command('CphDelete', M.delete_test, { desc = 'Delete current test case' })
api.nvim_create_user_command('CphKill', M.kill_process, { desc = 'Kill running process' })
api.nvim_create_user_command('CphNext', M.next_test, { desc = 'Go to next test' })
api.nvim_create_user_command('CphPrev', M.prev_test, { desc = 'Go to previous test' })
api.nvim_create_user_command('CphSave', M.save_and_stay, { desc = 'Save test cases' })
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<leader>o', M.toggle, opts)
vim.keymap.set('n', '<leader>r', M.run_current_test, opts)
vim.keymap.set('n', '<leader>ra', M.run_all_tests, opts)
vim.keymap.set('n', '<leader>a', M.add_test, opts)
vim.keymap.set('n', '<leader>d', M.delete_test, opts)
vim.keymap.set('n', '<leader>x', M.kill_process, opts)  -- 改用 x 表示 kill/stop
vim.keymap.set('n', '<leader>j', M.prev_test, opts)  -- j for previous (up)
vim.keymap.set('n', '<leader>k', M.next_test, opts)  -- k for next (down)
notify("FastOlympicCoding for Neovim initialized")
end
M.save_cases_to_file = save_tests
return M
