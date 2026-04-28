# 声场仿真知识库

> 记录成功案例、参数模板、踩坑经验。每次仿真完成后追加新条目。

## 成功案例

| 日期 | 模型 | 频率(Hz) | 源深度(m) | 接收范围(km) | 接收深度(m) | 生成文件 | 备注 |
|------|------|----------|-----------|-------------|-------------|----------|------|
| 2026-04-27 | BELLHOP | 100 | 25 | 0.5~10 | 10~500 | demo.shd, demo_shd.png | 首次端到端测试通过，TL 26.0~313.1 dB |

## 参数模板

### 典型浅水场景
```
freq=500, ssp="0,1540;50,1520;100,1500", bottom_cp=1600, bottom_density=1.8
source_depth=20, recv_depth="10,100", recv_range="0.1,5"
model=KRAKEN
```

### 典型深水场景
```
freq=100, ssp="0,1540;500,1500;2000,1480;4000,1520", bottom_cp=1800, bottom_density=2.0
source_depth=200, recv_depth="10,500", recv_range="1,50"
model=BELLHOP
```

### Munk 剖面
```
freq=50, ssp="0,1530;500,1480;1300,1500;3000,1535;5000,1550", bottom_cp=1600
source_depth=1300, recv_depth="100,5000", recv_range="10,200"
model=BELLHOP, nbeams=5000, angle_min=-15, angle_max=15
```

## 踩坑记录

| 日期 | 错误现象 | 原因 | 修复 |
|------|----------|------|------|
| 2026-04-27 | BELLHOP 报错 "Unknown attenuation units" | Bdry.Top.Opt 选项字符串太短（2 字符） | 改为 'SVF'（≥3 字符） |
| 2026-04-27 | 压力场全部为零 | recv_range 单位错误（m 当 km 传入）、Beam.Box.r 过小 | 确保 parse_range 使用正确单位，Box.r 不额外除以 1000 |
| 2026-04-27 | read_shd_bin 字段访问错误 | 数据返回 Pos.r.r 而非 Pos.r.range | 使用 Pos.r.r（单位 m） |

## 经验规则

- **BELLHOP 适合高频深水**（≥100 Hz），KRAKEN 适合低频浅水（<500 Hz），100~500 Hz 重叠区间两者均可
- Bdry.Top.Opt 必须是 3 字符以上（如 'SVF'），BELLHOP 对短字符串报错
- 接收距离（recv_range）以 km 为单位传入 at_make_env
- SSP 使用分号分隔深度-声速对：`"d1,cp1;d2,cp2;..."`
- nbeams 建议至少 1000 起步，深水长距可到 5000+
- 生成输出文件后先 read 确认数据非零再 plot
