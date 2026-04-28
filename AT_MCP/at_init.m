function at_init()
% at_init 初始化 Acoustics Toolbox 路径（重复调用安全）

persistent initialized
if ~isempty(initialized)
    return;
end

% 自动定位：mcp_dir = AT_MCP/，project_dir = 项目根目录
mcp_dir = fileparts(mfilename('fullpath'));
project_dir = fileparts(mcp_dir);
cd(project_dir);
addpath(mcp_dir);

at_root = 'D:\学习研究\水声专业课\计算海洋声学\AT2020\atWin10_2020_11_4\atWin10_2020_11_4';

addpath(at_root);
addpath(fullfile(at_root, 'Matlab'));
addpath(fullfile(at_root, 'Matlab', 'ReadWrite'));
addpath(fullfile(at_root, 'Matlab', 'Plot'));
addpath(fullfile(at_root, 'Matlab', 'Misc'));
addpath(fullfile(at_root, 'Matlab', 'Bellhop'));
addpath(fullfile(at_root, 'Matlab', 'Kraken'));
addpath(fullfile(at_root, 'Matlab', 'Scooter'));

% 二进制文件路径
bin_dir = fullfile(at_root, 'windows-bin-20201102');
setenv('PATH', [getenv('PATH') ';' bin_dir]);

initialized = true;
fprintf('Acoustics Toolbox 初始化完成\n');
end
