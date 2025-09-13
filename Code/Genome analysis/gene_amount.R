# 检查并安装必要的包
if (!require("svglite")) install.packages("svglite")
if (!require("patchwork")) install.packages("patchwork")
if (!require("scales")) install.packages("scales")

library(tidyverse)
library(patchwork)  # 显式加载patchwork包
library(scales)  # 加载scales包以使用alpha函数

# 读取颜色映射数据
color_mapping <- read_tsv("colors.tsv") %>%
  deframe()  # 将数据框转换为命名向量

# 读取基因数量检出数据
data <- read_tsv("基因数量检出情况.tsv") %>%
  pivot_longer(
    cols = c(CDS, tRNA, rRNA),
    names_to = "GeneType",
    values_to = "Count"
  )

# 创建分面绘图函数
create_facet_plot <- function(gene_type, add_ylab = FALSE) {  # 添加参数控制是否显示y轴标签
  p <- data %>%
    filter(GeneType == gene_type) %>%
    ggplot(aes(x = Method, y = Count, color = Strain, group = Strain)) +
    geom_line(linewidth = 1) +
    geom_point(size = 3) +
    scale_color_manual(values = setNames(
      alpha(unname(color_mapping), 0.6),  # 为所有颜色添加0.7透明度
      names(color_mapping)
    )) +
    facet_wrap(~GeneType, scales = "free_y") +
    theme_minimal(base_size = 14) +
    theme(
      axis.text.x = element_text(angle = -45, hjust = 0, vjust = 0.5),
      panel.grid.minor = element_blank(),
      legend.position = "right",
      legend.direction = "vertical",
      legend.title = element_blank(),  # 删除图例标题
      axis.title.x = element_blank(),    # 只删除x轴标题
      strip.background = element_blank(),  # 删除分面标签背景
      panel.border = element_rect(color = "black", fill = NA, linewidth = 1)  # 添加边框
    )
    
  if (add_ylab) {
    p <- p + ylab("Count")  # 只为指定的图添加y轴标签
  } else {
    p <- p + theme(axis.title.y = element_blank())  # 其他图删除y轴标签
  }
  
  return(p)
}

# 生成三个基因类型的图表
cds_plot <- create_facet_plot("CDS", add_ylab = TRUE)  # CDS图显示y轴标签
trna_plot <- create_facet_plot("tRNA", add_ylab = FALSE)
rrna_plot <- create_facet_plot("rRNA", add_ylab = FALSE)

# 组合图表（横向排列）
combined_plot <- cds_plot + trna_plot + rrna_plot +
  plot_layout(guides = "collect", nrow = 1)

# 显示图表
print(combined_plot)

# 保存图表
dev.off() # 确保没有悬挂的图形设备
ggsave("gene_detection_comparison.svg", combined_plot, width = 10, height = 5, dpi = 300)
