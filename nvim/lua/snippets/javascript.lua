-- Custom JavaScript snippets configuration for LuaSnip

local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

ls.add_snippets("javascript", {
  -- Console log
  s(
    "cl",
    fmt(
      [[
console.log({});
]],
      { i(1, "value") }
    )
  ),

  -- Console log with label
  s(
    "cll",
    fmt(
      [[
console.log("{}: ", {});
]],
      { i(1, "label"), i(2, "value") }
    )
  ),

  -- Arrow function
  s(
    "af",
    fmt(
      [[
const {} = ({}) => {{
  {}
}};
]],
      { i(1, "functionName"), i(2, ""), i(3, "// TODO: implement") }
    )
  ),

  -- Arrow function (concise body)
  s(
    "afc",
    fmt(
      [[
const {} = ({}) => {};
]],
      { i(1, "functionName"), i(2, ""), i(3, "expression") }
    )
  ),

  -- Named function
  s(
    "func",
    fmt(
      [[
function {}({}) {{
  {}
}}
]],
      { i(1, "functionName"), i(2, ""), i(3, "// TODO: implement") }
    )
  ),

  -- Async function
  s(
    "afn",
    fmt(
      [[
async function {}({}) {{
  {}
}}
]],
      { i(1, "functionName"), i(2, ""), i(3, "// TODO: implement") }
    )
  ),

  -- Async arrow function
  s(
    "aaf",
    fmt(
      [[
const {} = async ({}) => {{
  {}
}};
]],
      { i(1, "functionName"), i(2, ""), i(3, "// TODO: implement") }
    )
  ),

  -- Try-catch
  s(
    "try",
    fmt(
      [[
try {{
  {}
}} catch ({}) {{
  {}
}}
]],
      { i(1, "// code"), i(2, "error"), i(3, "console.error(error);") }
    )
  ),

  -- Try-catch-finally
  s(
    "tryf",
    fmt(
      [[
try {{
  {}
}} catch ({}) {{
  {}
}} finally {{
  {}
}}
]],
      { i(1, "// code"), i(2, "error"), i(3, "console.error(error);"), i(4, "// cleanup") }
    )
  ),

  -- Promise
  s(
    "prom",
    fmt(
      [[
new Promise((resolve, reject) => {{
  {}
}});
]],
      { i(1, "// async operation") }
    )
  ),

  -- Async/Await fetch
  s(
    "fetch",
    fmt(
      [[
const {} = await fetch("{}"{});
const {} = await {}.json();
]],
      { i(1, "response"), i(2, "url"), i(3, ""), i(4, "data"), rep(1) }
    )
  ),

  -- Fetch with options
  s(
    "fetchp",
    fmt(
      [[
const {} = await fetch("{}", {{
  method: "{}",
  headers: {{
    "Content-Type": "application/json",
  }},
  body: JSON.stringify({}),
}});
const {} = await {}.json();
]],
      { i(1, "response"), i(2, "url"), i(3, "POST"), i(4, "data"), i(5, "result"), rep(1) }
    )
  ),

  -- Import
  s(
    "imp",
    fmt(
      [[
import {} from "{}";
]],
      { i(1, "module"), i(2, "package") }
    )
  ),

  -- Import destructured
  s(
    "impd",
    fmt(
      [[
import {{ {} }} from "{}";
]],
      { i(1, "module"), i(2, "package") }
    )
  ),

  -- Export default
  s(
    "expd",
    fmt(
      [[
export default {};
]],
      { i(1, "value") }
    )
  ),

  -- Export named
  s(
    "expn",
    fmt(
      [[
export {{ {} }};
]],
      { i(1, "value") }
    )
  ),

  -- Class
  s(
    "class",
    fmt(
      [[
class {} {{
  constructor({}) {{
    {}
  }}

  {}
}}
]],
      { i(1, "ClassName"), i(2, ""), i(3, "// initialize"), i(4, "// methods") }
    )
  ),

  -- Class extending
  s(
    "classe",
    fmt(
      [[
class {} extends {} {{
  constructor({}) {{
    super({});
    {}
  }}

  {}
}}
]],
      { i(1, "ClassName"), i(2, "ParentClass"), i(3, ""), i(4, ""), i(5, "// initialize"), i(6, "// methods") }
    )
  ),

  -- Array methods: map
  s(
    "map",
    fmt(
      [[
{}.map(({}) => {{
  {}
}});
]],
      { i(1, "array"), i(2, "item"), i(3, "return item;") }
    )
  ),

  -- Array methods: filter
  s(
    "filter",
    fmt(
      [[
{}.filter(({}) => {{
  {}
}});
]],
      { i(1, "array"), i(2, "item"), i(3, "return true;") }
    )
  ),

  -- Array methods: reduce
  s(
    "reduce",
    fmt(
      [[
{}.reduce(({}, {}) => {{
  {}
}}, {});
]],
      { i(1, "array"), i(2, "acc"), i(3, "item"), i(4, "return acc;"), i(5, "initialValue") }
    )
  ),

  -- Array methods: forEach
  s(
    "foreach",
    fmt(
      [[
{}.forEach(({}) => {{
  {}
}});
]],
      { i(1, "array"), i(2, "item"), i(3, "// process item") }
    )
  ),

  -- Array methods: find
  s(
    "find",
    fmt(
      [[
{}.find(({}) => {});
]],
      { i(1, "array"), i(2, "item"), i(3, "item === value") }
    )
  ),

  -- Object destructuring
  s(
    "dest",
    fmt(
      [[
const {{ {} }} = {};
]],
      { i(1, "prop"), i(2, "object") }
    )
  ),

  -- Array destructuring
  s(
    "desta",
    fmt(
      [[
const [{}] = {};
]],
      { i(1, "first, second"), i(2, "array") }
    )
  ),

  -- Template literal
  s(
    "tl",
    fmt(
      [[
`{}`
]],
      { i(1, "${expression}") }
    )
  ),

  -- Ternary operator
  s(
    "tern",
    fmt(
      [[
{} ? {} : {};
]],
      { i(1, "condition"), i(2, "trueValue"), i(3, "falseValue") }
    )
  ),

  -- setTimeout
  s(
    "timeout",
    fmt(
      [[
setTimeout(() => {{
  {}
}}, {});
]],
      { i(1, "// callback"), i(2, "1000") }
    )
  ),

  -- setInterval
  s(
    "interval",
    fmt(
      [[
const {} = setInterval(() => {{
  {}
}}, {});
]],
      { i(1, "timer"), i(2, "// callback"), i(3, "1000") }
    )
  ),

  -- Event listener
  s(
    "event",
    fmt(
      [[
{}.addEventListener("{}", ({}) => {{
  {}
}});
]],
      { i(1, "element"), i(2, "click"), i(3, "event"), i(4, "// handler") }
    )
  ),

  -- For...of loop
  s(
    "forof",
    fmt(
      [[
for (const {} of {}) {{
  {}
}}
]],
      { i(1, "item"), i(2, "iterable"), i(3, "// body") }
    )
  ),

  -- For...in loop
  s(
    "forin",
    fmt(
      [[
for (const {} in {}) {{
  {}
}}
]],
      { i(1, "key"), i(2, "object"), i(3, "// body") }
    )
  ),

  -- Switch statement
  s(
    "switch",
    fmt(
      [[
switch ({}) {{
  case {}:
    {}
    break;
  case {}:
    {}
    break;
  default:
    {}
}}
]],
      { i(1, "expression"), i(2, '"value1"'), i(3, "// case 1"), i(4, '"value2"'), i(5, "// case 2"), i(6, "// default") }
    )
  ),

  -- Immediately Invoked Function Expression (IIFE)
  s(
    "iife",
    fmt(
      [[
(() => {{
  {}
}})();
]],
      { i(1, "// code") }
    )
  ),

  -- Getter/Setter
  s(
    "getset",
    fmt(
      [[
get {}() {{
  return this._{};
}}

set {}({}) {{
  this._{} = {};
}}
]],
      { i(1, "property"), rep(1), rep(1), i(2, "value"), rep(1), rep(2) }
    )
  ),

  -- Proxy
  s(
    "proxy",
    fmt(
      [[
const {} = new Proxy({}, {{
  get(target, prop) {{
    {}
    return target[prop];
  }},
  set(target, prop, value) {{
    {}
    target[prop] = value;
    return true;
  }},
}});
]],
      { i(1, "proxy"), i(2, "target"), i(3, "// get trap"), i(4, "// set trap") }
    )
  ),

  -- Generator function
  s(
    "gen",
    fmt(
      [[
function* {}({}) {{
  {}
}}
]],
      { i(1, "generatorName"), i(2, ""), i(3, "yield value;") }
    )
  ),

  -- Symbol
  s(
    "sym",
    fmt(
      [[
const {} = Symbol("{}");
]],
      { i(1, "sym"), i(2, "description") }
    )
  ),

  -- WeakMap
  s(
    "wmap",
    fmt(
      [[
const {} = new WeakMap();
{}.set({}, {});
]],
      { i(1, "weakMap"), rep(1), i(2, "key"), i(3, "value") }
    )
  ),

  -- Error class
  s(
    "err",
    fmt(
      [[
class {} extends Error {{
  constructor(message{}) {{
    super(message);
    this.name = "{}";
    {}
  }}
}}
]],
      { i(1, "CustomError"), i(2, ""), rep(1), i(3, "// additional properties") }
    )
  ),

  -- Describe test block (Jest/Vitest)
  s(
    "desc",
    fmt(
      [[
describe("{}", () => {{
  {}
}});
]],
      { i(1, "description"), i(2, "// tests") }
    )
  ),

  -- It test block (Jest/Vitest)
  s(
    "it",
    fmt(
      [[
it("{}", () => {{
  {}
}});
]],
      { i(1, "should do something"), i(2, "// assertion") }
    )
  ),

  -- Async it test block
  s(
    "ita",
    fmt(
      [[
it("{}", async () => {{
  {}
}});
]],
      { i(1, "should do something"), i(2, "// assertion") }
    )
  ),

  -- Expect assertion
  s(
    "exp",
    fmt(
      [[
expect({}).{}({});
]],
      { i(1, "value"), i(2, "toBe"), i(3, "expected") }
    )
  ),

  -- beforeEach/afterEach
  s(
    "before",
    fmt(
      [[
beforeEach(() => {{
  {}
}});
]],
      { i(1, "// setup") }
    )
  ),

  s(
    "after",
    fmt(
      [[
afterEach(() => {{
  {}
}});
]],
      { i(1, "// teardown") }
    )
  ),

  -- Express route handler
  s(
    "route",
    fmt(
      [[
{}.{}("{}", {}(req, res) => {{
  {}
}});
]],
      {
        i(1, "router"),
        c(2, { t("get"), t("post"), t("put"), t("patch"), t("delete") }),
        i(3, "/path"),
        c(4, { t(""), t("async ") }),
        i(5, 'res.json({ message: "OK" });'),
      }
    )
  ),

  -- Express middleware
  s(
    "mid",
    fmt(
      [[
const {} = (req, res, next) => {{
  {}
  next();
}};
]],
      { i(1, "middleware"), i(2, "// middleware logic") }
    )
  ),

  -- Module pattern
  s(
    "mod",
    fmt(
      [[
const {} = (() => {{
  {}

  return {{
    {}
  }};
}})();
]],
      { i(1, "module"), i(2, "// private"), i(3, "// public API") }
    )
  ),

  -- Object.keys/values/entries
  s(
    "okeys",
    fmt(
      [[
Object.keys({}).forEach(({}) => {{
  {}
}});
]],
      { i(1, "object"), i(2, "key"), i(3, "// body") }
    )
  ),

  -- Promise.all
  s(
    "pall",
    fmt(
      [[
const [{}] = await Promise.all([
  {},
]);
]],
      { i(1, "results"), i(2, "// promises") }
    )
  ),

  -- Debounce function
  s(
    "debounce",
    fmt(
      [[
function debounce(fn, delay = {}) {{
  let timeoutId;
  return (...args) => {{
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn(...args), delay);
  }};
}}
]],
      { i(1, "300") }
    )
  ),

  -- Throttle function
  s(
    "throttle",
    fmt(
      [[
function throttle(fn, limit = {}) {{
  let inThrottle;
  return (...args) => {{
    if (!inThrottle) {{
      fn(...args);
      inThrottle = true;
      setTimeout(() => (inThrottle = false), limit);
    }}
  }};
}}
]],
      { i(1, "300") }
    )
  ),
})

-- Also add these snippets for TypeScript (extends JavaScript)
ls.add_snippets("javascriptreact", {}, { key = "javascriptreact_from_js" })
ls.filetype_extend("javascriptreact", { "javascript" })
ls.filetype_extend("typescript", { "javascript" })
ls.filetype_extend("typescriptreact", { "javascript" })
