# 安装必要的包（如果尚未安装）
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("ggExtra")) install.packages("ggExtra")

# 加载包
library(ggplot2)
library(ggExtra)

# 读取数据
scatter_data <- read.csv("nanoplot/scatter_data.csv")

# 创建基础的 ggplot2 散点图
p <- ggplot(scatter_data, aes(x = x/1000, y = y)) +  # 将x轴除以1000转换为kbp
  geom_point(color = "#4682B4", alpha = 0.7) +  # 使用相同的蓝色和透明度
  theme_bw() +  # 使用黑白主题
  labs(
    title = "Read lengths vs Average read quality",
    x = "Read Length (kbp)",  # 修改x轴标签
    y = "Average read quality"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 14),  # 居中的标题
    axis.title = element_text(size = 12),               # 轴标题字体大小
    axis.text = element_text(size = 10)                 # 轴刻度字体大小
  )

# 使用 ggMarginal 添加边缘直方图
p2 <- ggMarginal(p, type = "histogram", 
          fill = "#4682B4",     # 使用相同的蓝色
          color = NA,           # 去掉描边
          alpha = 0.7,          # 相同的透明度
          size = 8,             # 直方图的大小
          margins = "both",     # 同时显示两个边缘图
          gridlines = FALSE,    # 不显示网格线
          bins = 100,           # 增加箱子的数量以提高精度
          xparams = list(panel.border = element_rect(color = "black", fill = NA)),  # x轴直方图边框
          yparams = list(panel.border = element_rect(color = "black", fill = NA)))  # y轴直方图边框

# 保存图片
ggsave("nanoplot/Read lengths vs Average read quality plot using dots.svg", p2, width = 4, height = 4)  # 使用相同的尺寸比例，保存为SVG格式