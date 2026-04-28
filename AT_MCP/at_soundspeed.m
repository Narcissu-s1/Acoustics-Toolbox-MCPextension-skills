function msg = at_soundspeed(S, T, D, equation)
% at_soundspeed  计算海水声速
%
% 参数:
%   S         - 盐度 (‰)
%   T         - 温度 (°C)
%   D         - 深度 (m) 或 压力 (dbar)
%   equation  - 公式: 'mackenzie'(default), 'del grosso', 'chen', 'state'

if nargin < 4
    equation = 'mackenzie';
end

c = soundspeed(S, T, D, equation);
msg = sprintf(['===== 声速计算结果 =====\n', ...
    '公式: %s\n', ...
    '输入: S=%.1f‰, T=%.1f°C, D=%.1f m\n', ...
    '声速: %.2f m/s\n'], ...
    equation, S, T, D, c);
fprintf('%s', msg);
end
