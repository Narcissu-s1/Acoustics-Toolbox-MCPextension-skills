function msg = at_run_model(filename, model_type)
% at_run_model  运行传播模型 (BELLHOP/KRAKEN)
at_init();
model_type = upper(model_type);

switch model_type
    case 'BELLHOP'
        bellhop(filename);
        msg = sprintf('BELLHOP 计算完成');
    case 'KRAKEN'
        kraken(filename);
        msg = sprintf('KRAKEN 计算完成');
    case 'KRAKENC'
        krakenc(filename);
        msg = sprintf('KRAKENC 计算完成');
    case 'SCOOTER'
        scooter(filename);
        msg = sprintf('SCOOTER 计算完成');
    otherwise
        error('不支持的模型类型: %s', model_type);
end

% 检查输出文件
exts = {'.shd', '.ray', '.arr', '.mod', '.prt'};
found = {};
for i = 1:length(exts)
    if isfile([filename exts{i}])
        found{end+1} = [filename exts{i}];
    end
end
if ~isempty(found)
    [~, fname, ~] = fileparts(filename);
    out_files = strjoin(found, ', ');
    msg = [msg, sprintf('\n生成文件: %s', out_files)];
else
    msg = [msg, sprintf('\n注意: 未检测到输出文件，请检查环境文件参数')];
end
end
