-- Custom C++ snippets configuration for LuaSnip

local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local f = ls.function_node
local t = ls.text_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

-- Helper functions
local function get_filename()
  return vim.fn.expand("%:t:r")
end

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

  -- RAII class
  s(
    "raii",
    fmt(
      [[
class {} {{
private:
    {}* {};

public:
    explicit {}({}* ptr) : {}(ptr) {{}}
    
    ~{}() {{
        delete {};
        {} = nullptr;
    }}
    
    // Delete copy constructor and assignment
    {}(const {}&) = delete;
    {}& operator=(const {}&) = delete;
    
    // Move constructor and assignment
    {}({}&& other) noexcept : {}(other.{}) {{
        other.{} = nullptr;
    }}
    
    {}& operator=({}&& other) noexcept {{
        if (this != &other) {{
            delete {};
            {} = other.{};
            other.{} = nullptr;
        }}
        return *this;
    }}
    
    {}* get() const {{ return {}; }}
    {}& operator*() const {{ return *{}; }}
    {}* operator->() const {{ return {}; }}
}};
]],
      {
        i(1, "ResourceManager"),
        i(2, "Resource"),
        i(3, "resource"),
        rep(1),
        rep(2),
        rep(3),
        rep(1),
        rep(3),
        rep(3),
        rep(1),
        rep(1),
        rep(1),
        rep(1),
        rep(1),
        rep(1),
        rep(3),
        rep(3),
        rep(3),
        rep(1),
        rep(1),
        rep(3),
        rep(3),
        rep(3),
        rep(3),
        rep(2),
        rep(3),
        rep(2),
        rep(3),
        rep(2),
        rep(3),
      }
    )
  ),

  -- Singleton pattern
  s(
    "singleton",
    fmt(
      [[
class {} {{
private:
    {}() = default;
    
public:
    static {}& getInstance() {{
        static {} instance;
        return instance;
    }}
    
    // Delete copy constructor and assignment
    {}(const {}&) = delete;
    {}& operator=(const {}&) = delete;
    
    {}
}};
]],
      {
        i(1, "Singleton"),
        rep(1),
        rep(1),
        rep(1),
        rep(1),
        rep(1),
        rep(1),
        rep(1),
        i(2, "// Public methods"),
      }
    )
  ),

  -- Observer pattern
  s(
    "observer",
    fmt(
      [[
class {} {{
public:
    virtual ~{}() = default;
    virtual void update({}) = 0;
}};

class {} {{
private:
    std::vector<{}*> observers;
    
public:
    void addObserver({}* observer) {{
        observers.push_back(observer);
    }}
    
    void removeObserver({}* observer) {{
        observers.erase(std::remove(observers.begin(), observers.end(), observer), observers.end());
    }}
    
    void notifyObservers({}) {{
        for (auto* observer : observers) {{
            observer->update({});
        }}
    }}
}};
]],
      {
        i(1, "Observer"),
        rep(1),
        i(2, "const Event& event"),
        i(3, "Subject"),
        rep(1),
        rep(1),
        rep(1),
        rep(2),
        rep(2),
      }
    )
  ),

  -- Thread pool
  s(
    "threadpool",
    fmt(
      [[
class {} {{
private:
    std::vector<std::thread> workers;
    std::queue<std::function<void()>> tasks;
    std::mutex queueMutex;
    std::condition_variable condition;
    bool stop;
    
public:
    explicit {}(size_t threads) : stop(false) {{
        for (size_t i = 0; i < threads; ++i) {{
            workers.emplace_back([this] {{
                for (;;) {{
                    std::function<void()> task;
                    {{
                        std::unique_lock<std::mutex> lock(this->queueMutex);
                        this->condition.wait(lock, [this] {{ return this->stop || !this->tasks.empty(); }});
                        
                        if (this->stop && this->tasks.empty()) {{
                            return;
                        }}
                        
                        task = std::move(this->tasks.front());
                        this->tasks.pop();
                    }}
                    task();
                }}
            }});
        }}
    }}
    
    template<class F, class... Args>
    auto enqueue(F&& f, Args&&... args) -> std::future<typename std::result_of<F(Args...)>::type> {{
        using return_type = typename std::result_of<F(Args...)>::type;
        
        auto task = std::make_shared<std::packaged_task<return_type()>>(
            std::bind(std::forward<F>(f), std::forward<Args>(args)...)
        );
        
        std::future<return_type> res = task->get_future();
        {{
            std::unique_lock<std::mutex> lock(queueMutex);
            
            if (stop) {{
                throw std::runtime_error("enqueue on stopped ThreadPool");
            }}
            
            tasks.emplace([task]() {{ (*task)(); }});
        }}
        condition.notify_one();
        return res;
    }}
    
    ~{}() {{
        {{
            std::unique_lock<std::mutex> lock(queueMutex);
            stop = true;
        }}
        condition.notify_all();
        for (std::thread &worker : workers) {{
            worker.join();
        }}
    }}
}};
]],
      { i(1, "ThreadPool"), rep(1), rep(1) }
    )
  ),

  -- STL algorithm usage
  s(
    "stl",
    fmt(
      [[
// {}
std::{}({}.begin(), {}.end(), {});
]],
      {
        c(1, {
          t("Find element"),
          t("Sort container"),
          t("Transform elements"),
          t("Filter elements"),
          t("Accumulate values"),
        }),
        c(2, {
          t("find"),
          t("sort"),
          t("transform"),
          t("copy_if"),
          t("accumulate"),
        }),
        i(3, "container"),
        rep(3),
        i(4, "predicate"),
      }
    )
  ),

  -- Lambda expression
  s(
    "lambda",
    fmt(
      [[
auto {} = [{}]({}) -> {} {{
    {}
}};
]],
      { i(1, "lambda"), i(2, "capture"), i(3, "params"), i(4, "return_type"), i(5, "// body") }
    )
  ),

  -- Exception class
  s(
    "exception",
    fmt(
      [[
class {} : public std::exception {{
private:
    std::string message;
    
public:
    explicit {}(const std::string& msg) : message(msg) {{}}
    
    const char* what() const noexcept override {{
        return message.c_str();
    }}
}};
]],
      { i(1, "CustomException"), rep(1) }
    )
  ),
})
