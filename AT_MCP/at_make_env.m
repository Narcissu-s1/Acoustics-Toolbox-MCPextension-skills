function msg = at_make_env(filename, title, freq, ssp_str, ...
    bottom_cp, bottom_density, bottom_alpha, ...
    source_depth, recv_depth_str, recv_range_str, ...
    model_type, nbeams, angle_min, angle_max)
% at_make_env  生成 Acoustics Toolbox 环境文件 (.env)
at_init();
%
% 参数:
%   filename        - 文件名 (不含扩展名)
%   title           - 标题文字
%   freq            - 频率 (Hz)
%   ssp_str         - 声速剖面 "depth1,cp1;depth2,cp2;..."  (m, m/s)
%   bottom_cp       - 海底声速 (m/s)
%   bottom_density  - 海底密度 (g/cm^3)
%   bottom_alpha    - 海底衰减 (dB/λ)
%   source_depth    - 源深度 (m)
%   recv_depth_str  - 接收器深度 "min,max" 或 "d1,d2,..."
%   recv_range_str  - 接收器距离 "min,max" (km)
%   model_type      - 模型: 'BELLHOP', 'KRAKEN', 'SCOOTER'
%   nbeams          - 波束数
%   angle_min       - 最小掠射角 (度)
%   angle_max       - 最大掠射角 (度)

% 解析 SSP
pairs = split(ssp_str, ';');
n = length(pairs);
z = zeros(n, 1);
cp = zeros(n, 1);
for i = 1:n
    vals = split(strtrim(pairs{i}), ',');
    z(i) = str2double(vals{1});
    cp(i) = str2double(vals{2});
end

% 构建 SSP 结构
SSP.NMedia = 1;
SSP.depth = [z(1); z(end)];
SSP.sigma = 0;
SSP.N = n;
SSP.raw(1).z = z;
SSP.raw(1).alphaR = cp;
SSP.raw(1).betaR = zeros(n, 1);
SSP.raw(1).rho = ones(n, 1);
SSP.raw(1).alphaI = zeros(n, 1);
SSP.raw(1).betaI = zeros(n, 1);

% 构建边界结构
Bdry.Top.Opt = 'SVF';

% 底部半空间
Bdry.Bot.Opt = 'A';
Bdry.Bot.HS.alphaR = bottom_cp;
Bdry.Bot.HS.betaR = 0;
Bdry.Bot.HS.rho = bottom_density;
Bdry.Bot.HS.alphaI = 0;
Bdry.Bot.HS.betaI = 0;
Bdry.Bot.sigma = 0;

% 位置结构
Pos.s.z = source_depth;
Pos.r.z = parse_range(recv_depth_str, 1);
Pos.r.range = parse_range(recv_range_str, 1);

% 波束结构
Beam.RunType = 'C';
Beam.Nbeams = nbeams;
Beam.alpha = [angle_min, angle_max];
Beam.deltas = 10;
Beam.Box.z = max(z) * 1.1;
Beam.Box.r = max(Pos.r.range) * 1.1;

% 声速区间
cInt.Low = min(cp) - 100;
cInt.High = max(cp) + 100;

% 最大距离 (km)
RMax = max(Pos.r.range) / 1000;

% 写入文件
write_env(filename, model_type, title, freq, SSP, Bdry, Pos, Beam, cInt, RMax);
msg = sprintf('环境文件 %s.env 已生成\n模型: %s, 频率: %.1f Hz, 声速点: %d', ...
    filename, upper(model_type), freq, n);
end

function vec = parse_range(str, default_unit)
% 解析 "min,max" 或 "v1,v2,..." 格式的字符串
str = strtrim(str);
if contains(str, ';')
    parts = split(str, ';');
    vec = zeros(length(parts), 1);
    for i = 1:length(parts)
        vec(i) = str2double(strtrim(parts{i}));
    end
elseif contains(str, ',')
    vals = split(str, ',');
    if length(vals) == 2
        v1 = str2double(vals{1});
        v2 = str2double(vals{2});
        npts = 501;
        vec = linspace(v1, v2, npts)';
    else
        vec = zeros(length(vals), 1);
        for i = 1:length(vals)
            vec(i) = str2double(strtrim(vals{i}));
        end
    end
else
    vec = str2double(str);
end
if default_unit == 1000 && max(vec) < 1000
    vec = vec * 1000;
end
end
