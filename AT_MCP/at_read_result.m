function msg = at_read_result(filename, data_type)
% at_read_result  读取计算结果并以文本形式返回
at_init();

switch lower(data_type)
    case 'shd'
        [PlotTitle, ~, ~, freq0, ~, Pos, press] = read_shd_bin([filename '.shd']);
        tl = -20 * log10(abs(press) + eps);
        msg = sprintf('===== 声场数据 [%s] =====\n', filename);
        msg = [msg, sprintf('标题: %s\n', strtrim(PlotTitle))];
        msg = [msg, sprintf('频率: %.2f Hz\n', freq0)];
        msg = [msg, sprintf('源深度: %.1f m\n', Pos.s.z(1))];
        msg = [msg, sprintf('接收深度: %.1f ~ %.1f m (%d 点)\n', Pos.r.z(1), Pos.r.z(end), length(Pos.r.z))];
        rvec = Pos.r.r / 1000;
        msg = [msg, sprintf('接收距离: %.2f ~ %.2f km (%d 点)\n', rvec(1), rvec(end), length(rvec))];
        msg = [msg, sprintf('传播损失: %.1f ~ %.1f dB\n', min(tl(:)), max(tl(:)))];

    case 'arr'
        if isfile([filename '.arr'])
            [a, tau, theta0, thetaR, srefl, brefl, narr, rz] = read_arrivals_asc([filename '.arr']);
            msg = sprintf('===== 到达结构 [%s] =====\n', filename);
            msg = [msg, sprintf('到达路径数: %d\n', sum(narr))];
            msg = [msg, sprintf('\n主要到达 (按振幅排序):\n')];
            [~, idx] = sort(abs(a), 'descend');
            n_show = min(10, length(idx));
            for i = 1:n_show
                j = idx(i);
                msg = [msg, sprintf('  路径%2d: 振幅=%.4f, 时延=%.3fs, 发射角=%.1f°, 到达角=%.1f°\n', ...
                    j, abs(a(j)), tau(j), theta0(j), thetaR(j))];
            end
        else
            msg = '未找到 .arr 文件 (需设置 OPTIONS3=''A'' 运行才能生成)';
        end

    case 'ray'
        if isfile([filename '.ray'])
            data = read_ray([filename '.ray']);
            msg = sprintf('===== 射线数据 [%s] =====\n', filename);
            msg = [msg, sprintf('射线数量: %d\n', length(data))];
            for i = 1:min(5, length(data))
                if isfield(data{i}, 'x')
                    msg = [msg, sprintf('  射线%2d: %d 个轨迹点\n', i, length(data{i}.x))];
                end
            end
            if length(data) > 5
                msg = [msg, sprintf('  ... 共 %d 条射线\n', length(data))];
            end
        else
            msg = '未找到 .ray 文件 (需设 OPTIONS3=''R'' 或 ''E'')';
        end

    case 'mode'
        if isfile([filename '.mod'])
            M = read_modes([filename '.mod']);
            c_phase = 2*pi*M.freqVec(1) ./ M.k;
            msg = sprintf('===== 简正波模态 [%s] =====\n', filename);
            msg = [msg, sprintf('模态数量: %d\n', M.M)];
            msg = [msg, sprintf('频率: %.2f Hz\n', M.freqVec(1))];
            msg = [msg, sprintf('深度点数: %d\n', length(M.z))];
            msg = [msg, sprintf('相速度: %.2f ~ %.2f m/s\n', min(c_phase), max(c_phase))];
        else
            msg = '未找到 .mod 文件 (需运行 KRAKEN)';
        end

    case 'env'
        if isfile([filename '.env'])
            E = read_env([filename '.env']);
            msg = sprintf('===== 环境文件 [%s] =====\n', filename);
            msg = [msg, sprintf('标题: %s\n', strrep(E.TitleEnv, '''', ''))];
            msg = [msg, sprintf('频率: %.2f Hz\n', E.freq)];
            msg = [msg, sprintf('介质层数: %d\n', E.SSP.NMedia)];
            msg = [msg, sprintf('源深度: %s m\n', num2str(E.Pos.s.z))];
        else
            msg = '未找到 .env 文件';
        end

    otherwise
        error('不支持的数据类型: %s', data_type);
end

fprintf('%s\n', msg);
end
