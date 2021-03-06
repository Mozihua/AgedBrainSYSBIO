# Script preprocesses file containing epistatic interactions in ADNI cohort.

library(gProfileR)

# Read the file related to ADNI cohort
epi <- read.table(file = "~/absb/data/epistasis/ADNI_VER_epistasis.tsv", header=T)

# Create the folder where current results will be written
resdir <- "~/absb/results/epistasis/"
dir.create(file.path(resdir),showWarnings  =  FALSE, recursive  =  TRUE)

# Set created directory as working dirrectory
setwd(resdir)

# Convert to character
epi$bin_1 <- as.character(epi$bin_1)

# Grep all the interactions that has intergenic regions
epi_a <- epi[grep("-ENSG", epi$bin_1), ]
epi_b <- epi[grep("-ENSG", epi$bin_2), ]

# Number of LRG genes among interactors 
dim(epi_a)
dim(epi_b)

rows_cut_a <- row.names(epi_a)
rows_cut_b <- row.names(epi_b)
rows_cut <- unique(c(rows_cut_a, rows_cut_b))
length(rows_cut)

# Intergenic regions
epi_adni_igri <- epi[rownames(epi)%in%rows_cut,c(1,2,3)]

# Bind columns with interaction_type, data_source.
epi_adni_igri <- cbind(epi_adni_igri, interaction_type="IGRI")
epi_adni_igri <- cbind(epi_adni_igri, data_source="ADNI_VER")

# df that has intercators as intergenic regions in one of the columns and correcponding scores
colnames(epi_adni_igri) <- c("ensg1","ensg2","score","interaction_type","data_source")

# Save data for intergenic regions interactions(IGRI)
#save(epi_adni_igri, file = "epi_adni_igri.RData")
#write.table(epi_adni_igri,file = "epi_adni_igri.txt",sep = "\t", quote = F, row.names = F)

# Size
dim(epi_adni_igri)

# Combine with the main data frame 
epi_adni <- epi[!row.names(epi)%in%rows_cut,c(1,2,3)]
dim(epi_adni)

# Bind columns with interaction_type, data_source
epi_adni <- cbind(epi_adni, interaction_type = "epistasis")
epi_adni <- cbind(epi_adni, data_source = "ADNI_VER")
colnames(epi_adni) <- c("ensg1","ensg2","score","interaction_type","data_source")

# Convert gene ids and ensg id to tha latest Ensembl version
# First interactor
epi_adni_ensg12ensg <- gconvert(epi_adni$ensg1)
epi_adni_ensg12ensg <- epi_adni_ensg12ensg[, c(2,4)]
colnames(epi_adni_ensg12ensg) <- c(".id", "Target")
dim(epi_adni_ensg12ensg)
epi_adni_ensg12ensg <- epi_adni_ensg12ensg[!duplicated(epi_adni_ensg12ensg), ]
dim(epi_adni_ensg12ensg)

# Second interactor
epi_adni_ensg22ensg <- gconvert(epi_adni$ensg2)
epi_adni_ensg22ensg <- epi_adni_ensg22ensg[, c(2,4)]
colnames(epi_adni_ensg22ensg) <- c(".id", "Tartget")
dim(epi_adni_ensg22ensg)
epi_adni_ensg22ensg <- epi_adni_ensg22ensg[!duplicated(epi_adni_ensg22ensg), ]
dim(epi_adni_ensg22ensg)

# Merge by ensg1
epi_adni_2ensg <- merge(epi_adni,epi_adni_ensg12ensg, by.x="ensg1", by.y=".id", all=F)
dim(epi_adni_2ensg)

#Merge by ensg2
epi_adni_2ensg <- merge(epi_adni_2ensg,epi_adni_ensg22ensg, by.x="ensg2", by.y=".id", all=F)

# Size of the dataset with old ENSG IDs(ver 74) converted to ver 887
dim(epi_adni_2ensg)
# Size of the dataset with old ENSG IDs(ver74)
dim(epi_adni)

# Find differences between ENSG IDs in Ensembl ver 90 and Ensembl ver 74
# All ENSG IDs in ver 90
ensg_adni_ver90 <- unique(c(as.character(epi_adni_2ensg$ensg1),as.character(epi_adni_2ensg$ensg2)))
length(ensg_adni_ver90)

# All ENSG IDs in ver 74
ensg_adni_ver74 <- unique(c(as.character(epi_adni$ensg1),as.character(epi_adni$ensg2)))
length(ensg_adni_ver74)       

# ENSG IDs present in ver 74 and not present in ver 90
ensg_90_vs_74_adni <- ensg_adni_ver74[!ensg_adni_ver74%in%ensg_adni_ver90]
length(ensg_90_vs_74_adni)

# Save to file
#write.table(ensg_90_vs_74_adni, file="ensg_90_vs_74_adni.txt", quote=F, row.names=F, sep="\t")

# Find differences in IGRI
epi_adni_igri_ensg <- unique(c(as.character(epi_adni_igri$ensg1),as.character(epi_adni_igri$ensg2)))
length(epi_adni_igri_ensg)
library(stringr)
epi_adni_igri_ensg<-unique(unlist(str_split(epi_adni_igri_ensg,"-")))
length(epi_adni_igri_ensg)

# Convert gene ids and ensg id to tha latest Ensembl version
epi_adni_igri_ensg12ensg <- gconvert(epi_adni_igri_ensg)
epi_adni_igri_ensg12ensg <- epi_adni_igri_ensg12ensg[, c(2,4)]
colnames(epi_adni_igri_ensg12ensg) <- c(".id", "Target")
dim(epi_adni_igri_ensg12ensg)

epi_adni_igri_ensg12ensg <- epi_adni_igri_ensg12ensg[!duplicated(epi_adni_igri_ensg12ensg), ]
dim(epi_adni_igri_ensg12ensg)

epi_adni_igri_ensg_ver90 <- unique(as.character(epi_adni_igri_ensg12ensg$Target))
epi_adni_igri_ensg_ver74 <- epi_adni_igri_ensg

ensg_90_vs_74_adni_igri <- epi_adni_igri_ensg_ver74[!epi_adni_igri_ensg_ver74%in%epi_adni_igri_ensg_ver90]
length(ensg_90_vs_74_adni_igri)

# Save 
#write.table(ensg_90_vs_74_adni_igri, file="ensg_90_vs_74_adni_igri.txt", quote=F, row.names=F, sep="\t")

# Find all missing IDs in IGRI and normal gene IDs
ensg_90_vs_74_adni_all <- unique(c(ensg_90_vs_74_adni,ensg_90_vs_74_adni_igri))
length(ensg_90_vs_74_adni_all)
#write.table(ensg_90_vs_74_adni_all, file = "ensg_90_vs_74_adni_all.txt", quote=F, row.names=F, sep="\t")

# Exclude the rows with old ids that are not mapped to Ensembl  ver 90
#epi_adni_igri
excluderow <- c()
for(i in 1:length(rownames(epi_adni_igri))){
 pair1 <- unique(unlist(str_split(as.character(epi_adni_igri[i,1]),"-")))
 p1 <- c(pair1%in%ensg_90_vs_74_adni_all)
 c1 <- length(p1[p1==T])
 pair2 <- unique(unlist(str_split(as.character(epi_adni_igri[i,2]),"-")))
 p2 <- c(pair2%in%ensg_90_vs_74_adni_all)
 c2 <- length(p2[p2==T])
if(c1>0){ 
  excluderow <- c(excluderow,i)
  }else if(c2>0){ 
        excluderow <- c(excluderow,i)
        }
}
epi_adni_igri_ver90 <- epi_adni_igri[!rownames(epi_adni_igri)%in%excluderow,]
#save(epi_adni_igri_ver90, file = "epi_adni_igri_ver90.RData")
#write.table(epi_adni_igri_ver90,file = "epi_adni_igri_ver90.txt", sep = "\t", quote = F, row.names = F)
dim(epi_adni_igri_ver90)
dim(epi_adni_igri)

epi_adni <- epi_adni_2ensg[,c(6,7,3,4,5)]
colnames(epi_adni)=c("ensg1","ensg2","score","interaction_type", "data_source")
epi_adni <- epi_adni[!duplicated(epi_adni), ]
dim(epi_adni)

# Write result
#save(epi_adni, file="epi_adni.RData")
#write.table(epi_adni,file="epi_adni.txt",sep="\t", quote=F, row.names=F)

# Combine dataframes of IGRI and the rest genes interactions. Write final ds to the file
epi_adni_ver_int <- rbind(epi_adni,epi_adni_igri_ver90)

# Remove the duplicated undirrescted edges with the same score.
# For example ENSG1-ENSG2 0.5 and ENSG2-ENSG1 0.5

# Convert factors to characters
df2string<-function(df){
i <- sapply(df, is.factor)
df[i] <- lapply(df[i], as.character)
df[,3]<-as.numeric(df[,3])
return (df)}

epi_adni_ver_int <- df2string(epi_adni_ver_int)
str(epi_adni_ver_int)
dim(epi_adni_ver_int)
epi_adni_ver_int <- epi_adni_ver_int[!duplicated(data.frame(t(apply(epi_adni_ver_int[1:2], 1, sort)), epi_adni_ver_int[,c(3,5)])),]
# New size
dim(epi_adni_ver_int)

# Save the part of the integrated dataset related to adni cohort
save(epi_adni_ver_int, file="epi_adni_ver_int.RData")
write.table(epi_adni_ver_int,file="epi_adni_ver_int.txt",sep="\t", quote=F, row.names=F)




