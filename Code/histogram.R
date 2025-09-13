library(ggplot2)
library(patchwork)  # 用于图形排版
library(tidyr)
library(dplyr)
library(scales)  # 用于格式化数字

# 读取颜色配置
color_df <- read.delim("nanocomp/colors.tsv", stringsAsFactors = FALSE)
colors <- setNames(color_df$color, color_df$name)

# 创建变浅的颜色
lighter_colors <- sapply(colors, function(color) {
  col <- col2rgb(color)
  rgb_color <- rgb(col[1] + (255 - col[1]) * 0.2,
                  col[2] + (255 - col[2]) * 0.2,
                  col[3] + (255 - col[3]) * 0.2,
                  maxColorValue = 255)
  return(rgb_color)
})

print("Colors from colors.tsv:")
print(color_df$name)

# 读取真实数据
raw_data <- read.delim("nanocomp/histogram.tsv", sep = "\t", stringsAsFactors = FALSE)
print("Strains from histogram.tsv:")
print(raw_data$strain)

# 检查列名
print("Column names in raw_data:")
print(colnames(raw_data))

data <- raw_data %>%
  tidyr::pivot_longer(cols = -strain, 
                      names_to = "metric", 
                      values_to = "value") %>%
  mutate(
    value = as.numeric(gsub(",", "", value)),
    strain = factor(strain, levels = names(colors))
  )

# 检查转换后的数据
print("First few rows of transformed data:")
print(head(data))
print("Unique metrics in data:")
print(unique(data$metric))

print("Levels in data$strain:")
print(levels(data$strain))
print("Names in colors vector:")
print(names(colors))

# 创建子图函数
create_plot <- function(metric_name, plot_title, y_label) {
  subset_data <- data %>% 
    filter(metric == metric_name)
  
  print(paste("Number of rows for", metric_name, ":", nrow(subset_data)))
  print("Sample of data for this metric:")
  print(head(subset_data))
  
  # 计算y轴范围
  y_max <- max(subset_data$value)
  y_limit <- y_max * 1.05  # 减少顶部空间到5%
  
  # 根据不同的指标设置不同的刻度格式
  scale_y <- if(metric_name == "Total.bases") {
    scale_y_continuous(
      labels = function(x) paste0(x/1e9, "B"),
      limits = c(0, y_limit),
      expand = expansion(mult = c(0.05, 0.05))  # 上下均匀留5%空间
    )
  } else {
    scale_y_continuous(
      labels = function(x) paste0(x/1e3, "k"),
      limits = c(0, y_limit),
      expand = expansion(mult = c(0.05, 0.05))  # 上下均匀留5%空间
    )
  }
  
  ggplot(subset_data, aes(x = strain, y = value, fill = strain)) +
    geom_bar(stat = "identity", width = 0.7) +  # 调整柱子宽度
    scale_fill_manual(values = lighter_colors) +
    scale_y + # 应用不同的刻度格式
    scale_x_discrete(expand = expansion(mult = c(0.1, 0.1))) +  # x轴两端留10%空间
    labs(title = plot_title, x = "", y = y_label) +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      legend.position = "none",
      plot.title = element_text(hjust = 0.5),  # 标题居中
      panel.grid.major.x = element_blank(),    # 移除横向主网格线
      panel.grid.minor.x = element_blank(),    # 移除横向次网格线
      panel.border = element_rect(fill = NA, color = "black"),  # 添加黑色图框
      axis.line = element_line(color = "black"),  # 添加坐标轴线
      plot.margin = margin(5, 15, 5, 15)  # 保持外边距
    )
}

# 生成三个子图并组合
p1 <- create_plot("Number.of.reads", "Comparing number of reads", "Number of reads")
p2 <- create_plot("Read.length.N50", "Comparing read length N50", "Sequenced read length N50")
p3 <- create_plot("Total.bases", "Comparing throughput in bases", "Total bases sequenced")

# 组合图形
combined_plot <- (p1 | p2 | p3) + 
  plot_layout(nrow = 1) +
  plot_annotation(
    theme = theme(
      plot.margin = margin(5, 5, 5, 5)
    )
  )

# 保存为SVG格式
ggsave("nanocomp/histogram.svg", combined_plot, width = 12, height = 4)

# 输出图形
print(combined_plot)