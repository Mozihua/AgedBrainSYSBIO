# This script maps SNP IDs from GWAS to Ensemble gene IDs

# Create the folder where current results will be written
resdir<-"~/absb/results/gwas/"
dir.create(file.path(resdir),showWarnings = FALSE, recursive = TRUE)

# Set created directory as working dirrectory
setwd(resdir)

# Used libraries
library(biomaRt)
library(gProfileR)

gwas <- read.table(file="~/absb/data/gwas/IGAP_stage_1_2_combined.txt", sep="\t", header=T,stringsAsFactors = F )
dim(gwas)
marker.name=unique(gwas$MarkerName)
length(marker.name)

# Convert rs ids with biomart biomaRt_2.16.0
rs <- gwas$MarkerName
mart.snp <- useMart("ENSEMBL_MART_SNP", "hsapiens_snp", host = "ensembl.org")
rs2ensg <- getBM(attributes = c("refsnp_id", "ensembl_gene_stable_id","ensembl_type"),filters=c("snp_filter"), values = rs, mart = mart.snp)

biomart_ensg <- rs2ensg
biomart_ensg<-biomart_ensg[,c(1,2)]
head(biomart_ensg)

# Remove duplicates
biomart_ensg<-biomart_ensg[!duplicated(biomart_ensg), ]

# Rename the columns
colnames(biomart_ensg) <- c("variant_name", "ensg")

# Remove blaks
biomart_ensg$ensg[biomart_ensg$ensg == ""]<- NA
biomart_ensg <- na.omit(biomart_ensg)


#Dimentions
dim(biomart_ensg)

# Merge by variant name with gewas original dataset
gwas_ensg=merge(gwas, biomart_ensg, by.x="MarkerName", by.y="variant_name", All=F)
dim(gwas_ensg)
head(gwas_ensg)

# Select only marker name, ensg,p-value
gwas_ensg <- gwas_ensg[, c(1, 8, 9)]

# Rename columns
colnames(gwas_ensg) <- c("SNP_id","GWAS_pvalue", "ensg")

# Save results to the file
save(gwas_ensg, file="gwas_ensg.RData")
write.table(gwas_ensg, file="gwas_ensg.txt",sep="\t", row.names=F, col.names=T, quote=F)
