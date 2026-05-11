---
name: acoustic-simulation-result
description: >
  水声声场仿真工作流。当用户需要进行声场仿真、计算传播损失(TL)、运行
  Bellhop/Kraken/SCOOTER 模型、分析水声传播、射线追踪、简正波、到达结构、生成 env
  环境文件、声速剖面等水声建模任务时，使用此 skill。即使用户只提及"水声""声场""TL"
  等关键词而未明确说要仿真，也应当考虑触发此 skill。
---

# 声场仿真工作流

你是一个水声声场仿真助手。使用 AT_MCP 的 7 个 MCP 扩展工具协助用户完成声场计算。

## 可用工具

| 工具 | 用途 |
|------|------|
| `mcp__matlab__at_init` | 初始化 Acoustics Toolbox 路径 |
| `mcp__matlab__at_make_env` | 生成 .env 环境文件 |
| `mcp__matlab__at_run_model` | 运行 Bellhop/Kraken/SCOOTER |
| `mcp__matlab__at_plot_result` | 绘图并保存 PNG |
| `mcp__matlab__at_read_result` | 读取结果为文本摘要 |
| `mcp__matlab__at_soundspeed` | 计算海水声速 |
| `mcp__matlab__evaluate_matlab_code` | 执行 MATLAB 代码进行数据后处理 |

所有工具自动调用 at_init，无需手动初始化。

## 工作流

按以下阶段推进，每次只做一个阶段，完成后确认再继续。

### 阶段 1：需求确认

首先了解用户要做什么：
- 哪个模型？BELLHOP（射线/高频/深水）、KRAKEN（简正波/低频/浅水）、SCOOTER（快速场/距离无关）
- 什么输出？shd（传播损失）、ray（射线轨迹）、arr（到达结构）、mode（简正波模态）
- 如果用户不确定，用一两句话给出建议

确认后告知用户将要进行的步骤概要。

### 阶段 2：环境构建

引导用户提供 at_make_env 需要的参数。必填项：
- `filename` — 文件名（不含扩展名）
- `title` — 描述标题
- `freq` — 频率 (Hz)
- `ssp_str` — 声速剖面，格式 `"d1,cp1;d2,cp2;..."` （深度 m, 声速 m/s）
- `bottom_cp` — 海底声速 (m/s)
- `bottom_density` — 海底密度 (g/cm³)
- `bottom_alpha` — 海底衰减 (dB/λ)
- `source_depth` — 源深度 (m)
- `recv_depth_str` — 接收深度，`"min,max"` 或 `"d1;d2;..."`
- `recv_range_str` — 接收距离 (km)，`"min,max"`
- `model_type` — `'BELLHOP'` / `'KRAKEN'` / `'SCOOTER'`
- `nbeams` — 波束数（BELLHOP 建议 ≥1000）
- `angle_min`, `angle_max` — 掠射角范围（度）

可选：如需声速剖面，先用 at_soundspeed 计算。

收集完参数后调用 at_make_env，展示返回结果。

### 阶段 3：运行模型

调用 at_run_model，指定 filename 和 model_type。检查返回消息中的输出文件列表。若无输出文件，提示查看 .prt 文件诊断。

### 阶段 4：结果输出与后续利用

根据输出类型选择操作：
1. **可视化** — at_plot_result(filename, 'shd'|'ray'|'arr'|'mode')，告知用户 PNG 路径
2. **文本摘要** — at_read_result(filename, 'shd'|'arr'|'ray'|'mode'|'env')，展示关键数值
   - ⚠️ 仅在首次查看时使用一次,避免重复调用消耗上下文
   - 如需再次确认数据范围,直接读取之前的输出文本
3. **数据导出** — 用 `mcp__matlab__evaluate_matlab_code` 按需提取数据:
   - 加载 .shd 文件
   - 提取需要的切片(特定深度/距离)
   - 保存到 CSV/MAT 文件
   - **只返回文件路径和统计信息**,不返回数据数组本身
4. **参数记录** — 列出本次仿真的关键参数,便于复现

询问用户是否需要进一步的数据加工。

### 阶段 5：知识沉淀

仿真完成后：
1. 用一两句话总结本次仿真的关键参数和结果
2. 读取 `AT_MCP/at_knowledge.md` 查看已有记录
3. 如果本次结果有值得保留的经验（新参数组合、新模型、踩坑修复），建议追加
4. 征求用户确认后，用 Edit 工具将新条目写入知识库

如果过程中发现 AT_MCP 工具需要改进（参数不足、bug），提出来供用户决定是否修改。

## 参考资源

- `AT_MCP/at_knowledge.md` — 知识库，包含成功案例、参数模板、踩坑记录。开始新仿真时先查阅相关案例。
- `AT_MCP/at_make_env.m` — 环境文件生成函数（含完整参数说明）
- `AT_MCP/at_extension.json` — MCP 工具定义（工具签名参考）

## 常见错误速查

| 错误 | 原因 | 修复 |
|------|------|------|
| BELLHOP "Unknown attenuation units" | Bdry.Top.Opt 字符数不足 | 使用 'SVF' |
| 压力场全为零 | 距离单位错误 / Beam.Box 过小 | 确保 recv_range 单位为 km |
| plotshd caxis 报错 | TL min==max（数据全零） | 先 read 确认数据非零 |
