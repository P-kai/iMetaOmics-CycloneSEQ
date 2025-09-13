# 加载必要的包
library(ggplot2)
library(dplyr)
library(readr)
library(RColorBrewer)

# 读取颜色映射文件
color_mapping <- read_tsv("/ifs1/User/tongzeyu/sample_reads/bgi/coverage_20250212/strain_colors.tsv", 
                          col_types = cols(
                            Strain = col_character(),
                            Color_Code = col_character()
                          ))

# 读取数据
coverage_files <- list.files(path = "/ifs1/User/tongzeyu/sample_reads/bgi/coverage_20250212/samtools_result", 
                           pattern = "\\.txt$", 
                           full.names = TRUE)

# 读取并处理所有文件
coverage_list <- list()
for(file in coverage_files) {
  print(paste("处理文件:", file))
  
  # 读取数据
  coverage_data <- read_delim(file, 
                          delim = " ",  # 使用空格作为分隔符
                          col_names = FALSE,  # 不使用第一行作为列名
                          col_types = cols(
                            X1 = col_character(),
                            X2 = col_double(),
                            X3 = col_double()
                          ),
                          show_col_types = FALSE) %>%
    rename(strain = X1, position = X2, depth = X3)  # 重命名列
  
  # 跳过空文件
  if(nrow(coverage_data) == 0) {
    print(paste("警告：跳过空文件", file))
    next
  }
  
  coverage_list[[basename(file)]] <- coverage_data
}

# 合并所有数据
all_coverage <- bind_rows(coverage_list, .id = "sample")

# 降低精度：每10000个点取平均值
all_coverage <- all_coverage %>%
  group_by(sample) %>%
  mutate(group = ceiling(row_number()/10000)) %>%  # 每10000行分为一组
  group_by(sample, group) %>%
  summarise(
    position = mean(position),
    depth = mean(depth),
    .groups = "drop"
  )

# 从文件名中提取菌株名称
all_coverage$strain <- gsub("_chr_coverage.txt", "", all_coverage$sample)

# 将菌株名称与颜色代码合并
all_coverage <- left_join(all_coverage, color_mapping, by = c("strain" = "Strain"))

# 创建深度图
p <- ggplot(all_coverage, aes(x = position/1000000, 
                             y = depth, 
                             color = strain)) +  
  geom_line(linewidth = 1, alpha = 0.7) +  
  scale_color_manual(values = setNames(color_mapping$Color_Code, color_mapping$Strain)) +  # 使用颜色映射文件中的颜色
  scale_y_continuous(limits = c(0, 600)) +  # 设置y轴范围为0-600
  scale_x_continuous(labels = scales::comma) +  # 使用普通数字格式
  theme_bw() +  # 使用黑白主题
  theme(
    legend.position = "right",  # 图例位置
    legend.title = element_blank(),  # 移除图例标题
    legend.text = element_text(size = 10),   # 图例文字大小
    axis.text = element_text(size = 10),     # 轴标签大小
    axis.title = element_text(size = 12),    # 轴标题大小
    legend.key = element_rect(fill = "white", colour = NA),  # 图例背景
    legend.key.size = unit(1, "lines")  # 图例大小
  ) +
  guides(color = guide_legend(override.aes = list(shape = 16, size = 4))) +  # 图例样式设置
  labs(
    x = "Base site (Mbp)",
    y = "Cover Depth",
    color = NULL
  )


# 保存图形
ggsave("/ifs1/User/tongzeyu/sample_reads/bgi/coverage_20250212/coverage_plot.svg", 
       p, 
       width = 10, 
       height = 5)
