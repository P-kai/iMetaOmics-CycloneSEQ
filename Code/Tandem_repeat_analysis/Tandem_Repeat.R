# 加载必要的包
library(ggplot2)
library(patchwork)

# 读取数据
data <- read.delim("串联重复情况.tsv", header=TRUE, sep="\t")

# 创建左图：Copy number vs. Read Length (kb)
p1 <- ggplot(data) +
  # 先画non-spanning的点（中等大小）
  geom_point(data=subset(data, !SPANNING), 
            aes(x=Copy, y=LENGTH/1000, color=SPANNING, size=SPANNING)) +  # 转换为kb
  # 后画spanning的点（大点）
  geom_point(data=subset(data, SPANNING), 
            aes(x=Copy, y=LENGTH/1000, color=SPANNING, size=SPANNING)) +  # 转换为kb
  scale_color_manual(values=c("FALSE"="#8CB8D8", "TRUE"="#FF9999"),
                    labels=c("FALSE"="Non-spanning", "TRUE"="Spanning")) +
  scale_size_manual(values=c("FALSE"=2, "TRUE"=4),
                   labels=c("FALSE"="Non-spanning", "TRUE"="Spanning")) +
  scale_x_continuous(expand = expansion(mult = 0.1)) +  # 添加x轴两侧的空间
  labs(x="Copy Number", y="Read Length (kb)", 
       title="Copy Number vs. Read Length") +
  theme_bw() +
  theme(plot.title=element_text(hjust=0.5),
        legend.title=element_blank())

# 创建右图：Copy number vs. Phred Quality Score
p2 <- ggplot(data) +
  # 先画non-spanning的点（中等大小）
  geom_point(data=subset(data, !SPANNING), 
            aes(x=Copy, y=Q_VALUE, color=SPANNING, size=SPANNING)) +
  # 后画spanning的点（大点）
  geom_point(data=subset(data, SPANNING), 
            aes(x=Copy, y=Q_VALUE, color=SPANNING, size=SPANNING)) +
  scale_color_manual(values=c("FALSE"="#8CB8D8", "TRUE"="#FF9999"),
                    labels=c("FALSE"="Non-spanning", "TRUE"="Spanning")) +
  scale_size_manual(values=c("FALSE"=2, "TRUE"=4),
                   labels=c("FALSE"="Non-spanning", "TRUE"="Spanning")) +
  scale_x_continuous(expand = expansion(mult = 0.1)) +  # 添加x轴两侧的空间
  labs(x="Copy Number", y="Phred Quality Score", 
       title="Copy Number vs. Quality Score") +
  theme_bw() +
  theme(plot.title=element_text(hjust=0.5),
        legend.title=element_blank())

# 使用patchwork组合图形，共享图例
combined_plot <- p1 + p2 + plot_layout(guides="collect")

# 保存图片
ggsave("tandem_repeat_analysis.svg", combined_plot, width=8.6, height=4)
