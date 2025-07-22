-- Custom snippets configuration for LuaSnip

local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

-- Helper functions
local function get_filename()
  return vim.fn.expand("%:t:r")
end

local function get_current_date()
  return os.date("%Y-%m-%d")
end

local function get_author()
  return vim.fn.system("git config user.name"):gsub("\n", "") or "Author"
end

-- Go snippets
ls.add_snippets("go", {
  -- Main function
  s(
    "main",
    fmt(
      [[
package main

import (
	"fmt"
)

func main() {{
	{}
}}
]],
      { i(1, 'fmt.Println("Hello, World!")') }
    )
  ),

  -- Function
  s(
    "func",
    fmt(
      [[
func {}({}) {} {{
	{}
}}
]],
      { i(1, "functionName"), i(2, ""), i(3, ""), i(4, "// TODO: implement") }
    )
  ),

  -- Method
  s(
    "method",
    fmt(
      [[
func ({} {}) {}({}) {} {{
	{}
}}
]],
      { i(1, "receiver"), i(2, "Type"), i(3, "methodName"), i(4, ""), i(5, ""), i(6, "// TODO: implement") }
    )
  ),

  -- Struct
  s(
    "struct",
    fmt(
      [[
type {} struct {{
	{}
}}
]],
      { i(1, "StructName"), i(2, "// fields") }
    )
  ),

  -- Interface
  s(
    "interface",
    fmt(
      [[
type {} interface {{
	{}
}}
]],
      { i(1, "InterfaceName"), i(2, "// methods") }
    )
  ),

  -- Error handling
  s(
    "iferr",
    fmt(
      [[
if err != nil {{
	{}
}}
]],
      { i(1, "return err") }
    )
  ),

  -- HTTP handler
  s(
    "handler",
    fmt(
      [[
func {}(w http.ResponseWriter, r *http.Request) {{
	{}
}}
]],
      { i(1, "handlerName"), i(2, "// TODO: implement handler") }
    )
  ),

  -- Test function
  s(
    "test",
    fmt(
      [[
func Test{}(t *testing.T) {{
	{}
}}
]],
      { i(1, "FunctionName"), i(2, "// TODO: implement test") }
    )
  ),

  -- Benchmark function
  s(
    "bench",
    fmt(
      [[
func Benchmark{}(b *testing.B) {{
	for i := 0; i < b.N; i++ {{
		{}
	}}
}}
]],
      { i(1, "FunctionName"), i(2, "// TODO: implement benchmark") }
    )
  ),

  -- Goroutine
  s(
    "go",
    fmt(
      [[
go func() {{
	{}
}}()
]],
      { i(1, "// TODO: implement goroutine") }
    )
  ),

  -- Channel
  s(
    "chan",
    fmt(
      [[
{} := make(chan {}{})
]],
      { i(1, "ch"), i(2, "int"), i(3, "") }
    )
  ),

  -- Select statement
  s(
    "select",
    fmt(
      [[
select {{
case {}:
	{}
default:
	{}
}}
]],
      { i(1, "<-ch"), i(2, "// handle case"), i(3, "// handle default") }
    )
  ),

  -- JSON struct tags
  s(
    "json",
    fmt(
      [[
`json:"{}"`
]],
      { i(1, "field_name") }
    )
  ),
})

-- C++ snippets
ls.add_snippets("cpp", {
  -- Main function
  s(
    "main",
    fmt(
      [[
#include <iostream>

int main() {{
    {}
    return 0;
}}
]],
      { i(1, 'std::cout << "Hello, World!" << std::endl;') }
    )
  ),

  -- Class
  s(
    "class",
    fmt(
      [[
class {} {{
private:
    {}

public:
    {}();
    ~{}();
    
    {}
}};
]],
      { i(1, "ClassName"), i(2, "// private members"), rep(1), rep(1), i(3, "// public methods") }
    )
  ),

  -- Function
  s(
    "func",
    fmt(
      [[
{} {}({}) {{
    {}
}}
]],
      { i(1, "void"), i(2, "functionName"), i(3, ""), i(4, "// TODO: implement") }
    )
  ),

  -- Header guard
  s(
    "guard",
    fmt(
      [[
#ifndef {}_H
#define {}_H

{}

#endif // {}_H
]],
      {
        f(function()
          return get_filename():upper()
        end),
        f(function()
          return get_filename():upper()
        end),
        i(1, "// header content"),
        f(function()
          return get_filename():upper()
        end),
      }
    )
  ),

  -- Namespace
  s(
    "namespace",
    fmt(
      [[
namespace {} {{
    {}
}} // namespace {}
]],
      { i(1, "name"), i(2, "// content"), rep(1) }
    )
  ),

  -- Template class
  s(
    "template",
    fmt(
      [[
template<typename {}>
class {} {{
private:
    {}

public:
    {}();
    ~{}();
    
    {}
}};
]],
      { i(1, "T"), i(2, "ClassName"), i(3, "// private members"), rep(2), rep(2), i(4, "// public methods") }
    )
  ),

  -- Constructor
  s(
    "ctor",
    fmt(
      [[
{}::{}({}) : {} {{
    {}
}}
]],
      { i(1, "ClassName"), rep(1), i(2, ""), i(3, "// initializer list"), i(4, "// constructor body") }
    )
  ),

  -- Destructor
  s(
    "dtor",
    fmt(
      [[
{}::~{}() {{
    {}
}}
]],
      { i(1, "ClassName"), rep(1), i(2, "// destructor body") }
    )
  ),

  -- For loop
  s(
    "for",
    fmt(
      [[
for (int {} = 0; {} < {}; ++{}) {{
    {}
}}
]],
      { i(1, "i"), rep(1), i(2, "n"), rep(1), i(3, "// loop body") }
    )
  ),

  -- Range-based for loop
  s(
    "forr",
    fmt(
      [[
for (const auto& {} : {}) {{
    {}
}}
]],
      { i(1, "item"), i(2, "container"), i(3, "// loop body") }
    )
  ),

  -- Try-catch
  s(
    "try",
    fmt(
      [[
try {{
    {}
}} catch (const {}& {}) {{
    {}
}}
]],
      { i(1, "// try block"), i(2, "std::exception"), i(3, "e"), i(4, "// catch block") }
    )
  ),

  -- Vector
  s(
    "vector",
    fmt(
      [[
std::vector<{}> {}({});
]],
      { i(1, "int"), i(2, "vec"), i(3, "") }
    )
  ),

  -- Smart pointer
  s(
    "unique",
    fmt(
      [[
std::unique_ptr<{}> {} = std::make_unique<{}>({});
]],
      { i(1, "Type"), i(2, "ptr"), rep(1), i(3, "") }
    )
  ),

  s(
    "shared",
    fmt(
      [[
std::shared_ptr<{}> {} = std::make_shared<{}>({});
]],
      { i(1, "Type"), i(2, "ptr"), rep(1), i(3, "") }
    )
  ),
})

-- Common snippets for all languages
ls.add_snippets("all", {
  -- File header
  s(
    "header",
    fmt(
      [[
/**
 * File: {}
 * Author: {}
 * Date: {}
 * Description: {}
 */

{}
]],
      {
        f(function()
          return vim.fn.expand("%:t")
        end),
        f(get_author),
        f(get_current_date),
        i(1, "File description"),
        i(2, ""),
      }
    )
  ),

  -- TODO comment
  s(
    "todo",
    fmt(
      [[
// TODO: {}
]],
      { i(1, "description") }
    )
  ),

  -- FIXME comment
  s(
    "fixme",
    fmt(
      [[
// FIXME: {}
]],
      { i(1, "description") }
    )
  ),

  -- NOTE comment
  s(
    "note",
    fmt(
      [[
// NOTE: {}
]],
      { i(1, "description") }
    )
  ),
})

-- Load additional language-specific snippets
local go_snippets = require("config.snippets.go")
local cpp_snippets = require("config.snippets.cpp")

-- Add language-specific snippets
for _, snippet in ipairs(go_snippets) do
  ls.add_snippets("go", { snippet })
end

for _, snippet in ipairs(cpp_snippets) do
  ls.add_snippets("cpp", { snippet })
end

-- Load friendly snippets
require("luasnip.loaders.from_vscode").lazy_load()

-- Load snippet manager
require("config.snippet-manager")

