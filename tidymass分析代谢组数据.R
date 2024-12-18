#####TIDYmass分析代谢组数据
#项目：spartina_microbabitat
#代码执行功能：代谢组数据定量定性分析
#使用数据：（1）60个样本的代谢组文件，格式为mzXML（2）60个样本的代谢组文件，格式为mgf（3）meta文件记录样本信息（4）代谢组公共一级二级质谱数据库
#使用软件及配置（选填）：R4.4、R包：tidymass

library(tidymass)
process_data(
  path = "/media/yyzhang/data2/shiqiang/metabolite/tidymass/pos",# 路径根据实际情况定
  polarity = "positive",
  ppm = 25.4,
  peakwidth = c(8.7, 185),
  threads = 20,
  output_tic = TRUE,
  output_bpc = TRUE,
  output_rt_correction_plot = TRUE,
  min_fraction = 0.94,
  group_for_figure = "QC",
  snthresh = 10,
  prefilter = c(3, 100),
  fitgauss = FALSE,
  integrate = 1,
  mzdiff = -0.0271,
  noise = 500,
  binSize = 0.025,
  bw = 12.4,
  fill_peaks = FALSE
)
# 加载对象
load("/media/yyzhang/data2/shiqiang/metabolite/tidymass/pos/Result/object")

# 查看metabolic features数量
object

# 获取互动图，在Rstudio中才能显示
load("/media/yyzhang/data2/shiqiang/metabolite/tidymass/pos/Result/intermediate_data/xdata2")

plot = massprocesser::plot_adjusted_rt(object = xdata2, group_for_figure = "QC", interactive = TRUE)

plot

process_data(
  path = "/media/yyzhang/data2/shiqiang/metabolite/tidymass/neg",# 路径根据实际情况定
  polarity = "negative",
  ppm = 25.4,
  peakwidth = c(8.7, 185),
  threads = 20,
  output_tic = TRUE,
  output_bpc = TRUE,
  output_rt_correction_plot = TRUE,
  min_fraction = 0.94,
  group_for_figure = "QC",
  snthresh = 10,
  prefilter = c(3, 100),
  fitgauss = FALSE,
  integrate = 1,
  mzdiff = -0.0271,
  noise = 500,
  binSize = 0.025,
  bw = 12.4,
  fill_peaks = FALSE
)

gc()

library(tidyverse)
# 加载对象
load("/media/yyzhang/data2/shiqiang/metabolite/tidymass/pos/Result/object")
object_pos <- object
object_pos

# 读入样本信息
sample_info_pos <- readr::read_csv("/media/yyzhang/data2/shiqiang/metabolite/tidymass/sample_info/info.csv")

#  查看object_pos中的元数据
object_pos %>%  extract_sample_info() %>% head()

# 移除object_pos中的"group", "class", "injection.order"
object_pos <- object_pos %>% activate_mass_dataset(what = "sample_info") %>% dplyr::select(-c("group", "class", "injection.order"))

# 将sample_info_pos 中的所有列整合到object_pos 中
object_pos = object_pos %>% activate_mass_dataset(what = "sample_info") %>% left_join(sample_info_pos, by = "sample_id")

# 查看元数据信息
object_pos %>% extract_sample_info() %>% head()

# 保存数据
dir.create("/media/yyzhang/data2/shiqiang/metabolite/tidymass/data_cleaning/POS", showWarnings = FALSE, recursive = TRUE)
save(object_pos, file = "/media/yyzhang/data2/shiqiang/metabolite/tidymass/data_cleaning/POS/object_pos")
# 统计样本数和variables数
object_pos

# 根据class统计样本数量，可将class换成group或batch等
object_pos %>% activate_mass_dataset(what = "sample_info") %>% dplyr::count(class)

# 获取peak分布图
pdf(file="/media/yyzhang/data2/shiqiang/metabolite/tidymass/data_cleaning/POS/peak_distributation_plot_positive.pdf")

p<- object_pos %>% `+`(1) %>% log(10) %>% show_mz_rt_plot(hex = FALSE) 

p+ scale_size_continuous(range = c(0.01, 2))

dev.off()

# 查看总缺失值数量
get_mv_number(object = object_pos)
#[1] 786005

# 查看各样本内的缺失值
get_mv_number(object = object_pos, by = "sample") %>% head()

# 查看各variable的缺失值
get_mv_number(object = object_pos, by = "variable") %>% head()

# 绘图展示缺失值信息，可在下一节生成
pdf(file="/media/yyzhang/data2/shiqiang/metabolite/tidymass/data_cleaning/POS/total_MVs.pdf")

show_missing_values(object = object_pos, show_column_names = TRUE, show_row_names = TRUE, percentage = TRUE)

dev.off()

# 绘图展示各样本缺失值信息，可在下一节生成
pdf(file="/media/yyzhang/data2/shiqiang/metabolite/tidymass/data_cleaning/POS/Samples_MVs.pdf")

show_sample_missing_values(object = object_pos, percentage = TRUE, color_by = "class")

dev.off()

# 绘图展示各variables缺失值信息，可在下一节生成
pdf(file="/media/yyzhang/data2/shiqiang/metabolite/tidymass/data_cleaning/POS/Variables_MVs.pdf")

p<- show_variable_missing_values(
  object = object_pos,
  percentage = TRUE,
  show_x_text = FALSE,
  show_x_ticks = FALSE,
  color_by = "mz"
) 

p+ scale_size_continuous(range = c(0.01, 1))

dev.off()
# 加载对象
load("/media/yyzhang/data2/shiqiang/metabolite/tidymass/neg/Result/object")
object_neg <- object
object_neg

# 读入样本信息
sample_info_neg <- readr::read_csv("/media/yyzhang/data2/shiqiang/metabolite/tidymass/sample_info/info.csv")

object_neg %>%  extract_sample_info() %>% head()

object_neg <- object_neg %>% activate_mass_dataset(what = "sample_info") %>% dplyr::select(-c("group", "class", "injection.order"))

# 将sample_info_neg添加至object_neg
object_neg = object_neg %>% activate_mass_dataset(what = "sample_info") %>% left_join(sample_info_neg, by = "sample_id")

object_neg %>% extract_sample_info() %>% head()

# 保存数据
dir.create("/media/yyzhang/data2/shiqiang/metabolite/tidymass/data_cleaning/NEG", showWarnings = FALSE, recursive = TRUE)
save(object_neg, file = "/media/yyzhang/data2/shiqiang/metabolite/tidymass/data_cleaning/NEG/object_neg")

# 统计样本数和variables数
object_neg

# 根据class统计样本数量，可将class换成group或batch等
object_neg %>% activate_mass_dataset(what = "sample_info") %>% dplyr::count(class)

# 获取peak分布图
pdf(file="/media/yyzhang/data2/shiqiang/metabolite/tidymass/data_cleaning/NEG/peak_distributation_plot_negtive.pdf")

object_neg %>% `+`(1) %>% log(10) %>% show_mz_rt_plot() + scale_size_continuous(range = c(0.01, 2))

dev.off()

# 查看总缺失值数量
get_mv_number(object = object_neg)

# 查看各样本内的缺失值
get_mv_number(object = object_neg, by = "sample") %>% head()

# 查看各variable的缺失值
get_mv_number(object = object_neg, by = "variable") %>% head()

# 绘图展示缺失值信息，可在下一节生成
pdf(file="/media/yyzhang/data2/shiqiang/metabolite/tidymass/data_cleaning/NEG/total_MVs.pdf")

show_missing_values(object = object_neg, show_column_names = FALSE, percentage = TRUE)

dev.off()

# 绘图展示各样本缺失值信息，可在下一节生成
pdf(file="/media/yyzhang/data2/shiqiang/metabolite/tidymass/data_cleaning/NEG/Samples_MVs.pdf")

show_sample_missing_values(object = object_neg, percentage = TRUE)

dev.off()

# 绘图展示各variables缺失值信息，可在下一节生成
pdf(file="/media/yyzhang/data2/shiqiang/metabolite/tidymass/data_cleaning/NEG/Variables_MVs.pdf")

p<- show_variable_missing_values(
  object = object_neg,
  percentage = TRUE,
  show_x_text = FALSE,
  show_x_ticks = FALSE
) 

p+ scale_size_continuous(range = c(0.01, 1))

dev.off()


# 加载数据
load("/media/yyzhang/data2/shiqiang/metabolite/tidymass/data_cleaning/POS/object_pos")
load("/media/yyzhang/data2/shiqiang/metabolite/tidymass/data_cleaning/NEG/object_neg")

# 将批次号改为字符串
object_pos <- object_pos %>% activate_mass_dataset(what = "sample_info") %>% dplyr::mutate(batch = as.character(batch))

object_neg <- object_neg %>% activate_mass_dataset(what = "sample_info") %>% dplyr::mutate(batch = as.character(batch))

# 先评估数据质量
massqc::massqc_report(object = object_pos, path = "/media/yyzhang/data2/shiqiang/metabolite/tidymass/data_cleaning/POS/data_quality_before_data_cleaning")

massqc::massqc_report(object = object_neg, path = "/media/yyzhang/data2/shiqiang/metabolite/tidymass/data_cleaning/NEG/data_quality_before_data_cleaning")

# 查看各分组样本量
object_pos %>% activate_mass_dataset(what = "sample_info") %>% dplyr::count(group)

# QC样本中的MV占比
pdf(file="/media/yyzhang/data2/shiqiang/metabolite/tidymass/data_cleaning/POS/MVpercentQC.pdf")

p<- show_variable_missing_values(object = object_pos %>% activate_mass_dataset(what = "sample_info") %>% filter(class == "QC"), percentage = TRUE) 

p+ scale_size_continuous(range = c(0.01, 2))

dev.off()

# 统计QC中的MV占比
qc_id = object_pos %>% activate_mass_dataset(what = "sample_info") %>% filter(class == "QC") %>% pull(sample_id)

A_id = object_neg %>% activate_mass_dataset(what = "sample_info") %>% filter(group == "A") %>% pull(sample_id)

B_id = object_neg %>% activate_mass_dataset(what = "sample_info") %>% filter(group == "B") %>% pull(sample_id)

C_id = object_neg %>% activate_mass_dataset(what = "sample_info") %>% filter(group == "C") %>% pull(sample_id)

D_id = object_neg %>% activate_mass_dataset(what = "sample_info") %>% filter(group == "D") %>% pull(sample_id)

# 整合以上统计信息
object_pos = object_pos %>% mutate_variable_na_freq(according_to_samples = qc_id) %>% mutate_variable_na_freq(according_to_samples = A_id) %>% mutate_variable_na_freq(according_to_samples = B_id) %>% mutate_variable_na_freq(according_to_samples = C_id) %>% mutate_variable_na_freq(according_to_samples = D_id)

head(extract_variable_info(object_pos))

# 移除variables
object_pos <- object_pos %>% activate_mass_dataset(what = "variable_info") %>% filter(na_freq < 0.2 & (na_freq.1 < 0.5 | na_freq.2 < 0.5))

object_pos

# 查看各分组样本量
object_neg %>% activate_mass_dataset(what = "sample_info") %>% dplyr::count(group)

# QC样本中的MV占比
pdf(file="/media/yyzhang/data2/shiqiang/metabolite/tidymass/data_cleaning/NEG/MVpercentQC.pdf")

p<- show_variable_missing_values(object = object_neg %>% activate_mass_dataset(what = "sample_info") %>% filter(class == "QC"), percentage = TRUE)

p+ scale_size_continuous(range = c(0.01, 2))

dev.off()

# 统计QC中的MV占比
qc_id = object_neg %>% activate_mass_dataset(what = "sample_info") %>% filter(class == "QC") %>% pull(sample_id)

A_id = object_neg %>% activate_mass_dataset(what = "sample_info") %>% filter(group == "A") %>% pull(sample_id)

B_id = object_neg %>% activate_mass_dataset(what = "sample_info") %>% filter(group == "B") %>% pull(sample_id)

C_id = object_neg %>% activate_mass_dataset(what = "sample_info") %>% filter(group == "C") %>% pull(sample_id)

D_id = object_neg %>% activate_mass_dataset(what = "sample_info") %>% filter(group == "D") %>% pull(sample_id)

# 整合以上统计信息
object_neg = object_neg %>% mutate_variable_na_freq(according_to_samples = qc_id) %>% mutate_variable_na_freq(according_to_samples = A_id) %>% mutate_variable_na_freq(according_to_samples = B_id)%>% mutate_variable_na_freq(according_to_samples = C_id)%>% mutate_variable_na_freq(according_to_samples = D_id)

head(extract_variable_info(object_neg))

# 移除variables
object_neg <- object_neg %>% activate_mass_dataset(what = "variable_info") %>% filter(na_freq < 0.2 & (na_freq.1 < 0.5 | na_freq.2 < 0.5))

object_neg

# 总览
pdf(file="/media/yyzhang/data2/shiqiang/metabolite/tidymass/data_cleaning/POS/MVpercentALL.pdf")

massdataset::show_sample_missing_values(object = object_pos, color_by = "group", order_by = "injection.order", percentage = TRUE) + theme(axis.text.x = element_text(size = 2)) + scale_size_continuous(range = c(0.1, 2)) + ggsci::scale_color_aaas()

dev.off()

# 检测离群样本
outlier_samples = object_pos %>% `+`(1) %>% log(2) %>% scale() %>% detect_outlier()

outlier_samples

outlier_table <- extract_outlier_table(outlier_samples)

outlier_table %>% head()

outlier_table %>% apply(1, function(x){ sum(x)  }) %>% `>`(0) %>% which()
# #named integer(0)
##无离群样本

# 总览
pdf(file="/media/yyzhang/data2/shiqiang/metabolite/tidymass/data_cleaning/NEG/MVpercentALL.pdf")

p<- massdataset::show_sample_missing_values(object = object_neg, color_by = "group", order_by = "injection.order", percentage = TRUE)

p+ theme(axis.text.x = element_text(size = 2)) + scale_size_continuous(range = c(0.1, 2)) + ggsci::scale_color_aaas()

dev.off()

# 检测离群样本
outlier_samples = object_neg %>% `+`(1) %>% log(2) %>% scale() %>% detect_outlier()

outlier_samples

outlier_table <- extract_outlier_table(outlier_samples)

outlier_table %>% head()

outlier_table %>% apply(1, function(x){ sum(x)  }) %>% `>`(0) %>% which()
# #named integer(0)
##无离群样本

# 获取正离子模式下的MV数量
get_mv_number(object_pos)

# 填充正离子模式缺失值
object_pos <- impute_mv(object = object_pos, method = "knn")

# 获取正离子模式下填充后的MV数量
get_mv_number(object_pos)

# 获取负离子模式下的MV数量
get_mv_number(object_neg)

# 填充正离子模式缺失值
object_neg <- impute_mv(object = object_neg, method = "knn")

# 获取正离子模式下填充后的MV数量
get_mv_number(object_neg)

object_pos <- normalize_data(object_pos, method = "median")

object_pos2 <- integrate_data(object_pos, method = "subject_median")

# 按批次分组绘制PCA图
pdf(file="/media/yyzhang/data2/shiqiang/metabolite/tidymass/data_cleaning/POS/PC_batch_intergrated.pdf")

object_pos2 %>% `+`(1) %>% log(2) %>% massqc::massqc_pca(color_by = "batch", line = FALSE)

dev.off()

object_neg <- normalize_data(object_neg, method = "median")

object_neg2 <- integrate_data(object_neg, method = "subject_median")

# 按批次分组绘制PCA图
pdf(file="/media/yyzhang/data2/shiqiang/metabolite/tidymass/data_cleaning/NEG/PC_batch_intergrated.pdf")

object_neg2 %>% `+`(1) %>% log(2) %>% massqc::massqc_pca(color_by = "batch", line = FALSE)

dev.off()

save(object_pos2, file = "/media/yyzhang/data2/shiqiang/metabolite/tidymass/data_cleaning/POS/object_pos2")
save(object_neg2, file = "/media/yyzhang/data2/shiqiang/metabolite/tidymass/data_cleaning/NEG/object_neg2")

object_pos2 <- mutate_ms2(
  object = object_pos2,
  column = "rp", # rp or hilic，对应RPLC（反相色谱）和HILIC（亲水相互作用色谱）
  polarity = "positive",
  ms1.ms2.match.mz.tol = 15,# ppm
  ms1.ms2.match.rt.tol = 30,# seconds
  path = "/media/yyzhang/data2/shiqiang/metabolite/tidymass/ms2/pos"
)

# summary
extract_ms2_data(object_pos2)

object_neg2 <- mutate_ms2(
  object = object_neg2,
  column = "rp",
  polarity = "negative",
  ms1.ms2.match.mz.tol = 15,
  ms1.ms2.match.rt.tol = 30,
  path = "/media/yyzhang/data2/shiqiang/metabolite/tidymass/ms2/neg"
)

# summary
extract_ms2_data(object_neg2)

# Annotate features using snyder_database_rplc0.0.3
load("/media/yyzhang/data2/shiqiang/metabolite/tidymass/gnps_bilelib19_ms2.rda")


## 注释
object_pos2_gnp <- annotate_metabolites_mass_dataset(
  object = object_pos2, 
  ms1.match.ppm = 15, 
  rt.match.tol = 30, 
  polarity = "positive",
  database = gnps_bilelib19_ms2,
  threads =30)

# Annotate features using orbitrap_database0.0.3
load("/media/yyzhang/data2/shiqiang/metabolite/tidymass/mona_ms2.rda")

## 注释
object_pos2 <- annotate_metabolites_mass_dataset(
  object = object_pos2, 
  ms1.match.ppm = 15, 
  polarity = "positive",
  database = mona_ms2,
  threads =30)

# Annotate features using mona_database0.0.3
load("/media/yyzhang/data2/shiqiang/metabolite/tidymass/mpsnyder_hilic_ms2.rda")

## 注释
object_pos2 <- annotate_metabolites_mass_dataset(
  object = object_pos2, 
  ms1.match.ppm = 15, 
  polarity = "positive",
  database = mpsnyder_hilic_ms2,
  threads =30)

load("/media/yyzhang/data2/shiqiang/metabolite/tidymass/mpsnyder_rplc_ms2.rda")

## 注释
object_pos2 <- annotate_metabolites_mass_dataset(
  object = object_pos2, 
  ms1.match.ppm = 15, 
  polarity = "positive",
  database = mpsnyder_hilic_ms2,
  threads =30)

# Annotate features using snyder_database_rplc0.0.3
object_neg2 <- annotate_metabolites_mass_dataset(
  object = object_neg2, 
  ms1.match.ppm = 15, 
  rt.match.tol = 30, 
  polarity = "negative",
  database = mpsnyder_hilic_ms2)

# Annotate features using orbitrap_database0.0.3
object_neg2 <- annotate_metabolites_mass_dataset(
  object = object_neg2, 
  ms1.match.ppm = 15, 
  polarity = "negative",
  database = mona_ms2.rda)

# Annotate features using mona_database0.0.3
object_neg2 <- annotate_metabolites_mass_dataset(
  object = object_neg2, 
  ms1.match.ppm = 15, 
  polarity = "negative",
  database = gnps_bilelib19_ms2.rda)

head(extract_annotation_table(object = object_pos2))

variable_info_pos <- extract_variable_info(object = object_pos2)

head(variable_info_pos)

table(variable_info_pos$Level)

table(variable_info_pos$Database)

save(object_pos2, file = "/media/yyzhang/data2/shiqiang/metabolite/tidymass/anntation/object_pos2")
save(object_neg2, file = "/media/yyzhang/data2/shiqiang/metabolite/tidymass/anntation/object_neg2")

load("/media/yyzhang/data2/shiqiang/metabolite/tidymass/anntation/object_pos2")
load("/media/yyzhang/data2/shiqiang/metabolite/tidymass/anntation/object_neg2")

object_pos2 <- object_pos2 %>% activate_mass_dataset(what = "annotation_table") %>% filter(!is.na(Level)) %>% filter(Level == 1 | Level == 2)

object_neg2 <- object_neg2 %>% activate_mass_dataset(what = "annotation_table") %>% filter(!is.na(Level)) %>% filter(Level == 1 | Level == 2)

# inner merge for samples and full merge for variables
object <- 
  merge_mass_dataset(
    x = object_pos2, 
    y = object_neg2, 
    sample_direction = "inner",# left, right, inner or full，此处用inner较合理
    variable_direction = "full",# left, right, inner or full，此处用full合理
    sample_by = "sample_id", # merge samples by what columns from sample_info
    variable_by = c("variable_id", "mz", "rt")# merge variables by what columns from variable_info
  )

dir.create(path = "/media/yyzhang/data2/shiqiang/metabolite/tidymass/statistical_analysis", showWarnings = FALSE)

report_parameters(object = object, path = "/media/yyzhang/data2/shiqiang/metabolite/tidymass/statistical_analysis/")

object <- object %>% 
  activate_mass_dataset(what = "annotation_table") %>% 
  group_by(Compound.name) %>% 
  filter(Level == min(Level)) %>% 
  filter(SS == max(SS)) %>% 
  slice_head(n = 1)

object <- object %>% 
  activate_mass_dataset(what = "annotation_table") %>% 
  group_by(variable_id) %>% 
  filter(Level == min(Level)) %>% 
  filter(SS == max(SS)) %>% 
  slice_head(n = 1)

####massdatabse下载公共数据库并转化为database对象
library(massdatabase)
setwd("C:/Users/51078/Desktop/对微生境异质性的快速响应适应/result2-overview/代谢组/Pubilc database")
download_kegg_compound(path = ".", sleep = 1)
##然后读取并将其转换为 `databaseClass` 格式。
data <- read_kegg_compound(path = ".")
##然后将其转换为 databaseClass 格式。
kegg_database <-convert_kegg2metid(data = data, path = ".")
##将数据库保存
save(kegg_database, file = "./kegg_database")
####kegg_pathway下载整理
download_kegg_pathway(path = ".",
                      sleep = 1,
                      organism = "osa")
## 然后读取所下载的数据    
data <- read_kegg_pathway(path = ".")
## 转变数据库形式
kegg_pathway_database <-convert_kegg2metpath(data = data, path = ".")
  
##查看有多少通路
length(unlist(kegg_pathway_database@pathway_name))
###提取文件
result2 <- NULL
com_num <- c(150)  ## 排除没有对应化合物的几个通路
for (i in 1:147) {
    a <-  data[[i]]$pathway_id  # 提取id
    b <- data[[i]]$pathway_name # 提取名称
    f <- data[[i]]$compound_list # 提取化合物对应关系
    if ( i %in% com_num){
        d <-  'None;None'
    }else {
        d <- data[[i]]$pathway_class
        Compound_re <- f %>% mutate(pathway_id = a,
                                    pathway_name = b,
                                    pathway_class= d)
        result2 <- rbind(result2,Compound_re)
    }
}
write.csv(result2,"./kegg_pathway_osa.csv")
