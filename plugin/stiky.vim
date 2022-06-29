augroup sticky_header
	au!
	au CursorMoved * :lua require("sticky").run()
augroup END
