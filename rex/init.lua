-- Rex 配置, 修改后执行 `rex config reload`。
-- 键位：Rex 默认已覆盖 cmd+1-9 / cmd+t / cmd+d / shift+cmd+d / cmd+w / cmd+backspace，这里只补差异
rex.bind("cmd+r", "client.tab.rename")        -- set_tab_title
rex.bind("cmd+z", "pane.zoom")                -- toggle_layout stack
rex.bind("cmd+h", "client.tab.previous")      -- previous_tab
rex.bind("cmd+l", "client.tab.next")          --  next_tab
