mapfile -t filenames < /ifs1/User/tongzeyu/sample_reads/bgi/names_standard

# 循环执行命令
for filename in "${filenames[@]}"; do

    samtools depth -@ 64 -aa /ifs1/User/tongzeyu/sample_reads/bgi/minimap2_result_20250212/${filename}/${filename}_chr_sorted.bam > /ifs1/User/tongzeyu/sample_reads/bgi/coverage_20250212/${filename}_chr_coverage.txt

done