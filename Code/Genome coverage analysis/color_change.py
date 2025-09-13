import re

# 读取颜色映射
color_map = {}
with open('colors.tsv', 'r') as f:
    # 跳过标题行
    next(f)
    for line in f:
        name, color = line.strip().split('\t')
        color_map[name] = color

# 读取SVG文件
with open('coverage_plot.svg', 'r') as f:
    svg_content = f.read()

# 当前使用的颜色和对应的菌株名称
current_colors = {
    '#DB8E00': 'CF1807',
    '#AEA200': 'CF2206',
    '#F8766D': 'CFA1707',
    '#64B200': 'IC25',
    '#00BD5C': 'IC7-2',
    '#00C1A7': 'JH25',
    '#00BADE': 'NB04',
    '#00A6FF': 'SL-V18',
    '#EF67EB': 'YTE70',
    '#B385FF': 'YTF44-1',
    '#FF63B6': 'ZN2'
}

# 替换颜色
for old_color, strain in current_colors.items():
    new_color = color_map[strain]
    svg_content = svg_content.replace(old_color, new_color)

# 保存修改后的SVG文件
with open('coverage_plot_new.svg', 'w') as f:
    f.write(svg_content)

print("颜色替换完成，新文件已保存为 coverage_plot_new.svg")
