local actions = require("telescope.actions")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local action_state = require("telescope.actions.state")
local settings = require("settings")

local M = {}

-- Is empty?
local function is_empty(s)
	return s == nil or s == ""
end

-- Path exists check
local function path_exists(path)
	local ok, err, code = os.rename(path, path)
	if not ok then
		if code == 13 then return true end
	end
	return ok, err
end

-- Unpad string
local function unpad(str)
	return (str:gsub("[%s%z]+$", ""))
end

-- Baca metadata MP3 (ID3v1)
local function readtags(file)
	if type(file) == "string" then
		file = assert(io.open(file, "rb"))
	elseif type(file) ~= "userdata" then
		error("Expecting file or filename as #1, not " .. type(file), 2)
	end

	local position = file:seek()

	local function readStr(len)
		local str = assert(file:read(len), "Could not read " .. len .. "-byte string.")
		return unpad(str)
	end

	local function readByte()
		local byte = assert(file:read(1), "Could not read byte.")
		return string.byte(byte)
	end

	-- Try ID3v1
	file:seek("end", -128)
	local header = file:read(3)
	if header == "TAG" then
		local info = {}
		info.title = readStr(30)
		info.artist = readStr(30)
		info.album = readStr(30)
		info.year = readStr(4)
		info.comment = readStr(28)
		local zero = readByte()
		local track = readByte()
		local genre = readByte()
		if zero == 0 then
			info.track = track
			info.genre = genre
		else
			info.comment = unpad(info.comment .. string.char(zero, track, genre))
		end
		file:seek("set", position)
		return info
	end
end

-- Setup
function M.setup(opts)
	opts = opts or {}
	local options = vim.tbl_deep_extend("force", settings.options, opts)
	settings.options = options
end

-- Fungsi utama
function M.music_search()
	local music_dir = settings.options.music_dir
	if is_empty(music_dir) or not path_exists(music_dir) then
		error("music_dir is not set, check config")
	end

	local cmd = string.format("find %s -name '*.mp3'", music_dir)
	local output = io.popen(cmd):read("*a")
	local tracks = {}
	for file in output:gmatch("[^\n]+") do
		table.insert(tracks, file)
	end

	pickers.new({}, {
		prompt_title = "Select a track",
		finder = finders.new_table({
			results = tracks,
			entry_maker = function(track)
				local tag = readtags(track) or {}
				local display = string.format("[%s] %s - %s", tag.year or "?", tag.artist or "Unknown", tag.title or "Unknown")
				return {
					display = display,
					ordinal = track,
					value = track,
				}
			end,
		}),
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr, map)

local play_track = function()
	local selection = action_state.get_selected_entry()
	if not selection then return end
	actions.close(prompt_bufnr)
	vim.notify("Now playing: " .. selection.display)

	vim.fn.jobstart({ "cvlc", "--play-and-exit", "--quiet", selection.value }, {
		detach = true,
		stdout = "null",
		stderr = "null",
	})
end


			map("i", "<CR>", play_track)
			map("n", "<CR>", play_track)

			return true
		end,
	}):find()
end

return M
