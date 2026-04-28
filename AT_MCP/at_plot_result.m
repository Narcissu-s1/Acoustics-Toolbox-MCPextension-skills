function msg = at_plot_result(filename, plot_type)
% at_plot_result  绘制并保存计算结果
at_init();
output_path = [filename '_' plot_type '.png'];

switch lower(plot_type)
    case 'shd'
        plotshd([filename '.shd']);
        title([filename ' — 传播损失']);
        colorbar;
        saveas(gcf, output_path);
        close(gcf);
        msg = sprintf('传播损失图已保存: %s', output_path);

    case 'ray'
        plotray([filename '.ray']);
        title([filename ' — 射线轨迹']);
        saveas(gcf, output_path);
        close(gcf);
        msg = sprintf('射线轨迹图已保存: %s', output_path);

    case 'arr'
        plotarr([filename '.arr']);
        title([filename ' — 到达结构']);
        saveas(gcf, output_path);
        close(gcf);
        msg = sprintf('到达结构图已保存: %s', output_path);

    case 'mode'
        if isfile([filename '.mod'])
            plotmode([filename '.mod']);
            title([filename ' — 简正波模态']);
            saveas(gcf, output_path);
            close(gcf);
            msg = sprintf('模态图已保存: %s', output_path);
        else
            msg = '错误: 未找到 .mod 文件 (运行 KRAKEN 后生成)';
        end

    otherwise
        error('不支持的绘图类型: %s (支持: shd, ray, arr, mode)', plot_type);
end

fprintf('%s\n', msg);
end
