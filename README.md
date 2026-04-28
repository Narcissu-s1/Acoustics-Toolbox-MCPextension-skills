# Acoustics-Toolbox-MCPextension-skills
一个关于声学工具箱的matlabMCP拓展与声场仿真 skills

## 部署

### 步骤

从源项目复制内容到目标项目根目录：

```bash
# 在源项目内执行（Git Bash / PowerShell / WSL 均可）
TARGET="D:/my-project"
mkdir -p "$TARGET/.claude/skills/acoustic-simulation"
cp .mcp.json "$TARGET/"
cp .claude/skills/acoustic-simulation/SKILL.md "$TARGET/.claude/skills/acoustic-simulation/"
cp -r AT_MCP "$TARGET/"
```

### 目标结构

```
目标项目/
├── .mcp.json                    # MCP 配置，相对路径，无需改
├── .claude/
│   └── skills/
│       └── acoustic-simulation/
│           └── SKILL.md
└── AT_MCP/
    ├── at_extension.json        # MCP 工具定义
    ├── at_init.m                # 初始化（自动定位项目目录）
    ├── at_make_env.m            # 生成 .env 环境文件
    ├── at_run_model.m           # 运行传播模型
    ├── at_plot_result.m         # 绘制结果图
    ├── at_read_result.m         # 读取数值结果
    ├── at_soundspeed.m          # 海水声速计算
    ├── at_knowledge.md          # 知识库（案例/模板/踩坑）
    └── USAGE.md                 # 本文档
```

### 验证

```bash
# 检查 .mcp.json 使用相对路径
grep -E '(extension-file|initial-working-folder)' 目标项目/.mcp.json
# 期望输出: "./AT_MCP/at_extension.json" 和 "."

# 检查 skill 文件存在
ls 目标项目/.claude/skills/acoustic-simulation/SKILL.md
```

重启 Claude Code 后，`/context` 应显示 `mcp__matlab__at_*` 工具和 `acoustic-simulation` skill。

---

## 环境配置

以下 2 项需在每台机器上手动修改：

| 配置项 | 文件 | 字段 |
|--------|------|------|
| MATLAB 安装路径 | `.mcp.json` | `--matlab-root` |
| Acoustics Toolbox 路径 | `AT_MCP/at_init.m` | `at_root` |

`command`（`matlab-mcp-core-server.exe`）需在系统 PATH 中，否则改回绝对路径。

---

## 工具参考

所有工具名以 `mcp__matlab__` 为前缀。skill 自动加载后按工作流调用。

| 工具 | 参数 | 说明 |
|------|------|------|
| `at_init` | 无 | 所有工具自动调用，无需手动 |
| `at_make_env` | filename, title, freq, ssp_str, bottom_cp, bottom_density, bottom_alpha, source_depth, recv_depth_str, recv_range_str, model_type, nbeams, angle_min, angle_max | 生成环境文件 |
| `at_run_model` | filename, model_type | 运行 BELLHOP / KRAKEN / SCOOTER |
| `at_plot_result` | filename, plot_type | plot_type: shd / ray / arr / mode |
| `at_read_result` | filename, data_type | data_type: shd / arr / ray / mode / env |
| `at_soundspeed` | S (盐度‰), T (温度°C), D (深度 m), equation (可选) | equation: mackenzie(默认) / chen / del grosso / state |
| `evaluate_matlab_code` | MATLAB 代码字符串 | 数据后处理，加载原始数据到工作区 |

### at_make_env 参数说明

| 参数 | 类型 | 示例 | 说明 |
|------|------|------|------|
| `filename` | string | `'test'` | 不含扩展名 |
| `title` | string | `'浅水测试'` | 描述标题 |
| `freq` | number | `100` | 频率 (Hz) |
| `ssp_str` | string | `"0,1540;100,1520"` | 深度,声速对，分号分隔 |
| `bottom_cp` | number | `1600` | 海底纵波声速 (m/s) |
| `bottom_density` | number | `1.8` | 海底密度 (g/cm³) |
| `bottom_alpha` | number | `0.5` | 海底衰减 (dB/λ) |
| `source_depth` | number | `25` | 源深度 (m) |
| `recv_depth_str` | string | `"10,500"` | 接收深度: min,max → 501 点; 或 d1;d2;... |
| `recv_range_str` | string | `"0.5,10"` | 接收距离 (km) |
| `model_type` | string | `'BELLHOP'` | BELLHOP / KRAKEN / SCOOTER |
| `nbeams` | number | `2000` | 波束数（建议 ≥1000） |
| `angle_min` | number | `-15` | 最小掠射角 (度) |
| `angle_max` | number | `15` | 最大掠射角 (度) |

---

## 工作流示例

### 传播损失

```
1. "帮我做 Bellhop 声场仿真"
2. 给出参数 → at_make_env 生成 test.env
3. at_run_model('test', 'BELLHOP') → 生成 test.shd
4. at_read_result('test', 'shd')   → 查看 TL 范围，确认数据非零
5. at_plot_result('test', 'shd')   → 保存 test_shd.png
6. 将参数和结果追加到 at_knowledge.md
```

### 数据后处理

```
1. at_read_result 拿到摘要后
2. evaluate_matlab_code 加载原始 pressure 矩阵
3. 自定义分析：提取特定距离 TL 剖面、与实测数据比对
4. save('result.mat', 'press', 'Pos') 导出供 Python 使用
```

### 声速计算

```
at_soundspeed(35, 15, 100, 'mackenzie')  → S=35‰, T=15°C, D=100m, 公式=mackenzie
```

---

## 模型选择

| 模型 | 方法 | 适用 |
|------|------|------|
| BELLHOP | 射线 | ≥100 Hz，深水 |
| KRAKEN | 简正波 | <500 Hz，浅水 |
| SCOOTER | 快速场 | 距离无关环境 |

---

## 常见问题

| 现象 | 原因 | 处理 |
|------|------|------|
| BELLHOP "Unknown attenuation units" | Bdry.Top.Opt 字符数 <3 | 已内置修复为 'SVF' |
| 压力场全为零 | 距离单位或 Beam.Box 配置错误 | 确认 recv_range 以 km 为单位 |
| plotshd caxis 报错 | 数据全零导致 TL 范围为空 | 先 read 验证数据非零 |
| 未找到 .arr | 需设置 OPTIONS3='A' | 修改环境文件或 at_make_env |
| 更多 → | 见 `AT_MCP/at_knowledge.md` 踩坑记录 | |

---

## 知识库

`AT_MCP/at_knowledge.md` 与本文档互补：
- **成功案例** — 已验证的参数组合
- **参数模板** — 浅水 / 深水 / Munk 剖面预设
- **踩坑记录** — 每次 bug 的现象→原因→修复
- **经验规则** — 模型选择、参数设置建议

每次仿真完成后 skill 会提示追加。新项目部署时知识库为空（仅模板），随使用逐渐积累。
