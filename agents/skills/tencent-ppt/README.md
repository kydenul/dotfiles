# tencent-ppt

**tencent-ppt** 是一个演示文稿生成技能，可以将用户的内容需求直接生成为基于 HTML 的幻灯片，遵循[腾讯官方 PPT 模板](https://dcloud.woa.com/wiki/vi_tencent/22654)设计规范（TencentSans 字体、品牌配色、16:9 比例画布）。

**功能：**
- 生成完整幻灯片项目：封面、目录、章节页、内容页、结尾页
- 支持 15+ 种内容布局：文字、图片、视频、图表、卡片、时间线、对比、引用等
- 内置幻灯片播放器：键盘翻页、全屏、缩略图概览（G 键）
- 支持嵌入本地图片/视频和远程 URL
- 支持 PDF 导出（需启动预览服务）
- 指哪改哪：在 CodeBuddy 中启动预览，可通过 [AI 视觉优化](https://www.codebuddy.cn/docs/ide/User-guide/preview#ai-%E8%A7%86%E8%A7%89%E4%BC%98%E5%8C%96) 选中任意元素交给 AI 迭代

**生成样例：**
- [AI对劳动力市场的影响_Anthropic_20260306](https://doc.weixin.qq.com/pdf/d3_ASAAzAbYAF0CN2RiXds0XTRma7KCX?scode=AJEAIQdfAAoBhtYBhxASAAzAbYAF0)
- [2026年初AI智能体主要进展与影响分析20260305](https://doc.weixin.qq.com/pdf/d3_ASAAzAbYAF0CN8ZLW6aJ4Ts6pO9lP?scode=AJEAIQdfAAogEKdHJ2ASAAzAbYAF0)

**使用方法：**
1. 安装：点击上方下载，跟 CodeBuddy 说"帮我安装刚下载的skill"（古法：下载 zip 文件并解压，打开 CodeBuddy - 右上角设置 - Skills - 导入/Import Skill - 选择刚解压得到的 `tencent-ppt` 文件夹
2. 对话中说"帮我做一份腾讯风PPT"、"生成腾讯风演示文稿"、"创建腾讯风幻灯片"等即可触发
3. 生成完成后 CodeBuddy 默认会帮你打开，也可以找到 `slides-output/index.html` 用浏览器打开

**生成文件结构：**
```
slides-output/
├── index.html          # 幻灯片内容（AI 生成）
├── styles.css          # 样式（AI 生成）
└── assets/
    ├── js/app.js       # 播放引擎：翻页、全屏、概览、PDF 导出
    ├── fonts/          # TencentSans 字体文件
    └── media/          # 腾讯 Logo、装饰图案、用户的本地图片/视频
```

> 用户提供的本地图片和视频会被硬链接到 `assets/media/` 目录，在 HTML 中以相对路径引用，确保预览和 PDF 导出均正常。

**注意事项：**
- 零外部依赖：生成的幻灯片为纯 HTML/CSS/JS，无需安装任何包
- PDF 导出需启动预览服务（在 CodeBuddy 中说"帮我启动 PPT 预览"即可）
- 直接双击 `index.html` 打开也可以预览和翻页，只是 PDF 导出不可用

**更新日志：**
- 2025-03-05：初始发布
- 2026-03-05：新增 PDF 导出
- 2026-03-12：字号优化、布局完整性检查
- 2026-03-17：架构升级，字号全面上调
- 2026-03-18：HTML/CSS/JS 解耦重构；新增缩略图概览（G 键）；PDF 导出改为预览服务模式；本地媒体硬链接
