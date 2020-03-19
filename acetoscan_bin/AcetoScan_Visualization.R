#!/usr/bin/env Rscript

#   File: AcetoScan_Visualization.R
#   Last modified: Tor, Mar 19, 2020 10:00
#   Sign: Abhi

otu_file <- "FTHFS_otutab.csv"
tax_file <- "FTHFS_taxtab.csv"
sam_file <- "FTHFS_samtab.csv"
tree_file <- "FTHFS_otu.tree"

#   Function for loading OR installing if missing R packages
Rpackage <- function(pkg){
  pkgR <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(pkgR))
    install.packages(pkgR)
  sapply(pkg, require, character.only = TRUE)
}

#   Defining required package list
Libraries <- c("ggplot2",
               "phyloseq",
               "plotly",
               "RColorBrewer",
               "plyr",
               "dplyr",
               "vegan")

# Turn the warnings off
#options(warn=-1)

#   Load required packages with suppressed start-up messages
suppressPackageStartupMessages(Rpackage(Libraries))

######  Reading OTU file

OTU_data <- read.table(otu_file,
                       sep = ",",
                       header = TRUE,
                       row.names = 1,
                       check.names = FALSE)

#   Making matrix
OTU_data_mat <- as.matrix(as.data.frame(OTU_data))

#   Making phyloseq otu table
OTU_data_mat_table <- otu_table(OTU_data_mat, taxa_are_rows = TRUE)

###### Reading TAX table

TAX_data1 <- read.table(tax_file,
                       sep = ",",
                       header = T,
                       stringsAsFactors = F)

TAX_data <- subset(TAX_data1, select = -c(Subject_Accession,Percentage_identity:Query_seq))

#   subsetting the data
TAX_data_subset <- TAX_data[, -1]
#TAX_data_subset

#   getting OTU names from otu table "OTU_data"
rownames(TAX_data_subset) <- rownames(OTU_data_mat_table)

#   making matrix of subset tax_data
TAX_data_subset_mat <- as.matrix(TAX_data_subset)

#   making phyloseq tax table
TAX_data_subset_mat_table <- tax_table(TAX_data_subset_mat)

###### Reading sample data
sam_data <- read.table(sam_file,
                       sep = ",",
                       row.names = 1,
                       check.names = FALSE,
                       header = T)

sam_data <- sample_data(sam_data)

### Reading phylogenetic tree
tree_data <- read_tree(tree_file)

# Making phyloseq object from the tax table and OTU table
ps0 <- phyloseq(OTU_data_mat_table, TAX_data_subset_mat_table)

# Adding sample data and phylogenetic tree to phyloseq object
ps <- merge_phyloseq(ps0, sam_data, tree_data)
writeLines("\n------------------------- \t Phyloseq object \t-------------------------\n")
ps
writeLines("\n------------------------- \t END \t-------------------------\n")

# Save infor of phyloseq object
sink("Visualization_processing_info.txt")
writeLines("\n------------------------- \t Phyloseq object \t-------------------------\n")
print(ps)
writeLines("\n------------------------- \t END \t-------------------------\n")
sink()

# Visualize phyloseq object details
#sample_names(ps)
#nsamples(ps)
#ntaxa(ps)

# phylum detail
ps_table <- table(tax_table(ps)[, "Phylum"], exclude = NULL)
# save phylum detail
sink("Visualization_processing_info.txt", append = T)
writeLines("\n------------------------- \t Phylum table \t-------------------------\n")
print(ps_table)
writeLines("\n------------------------- \t END \t-------------------------\n")
sink()

# Compute prevalence of each feature, store as data.frame
prevalence_dataframe <- apply(X = otu_table(ps),
                              MARGIN = ifelse(taxa_are_rows(ps), yes = 1, no = 2),
                              FUN = function(x){sum(x > 0)})
# Add taxonomy and total read counts to this data.frame
prevalence_dataframe <- data.frame(Prevalence = prevalence_dataframe,
                                   TotalAbundance = taxa_sums(ps),
                                   tax_table(ps))
# Compute the mean prevalences and total abundance of the features in each phylum
prevalence_table <- plyr::ddply(prevalence_dataframe, "Phylum", function(df1) {
  data.frame(mean_prevalence = mean(df1$Prevalence),
             total_abundance = sum(df1$TotalAbundance, na.rm = TRUE),
             stringsAsFactors = FALSE)
})

# #save the prevalance table as text file
sink("Visualization_processing_info.txt", append = T)
writeLines("\n------------------------- \t Phylum_prevalence_table: \t-------------------------\n")
print(prevalence_table)
writeLines("\n------------------------- \t END \t-------------------------\n")
sink()

# Write the details to console/terminal

writeLines("\n------------------------- \t Taxonomy overview \t-------------------------\n")
paste("number_of_Phylum: ", length(get_taxa_unique(ps, taxonomic.rank = "Phylum")))
paste("number_of_Class: ", length(get_taxa_unique(ps, taxonomic.rank = "Class")))
paste("number_of_Order: ", length(get_taxa_unique(ps, taxonomic.rank = "Order")))
paste("number_of_Family: ", length(get_taxa_unique(ps, taxonomic.rank = "Family")))
paste("number_of_Genus: ", length(get_taxa_unique(ps, taxonomic.rank = "Genus")))
paste("number_of_Species: ", length(get_taxa_unique(ps, taxonomic.rank = "Species")))
writeLines("\n------------------------- \t END \t-------------------------\n")
# Write the details of taxa to file
sink("Visualization_processing_info.txt", append = T)
writeLines("\n------------------------- \t Phylum \t-------------------------\n")
paste("number_of_Phylum: ", length(get_taxa_unique(ps, taxonomic.rank = "Phylum")))
get_taxa_unique(ps, taxonomic.rank = "Phylum")
writeLines("\n------------------------- \t END \t-------------------------\n")
writeLines("\n------------------------- \t Class \t-------------------------\n")
paste("number_of_Class: ", length(get_taxa_unique(ps, taxonomic.rank = "Class")))
get_taxa_unique(ps, taxonomic.rank = "Class")
writeLines("\n------------------------- \t END \t-------------------------\n")
writeLines("\n------------------------- \t Order \t-------------------------\n")
paste("number_of_Order: ", length(get_taxa_unique(ps, taxonomic.rank = "Order")))
get_taxa_unique(ps, taxonomic.rank = "Order")
writeLines("\n------------------------- \t END \t-------------------------\n")
writeLines("\n------------------------- \t Family \t-------------------------\n")
paste("number_of_Family: ", length(get_taxa_unique(ps, taxonomic.rank = "Family")))
get_taxa_unique(ps, taxonomic.rank = "Family")
writeLines("\n------------------------- \t END \t-------------------------\n")
writeLines("\n------------------------- \t Genus \t-------------------------\n")
paste("number_of_Genus: ", length(get_taxa_unique(ps, taxonomic.rank = "Genus")))
get_taxa_unique(ps, taxonomic.rank = "Genus")
writeLines("\n------------------------- \t END \t-------------------------\n")
writeLines("\n------------------------- \t Species \t-------------------------\n")
paste("number_of_Species: ", length(get_taxa_unique(ps, taxonomic.rank = "Species")))
get_taxa_unique(ps, taxonomic.rank = "Species")
writeLines("\n------------------------- \t END \t-------------------------\n")
sink()

########### Fixing functions
##Calculate abundance of different ranks
#   taxonomy table
tax.tab <- tibble(tax_table(ps))

# function for the modification of OTU table
ModifyTax <- function(x, ind) {
  #   xth row in the dataframe
  #   ind taxonomy level to change
  if (is.na(x[ind])) {
    nonNa <- which(!is.na(x[-ind]))
    maxNonNa <- max(nonNa)
    x[ind] <- paste(x[maxNonNa], ".", x[ind])
  } else {
    x[ind] <- x[ind]
  }
}

##  Making manual and distinctive colour palette
colour_palette = brewer.pal.info[brewer.pal.info$category == 'qual',]
my_colours_1 = unlist(mapply(brewer.pal, colour_palette$maxcolors, rownames(colour_palette)))
my_colours <- rep(my_colours_1, times=5)

# plot absolute abundance
pdf(file = "Absolute_abundance.pdf", width = 28, height = 18, paper = "a4r")
plot_bar(ps, fill="Kingdom")+scale_fill_manual(values = my_colours)+theme(axis.text.x = element_text(colour = "black", angle = 85, hjust = 1, vjust = 1, face = "bold"))+
  theme(legend.position = "bottom")+
  guides(col = guide_legend(ncol = 4))+
  theme(legend.key.height = unit(0.3, "cm"), legend.key.width = unit(0.4, "cm"))+
  ylab("Absolute Abundance (counts)")
plot_bar(ps, fill="Phylum")+scale_fill_manual(values = my_colours)+theme(axis.text.x = element_text(colour = "black", angle = 85, hjust = 1, vjust = 1, face = "bold"))+
  theme(legend.position = "bottom")+
  guides(col = guide_legend(ncol = 4))+
  theme(legend.key.height = unit(0.3, "cm"), legend.key.width = unit(0.4, "cm"))+
  ylab("Absolute Abundance (counts)")
plot_bar(ps, fill="Class")+scale_fill_manual(values = my_colours)+theme(axis.text.x = element_text(colour = "black", angle = 85, hjust = 1, vjust = 1, face = "bold"))+
  theme(legend.position = "bottom")+
  guides(col = guide_legend(ncol = 4))+
  theme(legend.key.height = unit(0.3, "cm"), legend.key.width = unit(0.4, "cm"))+
  ylab("Absolute Abundance (counts)")
plot_bar(ps, fill="Order")+scale_fill_manual(values = my_colours)+theme(axis.text.x = element_text(colour = "black", angle = 85, hjust = 1, vjust = 1, face = "bold"))+
  theme(legend.position = "bottom")+
  guides(col = guide_legend(ncol = 4))+
  theme(legend.key.height = unit(0.3, "cm"), legend.key.width = unit(0.4, "cm"))+
  ylab("Absolute Abundance (counts)")
plot_bar(ps, fill="Family")+scale_fill_manual(values = my_colours)+theme(axis.text.x = element_text(colour = "black", angle = 85, hjust = 1, vjust = 1, face = "bold"))+
  theme(legend.position = "bottom")+
  guides(col = guide_legend(ncol = 4))+
  theme(legend.key.height = unit(0.3, "cm"), legend.key.width = unit(0.4, "cm"))+
  ylab("Absolute Abundance (counts)")
plot_bar(ps, fill="Genus")+scale_fill_manual(values = my_colours)+theme(axis.text.x = element_text(colour = "black", angle = 85, hjust = 1, vjust = 1, face = "bold"))+
  theme(legend.position = "bottom")+
  guides(col = guide_legend(ncol = 4))+
  theme(legend.key.height = unit(0.3, "cm"), legend.key.width = unit(0.4, "cm"))+
  ylab("Absolute Abundance (counts)")
plot_bar(ps, fill="Species")+scale_fill_manual(values = my_colours)+theme(axis.text.x = element_text(colour = "black", angle = 85, hjust = 1, vjust = 1, face = "bold"))+
  theme(legend.position = "bottom")+
  guides(col = guide_legend(ncol = 4))+
  theme(legend.key.height = unit(0.3, "cm"), legend.key.width = unit(0.4, "cm"))+
  ylab("Absolute Abundance (counts)")
dev.off()

######################  Phylum Absolute abundance
Phylum_Absolute_abundance <- plot_bar(ps, fill = "Phylum") +
  theme(legend.position = "bottom") +
  theme(axis.text.x = element_text(colour = "black", angle = 45, hjust = 1, vjust = 1, face = "bold")) +
  theme(legend.key.height = unit(0.3, "cm"), legend.key.width = unit(0.4, "cm")) +
  theme(strip.text.x = element_text(size = 10, colour = "black", face = "bold")) +
  theme(strip.text.x = element_text(margin = margin(0.025, 0, 0.025, 0, "cm"))) +
  theme(axis.text.x = element_text(colour = "black", angle = 45, hjust = 1, vjust = 1, face = "bold", size = 8)) +
  theme(axis.text.y = element_text(colour = "black", angle = 0, hjust = 1, size = 8, face = "bold")) +
  theme(axis.line.y.left = element_line(colour = "black")) +
  theme(axis.line.x.bottom = element_line(colour = "black")) +
  theme(axis.line.x.top = element_line(colour = "black")) +
  theme(axis.title.x = element_text(colour = "black", face = "bold", size = 10)) +
  theme(axis.title.y = element_text(colour = "black", face = "bold", size = 10)) +
  ylab("Absolute Abundance (counts)")+
  ggtitle("Phylum absolute abundance")+
  theme(plot.title = element_text(size = 10, face = "bold"))

# save plot as pdf
pdf("Barplot_Phylum_Absolute_abundance.pdf", width = 28, height = 18, paper = "a4r")
plot(Phylum_Absolute_abundance)
dev.off()

# save plot as image
tiff("Barplot_Phylum_Absolute_abundance.tif", width = 12, height = 6, units = "in", res = 250)
plot(Phylum_Absolute_abundance)
dev.off()

# saving Total_Phylum_numbers_in_absolute abundance_barplot
sink("Visualization_processing_info.txt", append = T)
writeLines("\n------------------------- \t START \t-------------------------\n")
paste("Total Phylum numbers in absolute abundance_barplot: ", length(get_taxa_unique(ps, taxonomic.rank = "Phylum")))
writeLines("\n------------------------- \t END \t-------------------------\n")
sink()

# save plot as html widget
Phylum_Absolute_abundance_gg <- ggplotly(Phylum_Absolute_abundance)
htmlwidgets::saveWidget(as_widget(Phylum_Absolute_abundance_gg), "Barplot_Phylum_Absolute_abundance.html")

################################################
########################## VISUALIZATION PART / MAKING MAIN PLOTS
#####################################################################
#Phylum level
#   replace the NA taxonomy with the highest known taxonomy
tax_table(ps)[, 2] <- apply(tax.tab, 1, ModifyTax, ind = 2)
# prepare the phylum level data file
phylum_level <-tax_glom(ps, taxrank = "Phylum", is.na("Phylum"))
# visualise the filtered taxa at phylum level
#phylum_level
# transform the taxa(phylum) information in the 100% stacked table
phylum_level_transformed <- transform_sample_counts(phylum_level, function(x) {x/sum(x)}*100)
# melting the transforming phylum data
phylum_level_transformed_psmelt <- psmelt(phylum_level_transformed)
# converting the phylum information as character
phylum_level_transformed_psmelt$Phylum <- as.character(phylum_level_transformed_psmelt$Phylum)

# Phylum level barplot
Phylum_level_barplot <- ggplot(data = phylum_level_transformed_psmelt,
                               aes(x = Sample, y = Abundance, fill = Phylum)) +
  geom_bar(aes(fill = Phylum), linetype = "blank", stat = "identity", position = "stack") +
  scale_fill_manual(values = my_colours, na.value="white")+
  theme(legend.position = "bottom") +
  guides(fill = guide_legend(nrow = 3)) +
  theme(axis.text.x = element_text(colour = "black", angle = 45, hjust = 1, vjust = 1, face = "bold")) +
  theme(axis.text.y = element_text(colour = "black", hjust = 1, vjust = 1, face = "bold")) +
  theme(axis.title.x = element_text(colour = "black", face = "bold", size = 10)) +
  theme(axis.title.y = element_text(colour = "black", face = "bold", size = 10)) +
  ylab("Relative Abundance (%)") +
  theme(legend.key.height = unit(0.3, "cm"), legend.key.width = unit(0.4, "cm")) +
  theme(strip.text.x = element_text(size = 10, colour = "black", face = "bold")) +
  theme(strip.text.x = element_text(margin = margin(0.025, 0, 0.025, 0, "cm"))) +
  theme(axis.line.y.left = element_line(colour = "black")) +
  theme(axis.line.x.bottom = element_line(colour = "black")) +
  theme(axis.line.x.top = element_line(colour = "black")) +
  theme(legend.title = element_text(size = 10, face = "bold", colour = "black"))+
  ggtitle("Phylum level")+
  theme(plot.title = element_text(size = 10, face = "bold"))

#saving plot in pdf
pdf("1_Phylum_barplot.pdf", width = 28, height = 18, paper = "a4r")
plot(Phylum_level_barplot)
dev.off()

# save plot as image
tiff("1_Phylum_barplot.tif", width = 12, height = 6, units = "in", res = 250)
plot(Phylum_level_barplot)
dev.off()

# saving Phylum number in phylum level barplot
sink("Visualization_processing_info.txt", append = T)
writeLines("\n------------------------- \t START \t-------------------------\n")
paste("Phylum number in phylum level barplot: ", length(unique(phylum_level_transformed_psmelt$Phylum)))
writeLines("\n------------------------- \t END \t-------------------------\n")
sink()

#saving plot as html widget
barplot_phylum<-ggplotly(Phylum_level_barplot)
htmlwidgets::saveWidget(as_widget(barplot_phylum), "1_Phylum_barplot.html")

#####################################################################################################

#Class level
# replace the NA taxonomy with the highest known taxonomy
tax_table(ps)[, 3] <- apply(tax.tab, 1, ModifyTax, ind = 3)
## prepare the class level data file
class_level <-tax_glom(ps, taxrank = "Class", NArm = T)
# print class level data file info
#class_level
# transform
class_level_transformed <- transform_sample_counts(class_level, function(x) {x/sum(x)}*100)
# melting the transforming class data
class_level_transformed_psmelt <- psmelt(class_level_transformed)
# converting the class information as character
class_level_transformed_psmelt$Class <- as.character(class_level_transformed_psmelt$Class)
# merge the class with abundance less than 0.25
class_level_transformed_psmelt$Class[class_level_transformed_psmelt$Abundance < 0.25] <- "x-Minor class (<0.25%)"

# Class level barplot
Class_level_barplot <- ggplot(data = class_level_transformed_psmelt,
                              aes(x = Sample, y = Abundance, fill = Class)) +
  geom_bar(aes(fill = Class), linetype = "blank", stat = "identity", position = "stack") +
  scale_fill_manual(values = my_colours, na.value="white")+
  theme(legend.position = "bottom") +
  guides(fill = guide_legend(nrow = 5)) +
  guides(fill = guide_legend(title = "Class", title.position = "top", title.theme = element_text(face = "bold"))) +
  theme(axis.text.x = element_text(colour = "black", angle = 45, hjust = 1, vjust = 1, face = "bold")) +
  theme(axis.text.y = element_text(colour = "black", hjust = 1, vjust = 1, face = "bold")) +
  theme(axis.title.x = element_text(colour = "black", face = "bold", size = 10)) +
  theme(axis.title.y = element_text(colour = "black", face = "bold", size = 10)) +
  theme(legend.key.height = unit(0.3, "cm"), legend.key.width = unit(0.4, "cm")) +
  theme(strip.text.x = element_text(size = 10, colour = "black", face = "bold")) +
  theme(strip.text.x = element_text(margin = margin(0.025, 0, 0.025, 0, "cm"))) +
  theme(axis.line.y.left = element_line(colour = "black")) +
  theme(axis.line.x.bottom = element_line(colour = "black")) +
  theme(axis.line.x.top = element_line(colour = "black")) +
  ylab("Relative Abundance (%)")+
  ggtitle("Class level (> 0.25 %)")+
  theme(plot.title = element_text(size = 10, face = "bold"))

#saving plot in pdf
pdf("2_Class_barplot.pdf", width = 28, height = 18, paper = "a4r")
plot(Class_level_barplot)
dev.off()

# save plot as image
tiff("2_Class_barplot.tif", width = 12, height = 6, units = "in", res = 250)
plot(Class_level_barplot)
dev.off()

# saving Class numbers in Class level barplot
sink("Visualization_processing_info.txt", append = T)
writeLines("\n------------------------- \t START \t-------------------------\n")
paste("Class number in Class level barplot (> 0.25 %): ", length(unique(class_level_transformed_psmelt$Class)))
writeLines("\n------------------------- \t END \t-------------------------\n")
sink()

# saving plot as html widget
barplot_class<-ggplotly(Class_level_barplot)
htmlwidgets::saveWidget(as_widget(barplot_class), "2_Class_barplot.html")

#####################################################################################################

# Order level
# replace the NA taxonomy with the highest known taxonomy
tax_table(ps)[, 4] <- apply(tax.tab, 1, ModifyTax, ind = 4)
# prepare the order level data file
order_level <-tax_glom(ps, taxrank = "Order", is.na("Order"))
# print order level data file info
#order_level
# transform
order_level_transformed <- transform_sample_counts(order_level, function(x) {x/sum(x)}*100)
# melting the transforming order data
order_level_transformed_psmelt <- psmelt(order_level_transformed)
# converting the order information as character
order_level_transformed_psmelt$Order <- as.character(order_level_transformed_psmelt$Order)
# merge the order with abundance less than 0.25
order_level_transformed_psmelt$Order[order_level_transformed_psmelt$Abundance < 0.25] <- "x-Minor order(<0.25%)"

# Order level barplot
Order_level_barplot <- ggplot(data = order_level_transformed_psmelt,
                              aes(x = Sample, y = Abundance, fill = Order)) +
  geom_bar(aes(fill=Order), linetype = "blank", stat = "identity", position = "stack") +
  scale_fill_manual(values = my_colours, na.value="white")+
  theme(legend.position = "bottom") +
  guides(fill=guide_legend(nrow = 5)) +
  guides(fill=guide_legend(title = "Order", title.position = "top", title.theme = element_text(face = "bold"))) +
  theme(axis.text.x = element_text(colour = "black", angle = 45, hjust = 1, vjust = 1, face = "bold")) +
  theme(axis.text.y = element_text(colour = "black", hjust = 1, vjust = 1, face = "bold")) +
  theme(axis.title.x = element_text(colour = "black", face = "bold", size = 10)) +
  theme(axis.title.y = element_text(colour = "black", face = "bold", size = 10)) +
  theme(legend.key.height = unit(0.3, "cm"), legend.key.width = unit(0.4, "cm")) +
  theme(strip.text.x = element_text(size = 10, colour = "black", face = "bold")) +
  theme(strip.text.x = element_text(margin = margin(0.025, 0, 0.025, 0, "cm"))) +
  theme(axis.line.y.left = element_line(colour = "black")) +
  theme(axis.line.x.bottom = element_line(colour = "black")) +
  theme(axis.line.x.top = element_line(colour = "black")) +
  ylab("Relative Abundance (%)")+
  ggtitle("Order level (> 0.25 %)")+
  theme(plot.title = element_text(size = 10, face = "bold"))

#saving plot in pdf
pdf("3_Order_barplot.pdf", width = 28, height = 18, paper = "a4r")
plot(Order_level_barplot)
dev.off()

# save plot as image
tiff("3_Order_barplot.tif", width = 12, height = 6, units = "in", res = 250)
plot(Order_level_barplot)
dev.off()

# saving Order number in order level barplot
sink("Visualization_processing_info.txt", append = T)
writeLines("\n------------------------- \t START \t-------------------------\n")
paste("Order number in order level barplot (> 0.25 %): ", length(unique(order_level_transformed_psmelt$Order)))
writeLines("\n------------------------- \t END \t-------------------------\n")
sink()

#saving plot as html widget
barplot_order<-ggplotly(Order_level_barplot)
htmlwidgets::saveWidget(as_widget(barplot_order), "3_Order_barplot.html")
#

################################################################################################

# Family level
# replace the NA taxonomy with the highest known taxonomy
tax_table(ps)[, 5] <- apply(tax.tab, 1, ModifyTax, ind = 5)
## prepare the family level data file
family_level <-tax_glom(ps, taxrank = "Family", is.na("Family"))
# print family level data file info
#family_level
# transform
family_level_transformed <- transform_sample_counts(family_level, function(x) {x/sum(x)}*100)
# melting the transforming family data
family_level_transformed_psmelt <- psmelt(family_level_transformed)
# converting the family information as character
family_level_transformed_psmelt$Family <- as.character(family_level_transformed_psmelt$Family)
# merge the family with abundance less than 1
family_level_transformed_psmelt$Family[family_level_transformed_psmelt$Abundance < 1] <- "x-Minor family(<1%)"

# Family level barplot
Family_level_barplot <- ggplot(data = family_level_transformed_psmelt,
                               aes(x = Sample, y = Abundance, fill = Family)) +
  geom_bar(aes(fill = Family), linetype = "blank", stat = "identity", position = "stack") +
  scale_fill_manual(values = my_colours, na.value="white")+
  theme(legend.position = "bottom") +
  guides(fill=guide_legend(title = "Family", title.position = "top", title.theme = element_text(face = "bold"))) +
  theme(axis.text.x = element_text(colour = "black", angle = 45, hjust = 1, vjust = 1, face = "bold")) +
  theme(axis.text.y = element_text(colour = "black", hjust = 1, vjust = 1, face = "bold")) +
  theme(axis.title.x = element_text(colour = "black", face = "bold", size = 10)) +
  theme(axis.title.y = element_text(colour = "black", face = "bold", size = 10)) +
  theme(legend.key.height = unit(0.2, "cm"), legend.key.width = unit(0.3, "cm")) +
  theme(strip.text.x = element_text(size = 10, colour = "black", face = "bold")) +
  theme(strip.text.x = element_text(margin = margin(0.025, 0, 0.025, 0, "cm"))) +
  theme(axis.line.y.left = element_line(colour = "black")) +
  theme(axis.line.x.bottom = element_line(colour = "black")) +
  theme(axis.line.x.top = element_line(colour = "black")) +
  ylab("Relative Abundance (%)")+
  ggtitle("Family level (> 1 %)")+
  theme(plot.title = element_text(size = 10, face = "bold"))

#saving plot in pdf
pdf("4_Family_barplot.pdf", width = 28, height = 18, paper = "a4r")
plot(Family_level_barplot)
dev.off()

# save plot as image
tiff("4_Family_barplot.tif", width = 12, height = 6, units = "in", res = 250)
plot(Family_level_barplot)
dev.off()

# saving Family number in family level barplot
sink("Visualization_processing_info.txt", append = T)
writeLines("\n------------------------- \t START \t-------------------------\n")
paste("Family number in family level barplot(> 1 %): ", length(unique(family_level_transformed_psmelt$Family)))
writeLines("\n------------------------- \t END \t-------------------------\n")
sink()

#saving plot as html widget
barplot_family<-ggplotly(Family_level_barplot)
htmlwidgets::saveWidget(as_widget(barplot_family), "4_Family_barplot.html")


############################################################################################################

#heatmapping for abundance more than 1%
family_level_transformed_forheatmap <- transform_sample_counts(family_level, function(x) x / sum(x)*100 )

family_level_transformed_forheatmap_morethan1 <- filter_taxa(family_level_transformed_forheatmap, function(x) sum(x) > 1, TRUE)

  Heatmap_family <- plot_heatmap(family_level_transformed_forheatmap_morethan1,
                               taxa.label = "Family",
                               title = "Family level (> 1 %)",
                               sample.order = "Sample_Names",
                               low = "#FEFE62", high = "#D35FB7", na.value = "white") +
  theme(strip.text.x = element_text(size = 10, colour = "black", face = "bold")) +
  theme(strip.text.x = element_text(margin = margin(0.025, 0, 0.025, 0, "cm"))) +
  theme(legend.position = "right") +
  theme(legend.text = element_blank()) +
  theme(legend.title = element_text(face = "bold", size = 10)) +
  theme(axis.text.x = element_text(colour = "black", angle = 45, hjust = 1, vjust = 1, face = "bold", size = 8)) +
  theme(axis.text.y = element_text(colour = "black", angle = 0, hjust = 1, face = "bold", size = 7)) +
  theme(axis.line.y.left = element_line(colour = "black")) +
  theme(axis.line.x.bottom = element_line(colour = "black")) +
  theme(axis.line.x.top = element_line(colour = "black")) +
  theme(axis.title.x = element_text(colour = "black", face = "bold", size = 8)) +
  theme(axis.title.y = element_text(colour = "black", face = "bold", size = 10))

#saving plot in pdf
pdf("4_Family_heatmap.pdf", width = 28, height = 18, paper = "a4r")
plot(Heatmap_family)
dev.off()

# save plot as image
tiff("4_Family_heatmap.tif", width = 12, height = 6, units = "in", res = 250)
plot(Heatmap_family)
dev.off()

# saving plot as html widget
family_heatmap<-ggplotly(Heatmap_family)
htmlwidgets::saveWidget(as_widget(family_heatmap), "4_Family_heatmap.html")

#############################################################################################################################

# Genus level
# replace the NA taxonomy with the highest known taxonomy
tax_table(ps)[, 6] <- apply(tax.tab, 1, ModifyTax, ind = 6)
# prepare the genus level data file
genus_level <-tax_glom(ps, taxrank = "Genus", is.na("Genus"))
# print genus level data file info
#genus_level
# transform
genus_level_transformed <- transform_sample_counts(genus_level, function(x) {x/sum(x)}*100)
# melting the transforming genus data
genus_level_transformed_psmelt <- psmelt(genus_level_transformed)
# converting the genus information as character
genus_level_transformed_psmelt$Genus <- as.character(genus_level_transformed_psmelt$Genus)
# merge the genus with abundance less than 1
genus_level_transformed_psmelt$Genus[genus_level_transformed_psmelt$Abundance < 1] <- "x-Minor genus(<1%)"

# Genus level barplot
Genus_level_barplot <- ggplot(data = genus_level_transformed_psmelt,
                              aes(x = Sample, y = Abundance, fill = Genus)) +
  geom_bar(aes(color = Genus, fill = Genus), linetype = "blank", stat = "identity", position = "stack") +
  scale_fill_manual(values = my_colours, na.value="white")+
  theme(legend.position = "bottom") +
  guides(fill=guide_legend(title = "Genus", title.position = "top", title.theme = element_text(face = "bold"))) +
  theme(axis.text.x = element_text(colour = "black", angle = 45, hjust = 1, vjust = 1, face = "bold")) +
  theme(axis.text.y = element_text(colour = "black", hjust = 1, vjust = 1, face = "bold")) +
  theme(axis.title.x = element_text(colour = "black", face = "bold", size = 10)) +
  theme(axis.title.y = element_text(colour = "black", face = "bold", size = 10)) +
  theme(legend.key.height = unit(0.3, "cm"), legend.key.width = unit(0.3, "cm")) +
  theme(strip.text.x = element_text(size = 10, colour = "black", face = "bold")) +
  theme(strip.text.x = element_text(margin = margin(0.025, 0, 0.025, 0, "cm"))) +
  theme(axis.line.y.left = element_line(colour = "black")) +
  theme(axis.line.x.bottom = element_line(colour = "black")) +
  theme(axis.line.x.top = element_line(colour = "black")) +
  ylab("Relative Abundance (%)")+
  ggtitle("Genus level (> 1 %)")+
  theme(plot.title = element_text(size = 10, face = "bold"))

#saving plot in pdf
pdf("5_Genus_barplot.pdf", width = 28, height = 18, paper = "a4r")
plot(Genus_level_barplot)
dev.off()

# save plot as image
tiff("5_Genus_barplot.tif", width = 12, height = 6, units = "in", res = 250)
plot(Genus_level_barplot)
dev.off()

# saving Genus number in genus level barplot
sink("Visualization_processing_info.txt", append = T)
writeLines("\n------------------------- \t START \t-------------------------\n")
paste("Genus number in genus level barplot(> 1 %): ", length(unique(genus_level_transformed_psmelt$Genus)))
writeLines("\n------------------------- \t END \t-------------------------\n")
sink()

#saving plot as html widget
barplot_genus<-ggplotly(Genus_level_barplot)
htmlwidgets::saveWidget(as_widget(barplot_genus), "5_Genus_barplot.html")

###########

# heatmapping for abundance more than 1%
genus_level_transformed_forheatmap <- transform_sample_counts(genus_level, function(x) x / sum(x)*100 )

genus_level_transformed_forheatmap_morethan1 <- filter_taxa(genus_level_transformed_forheatmap, function(x) sum(x) > 1, TRUE)

Heatmap_Genus <- plot_heatmap(genus_level_transformed_forheatmap_morethan1,
                              taxa.label = "Genus",
                              sample.order = "Sample_Names",
                              low = "#FEFE62", high = "#D35FB7", na.value = "white",
                              title = "Genus level (> 1 %)") +
  theme(strip.text.x = element_text(size = 10, colour = "black", face = "bold")) +
  theme(strip.text.x = element_text(margin = margin(0.025, 0, 0.025, 0, "cm"))) +
  theme(legend.position = "right") +
  theme(legend.title = element_text(face = "bold", size = 10)) +
  theme(legend.text = element_blank()) +
  theme(axis.text.x = element_text(colour = "black", angle = 45, hjust = 1, vjust = 1, face = "bold", size = 10)) +
  theme(axis.text.y = element_text(colour = "black", angle = 0, hjust = 1, size = 7, face = "bold")) +
  theme(axis.line.y.left = element_line(colour = "black")) +
  theme(axis.line.x.bottom = element_line(colour = "black")) +
  theme(axis.line.x.top = element_line(colour = "black")) +
  theme(axis.title.x = element_text(colour = "black", face = "bold", size = 8)) +
  theme(axis.title.y = element_text(colour = "black", face = "bold", size = 12))

# saving plot in pdf
pdf("5_Genus_heatmap.pdf", width = 28, height = 18, paper = "a4r")
plot(Heatmap_Genus)
dev.off()

# save plot as image
tiff("5_Genus_heatmap.tif", width = 12, height = 6, units = "in", res = 250)
plot(Heatmap_Genus)
dev.off()

# saving plot as html widget
Genus_Heatmap<-ggplotly(Heatmap_Genus)
htmlwidgets::saveWidget(as_widget(Genus_Heatmap), "5_Genus_heatmap.html")

####################################################################################################

######################
# Species level
# replace the NA taxonomy with the highest known taxonomy
tax_table(ps)[, 7] <- apply(tax.tab, 1, ModifyTax, ind = 7)
# prepare the Species level data file
Species_level <- tax_glom(ps, taxrank = "Species", is.na("Species"))
#print Species level data file info
#Species_level
#transform
Species_level_transformed <- transform_sample_counts(Species_level, function(x) {x/sum(x)}*100)
#melting the transforming Species data
Species_level_transformed_psmelt <- psmelt(Species_level_transformed)
#converting the Species information as character
Species_level_transformed_psmelt$Species <- as.character(Species_level_transformed_psmelt$Species)
#merge the Species with abundance less than 5
Species_level_transformed_psmelt$Species[Species_level_transformed_psmelt$Abundance < 5] <- "x-Minor Species(<5%)"

# Species level barplot
Species_level_barplot <- ggplot(data = Species_level_transformed_psmelt,
                                aes(x = Sample, y = Abundance, fill = Species)) +
  geom_bar(aes(color = Species, fill = Species), linetype = "blank", stat = "identity", position = "stack") +
  scale_fill_manual(values = my_colours, na.value="white")+
  theme(legend.position = "bottom") +
  guides(fill=guide_legend(title = "Species", title.position = "top", title.theme = element_text(face = "bold"))) +
  theme(axis.text.x = element_text(colour = "black", angle = 45, hjust = 1, vjust = 1, face = "bold")) +
  theme(axis.text.y = element_text(colour = "black", hjust = 1, vjust = 1, face = "bold")) +
  theme(axis.title.x = element_text(colour = "black", face = "bold", size = 10)) +
  theme(axis.title.y = element_text(colour = "black", face = "bold", size = 10)) +
  theme(legend.key.height = unit(0.3, "cm"), legend.key.width = unit(0.3, "cm")) +
  theme(strip.text.x = element_text(size = 10, colour = "black", face = "bold")) +
  theme(strip.text.x = element_text(margin = margin(0.025, 0, 0.025, 0, "cm"))) +
  theme(axis.line.y.left = element_line(colour = "black")) +
  theme(axis.line.x.bottom = element_line(colour = "black")) +
  theme(axis.line.x.top = element_line(colour = "black")) +
  ylab("Relative Abundance (%)")+
  ggtitle("Species level (> 5 %)")+
  theme(plot.title = element_text(size = 10, face = "bold"))

#saving plot in pdf
pdf("6_Species_barplot.pdf", width = 28, height = 18, paper = "a4r")
plot(Species_level_barplot)
dev.off()

# save plot as image
tiff("6_Species_barplot.tif", width = 12, height = 6, units = "in", res = 250)
plot(Species_level_barplot)
dev.off()

# saving Species number in species level barplot
sink("Visualization_processing_info.txt", append = T)
writeLines("\n------------------------- \t START \t-------------------------\n")
paste("Species number in species level barplot(> 5%): ", length(unique(Species_level_transformed_psmelt$Species)))
writeLines("\n------------------------- \t END \t-------------------------\n")
sink()

# saving plot as html widget
barplot_Species<-ggplotly(Species_level_barplot)
htmlwidgets::saveWidget(as_widget(barplot_Species), "6_Species_barplot.html")

########

# heatmapping for abundance more than 5%
Species_level_transformed_forheatmap <- transform_sample_counts(Species_level, function(x) x / sum(x)*100)

Species_level_transformed_forheatmap_morethan5 <- filter_taxa(Species_level_transformed_forheatmap, function(x) sum(x) > 5, TRUE)

Heatmap_Species <-plot_heatmap(Species_level_transformed_forheatmap_morethan5,
                               taxa.label = "Species",
                               sample.order = "Sample_Names",
                               low = "#FEFE62", high = "#D35FB7", na.value = "white",
                               title = "Species level (> 5 %)") +
  theme(strip.text.x = element_text(size = 10, colour = "black", face = "bold")) +
  theme(strip.text.x = element_text(margin = margin(0.025, 0, 0.025, 0, "cm"))) +
  theme(legend.position = "right") +
  theme(legend.title = element_text(face = "bold", size = 10)) +
  theme(legend.text = element_blank()) +
  theme(axis.text.x = element_text(colour = "black", angle = 45, hjust = 1, vjust = 1, face = "bold", size = 10)) +
  theme(axis.text.y = element_text(colour = "black", angle = 0, hjust = 1, size = 7, face = "bold")) +
  theme(axis.line.y.left = element_line(colour = "black")) +
  theme(axis.line.x.bottom = element_line(colour = "black")) +
  theme(axis.line.x.top = element_line(colour = "black")) +
  theme(axis.title.x = element_text(colour = "black", face = "bold", size = 8)) +
  theme(axis.title.y = element_text(colour = "black", face = "bold", size = 12))

# saving plot in pdf
pdf("6_Species_heatmap.pdf", width = 28, height = 18, paper = "a4r")
plot(Heatmap_Species)
dev.off()

# save plot as image
tiff("6_Species_heatmap.tif", width = 12, height = 6, units = "in", res = 250)
plot(Heatmap_Species)
dev.off()

# saving plot as html widget
Species_Heatmap<-ggplotly(Heatmap_Species)
htmlwidgets::saveWidget(as_widget(Species_Heatmap), "6_Species_heatmap.html")
######################

#	Plot all relative abundance in one file
pdf(file = "Relative_abundance.pdf", width = 28, height = 18, paper = "a4r")
plot(Phylum_level_barplot)
plot(Class_level_barplot)
plot(Order_level_barplot)
plot(Family_level_barplot)
plot(Genus_level_barplot)
plot(Species_level_barplot)
dev.off()

########

# Ordination

set.seed(10)
ps.ord <- ordinate(ps, "NMDS", "bray" )
#ps.ord

# saving ordination detail
sink("Visualization_processing_info.txt", append = T)
writeLines("\n------------------------- \t START \t-------------------------\n")
paste("Ordination details: ")
ps.ord
writeLines("\n------------------------- \t END \t-------------------------\n")
sink()

# Plotting ordination

NMDS_Phylum_1 <- plot_ordination(ps, ps.ord,
                                 type="taxa",
                                 color = "Phylum")+
  geom_point(size=2, stroke=1)+
  theme(legend.title = element_text(face = "bold", size = 10))+
  facet_wrap(~Phylum)+
  theme(axis.text.x = element_text(colour = "black", angle = 0, hjust = 1, vjust = 1, face = "bold", size = 8))+
  theme(axis.text.y = element_text(colour = "black", angle = 0, hjust = 1, size = 8, face = "bold"))+
  theme(axis.line.y.left = element_line(colour = "black"))+
  theme(axis.line.x.bottom = element_line(colour = "black"))+
  theme(axis.line.x.top = element_line(colour = "black"))+
  theme(legend.position = "bottom")+
  theme(strip.text.x = element_text(size = 10, colour = "black",face = "bold"))+
  theme(strip.text.x = element_text(margin = margin(0.025,0,0.025,0, "cm")))+
  theme(axis.title.x = element_text(colour = "black", face = "bold", size = 8))+
  theme(axis.title.y = element_text(colour = "black", face = "bold", size = 8))

# saving plot in pdf
pdf("NMDS_Phylum_1.pdf", width = 28, height = 18, paper = "a4r")
plot(NMDS_Phylum_1)
dev.off()

# save plot as image
tiff("NMDS_Phylum_1.tif", width = 12, height = 6, units = "in", res = 250)
plot(NMDS_Phylum_1)
dev.off()

# saving plot as html widget
NMDS_Phylum_1_ <-ggplotly(NMDS_Phylum_1)
htmlwidgets::saveWidget(as_widget(NMDS_Phylum_1_), "NMDS_Phylum_1.html")
######################

# Plotting ordination 2

NMDS_Phylum_2 <- plot_ordination(ps, ps.ord,
                                 type="taxa",
                                 color = "Phylum")+
  geom_point(size=2, stroke=1)+
  theme(legend.title = element_text(face = "bold", size = 10))+
  theme(axis.text.x = element_text(colour = "black", angle = 0, hjust = 1, vjust = 1, face = "bold", size = 8))+
  theme(axis.text.y = element_text(colour = "black", angle = 0, hjust = 1, size = 8, face = "bold"))+
  theme(axis.line.y.left = element_line(colour = "black"))+
  theme(axis.line.x.bottom = element_line(colour = "black"))+
  theme(axis.line.x.top = element_line(colour = "black"))+
  theme(legend.position = "bottom")+
  theme(strip.text.x = element_text(size = 10, colour = "black",face = "bold"))+
  theme(strip.text.x = element_text(margin = margin(0.025,0,0.025,0, "cm")))+
  theme(axis.title.x = element_text(colour = "black", face = "bold", size = 8))+
  theme(axis.title.y = element_text(colour = "black", face = "bold", size = 8))

# saving plot in pdf
pdf("NMDS_Phylum_2.pdf", width = 28, height = 18, paper = "a4r")
plot(NMDS_Phylum_2)
dev.off()

# save plot as image
tiff("NMDS_Phylum_2.tif", width = 12, height = 6, units = "in", res = 250)
plot(NMDS_Phylum_2)
dev.off()

# saving plot as html widget
NMDS_Phylum_2_ <-ggplotly(NMDS_Phylum_2)
htmlwidgets::saveWidget(as_widget(NMDS_Phylum_2_), "NMDS_Phylum_2.html")
######################


########

# Alpha diversity analysis

Alpha_diversity <-   plot_richness(ps,
                                   measures = c("Observed", "Shannon", "Simpson"),
                                   nrow=3)+
  theme(panel.background = element_rect(fill = NA),
        panel.grid.major = element_line(colour = "grey90", linetype = "dashed"),
        panel.ontop = F)+
  labs(x="Sample", y="Alpha diversity measure")+
  theme(strip.text.x = element_text(size = 10, colour = "black",face = "bold"))+
  theme(axis.title.x = element_text(face="bold", size=10))+
  theme(axis.title.y = element_text(face="bold", size=10))+
  theme(axis.text.x  = element_text(face="bold",size=8,angle=60,hjust=1,vjust=1,colour = "black"))+
  theme(axis.text.y  = element_text(face="bold",size=8, colour = "black"))+
  theme(legend.text=element_text(size=7))+
  theme(legend.title=element_text(size=10, face = "bold", colour = "black"))+
  theme(strip.text.x = element_text(size = 10, colour = "black",face = "bold"))+
  theme(strip.text.x = element_text(margin = margin(0.025,0,0.025,0, "cm")))+
  theme(strip.background = element_rect(colour = "black", fill = "white"),
        strip.background.x = element_rect(colour = NA, fill = "grey90"))+
  theme(axis.line.y.left = element_line(colour = "black"))+
  theme(axis.line.x.bottom = element_line(colour = "black"))

# saving plot in pdf
pdf("Alpha_diversity.pdf", width = 28, height = 18, paper = "a4r")
plot(Alpha_diversity)
dev.off()

# save plot as image
tiff("Alpha_diversity.tif", width = 12, height = 6, units = "in", res = 250)
plot(Alpha_diversity)
dev.off()

# saving plot as html widget
Alpha_diversity_ <-ggplotly(Alpha_diversity)
htmlwidgets::saveWidget(as_widget(Alpha_diversity_), "Alpha_diversity.html")
######################

# Phylogenetic tree visualization

tree1 <- plot_tree(ps, color = "Phylum",
                  method = "sampledodge",
                  base.spacing = 0,
                  min.abundance = 100,
                  title = "Min. abundance = 100",
                  label.tips = "taxa_names",
                  justify = "jagged",
                  nodelabf=nodeplotblank,
                  ladderize = "right",
                  text.size = 1,
                  plot.margin = 0)+
  scale_color_manual(values = my_colours)+
  theme(legend.position = "bottom") +
  guides(col = guide_legend(ncol = 4))+
  theme(legend.text=element_text(size=7, face = "bold"))+
  theme(legend.key.height = unit(0.3, "cm"), legend.key.width = unit(0.4, "cm")) +
  facet_wrap(~Phylum)+
  theme(plot.title = element_text(size = 8))

  #+coord_polar(theta = "y")

# saving plot in pdf
pdf("FTHFH_OTU.tree1.pdf", width = 10, height = 10, paper = "a4r")
plot(tree1)
dev.off()

# save plot as image
tiff("FTHFH_OTU.tree1.tif", width = 10, height = 10, units = "in", res = 300)
plot(tree1)
dev.off()

# saving plot as html widget
tree1_ <-ggplotly(tree1)
htmlwidgets::saveWidget(as_widget(tree1_), "FTHFH_OTU.tree1.html")

#####

tree2 <- plot_tree(ps,
                   color = "Family",
                   method = "sampledodge",
                   base.spacing = 0,
                   min.abundance = 100,
                   label.tips = "taxa_names",
                   justify = "jagged",
                   nodelabf=nodeplotblank,
                   ladderize = "right",
                   text.size = 1,
                   title = "Min. abundance = 100",
                   plot.margin = 0)+
  scale_color_manual(values = my_colours)+
  theme(legend.position = "bottom") +
  guides(col = guide_legend(ncol = 4))+
  theme(legend.text=element_text(size=7, face = "bold"))+
  theme(legend.key.height = unit(0.2, "cm"), legend.key.width = unit(0.3, "cm"))+
  theme(plot.title = element_text(size = 4))
tree2
#+coord_polar(theta = "y")

# saving plot in pdf
pdf("FTHFH_OTU.tree2.pdf", width = 10, height = 10, paper = "a4r")
plot(tree2)
dev.off()

# save plot as image
tiff("FTHFH_OTU.tree2.tif", width = 10, height = 10, units = "in", res = 300)
plot(tree2)
dev.off()

# saving plot as html widget
tree2_ <-ggplotly(tree2)
htmlwidgets::saveWidget(as_widget(tree2_), "FTHFH_OTU.tree2.html")
######################

# Computing weighted unifrac
set.seed(10)
ps_unifrac <- UniFrac(ps, weighted = T)
# computing PCOA from weighted unifrac
set.seed(100)
ps_unifrac.pcoa=cmdscale(ps_unifrac, eig=TRUE)
#
Axis_1_value <- paste("PCoA 1 - ", round(ps_unifrac.pcoa$eig[1]/sum(ps_unifrac.pcoa$eig)*100), "%")
Axis_1_value
Axis_2_value <- paste("PCoA 2 - ", round(ps_unifrac.pcoa$eig[2]/sum(ps_unifrac.pcoa$eig)*100), "%")
Axis_2_value
# MAKING DF FROM THE pcoa POINTS
PCoA <- data.frame(PCoA1 = ps_unifrac.pcoa$points[,1], PCoA2 = ps_unifrac.pcoa$points[,2],
                   check.rows = T,
                   check.names = T)
#PCoA
#plot(PCoA)
#
sample_df_all <- data.frame(sample_data(ps))
# merging PCOA and sample data
sample_df_PCOA <- merge(sample_df_all, PCoA, by = 0,
                        sort = TRUE)
#sample_df_PCOA
#envEF
#ps_unifrac.pcoa_envEF
##
ps_unifrac.pcoa_envEF=envfit(ps_unifrac.pcoa, sample_df_all)
#
#ps_unifrac.pcoa_envEF
##########
# calculating the scores
ps_unifrac.pcoa_envEF_scores <- as.data.frame(scores(ps_unifrac.pcoa_envEF, display = "factors"))
# giving name of arrow
ps_unifrac.pcoa_envEF_scores <- cbind(ps_unifrac.pcoa_envEF_scores, Species = rownames(sample_df_all))
#ps_unifrac.pcoa_envEF_scores

# saving ordination detail
sink("Visualization_processing_info.txt", append = T)
writeLines("\n------------------------- \t START \t-------------------------\n")
paste("Weighted unifrac principal coordinate analysis details: ")
ps_unifrac.pcoa_envEF_scores
writeLines("\n------------------------- \t END \t-------------------------\n")
sink()
#  plotting
my_plot <- ggplot()+

  # making intercept at zero position
  geom_hline(yintercept = 0, linetype="dashed",color="grey20")+
  geom_vline(xintercept = 0, linetype="dashed",color="grey20")+
  # lines on axis
  theme(axis.line.y.left = element_line(colour = "black"))+
  theme(axis.line.x.bottom = element_line(colour = "black"))+
  # axis text
  theme(axis.text.x = element_text(colour = "black", face = "bold", size = 10))+
  theme(axis.text.y = element_text(colour = "black", face = "bold", size = 10))+
  # axis label style
  theme(axis.title.x = element_text(colour = "black",face = "bold",size = 10))+
  theme(axis.title.y = element_text(colour = "black",face = "bold",size = 10))+
  # making points
  geom_point(mapping=aes(x=sample_df_PCOA$PCoA1, y=sample_df_PCOA$PCoA2,
                         color=factor(sample_df_PCOA$Row.names)), size=2)+
  # colour
  scale_colour_manual(values = my_colours)+
  #point lables
  geom_text(data= sample_df_PCOA,
            x=sample_df_PCOA$PCoA1, y=sample_df_PCOA$PCoA2,
            mapping= aes(label = sample_df_PCOA$Row.names),
            size=1.5, vjust=-1)+
  # Legend on right
  theme(legend.position = "bottom")+
  guides(fill=guide_legend(ncol = 5))+
  # removing legend title
  theme(legend.title=element_blank())+
  theme(legend.key.height = unit(0.3,"cm"), legend.key.width = unit(0.4,"cm"))+
  theme(legend.text = element_text(size = 5))+
  # x and y axis label
  xlab(Axis_1_value)+
  ylab(Axis_2_value)+
  #
  ggtitle("Weighted Unifrac Principal Coordinate Analysis")

# saving plot in pdf
pdf("weighted_unifrac_PCoA.pdf", width = 10, height = 10, paper = "a4r")
  plot(my_plot)
dev.off()

# saving plot as image
tiff("weighted_unifrac_PCoA.tif", width = 8, height = 6, units = "in", res = 250)
plot(my_plot)
dev.off()

# saving plot as html widget
my_plot_ <-ggplotly(my_plot)
htmlwidgets::saveWidget(as_widget(my_plot_), "weighted_unifrac_PCoA.html")


#  plotting without legends
my_plot2 <- ggplot()+
  
  # making intercept at zero position
  geom_hline(yintercept = 0, linetype="dashed",color="grey20")+
  geom_vline(xintercept = 0, linetype="dashed",color="grey20")+
  # lines on axis
  theme(axis.line.y.left = element_line(colour = "black"))+
  theme(axis.line.x.bottom = element_line(colour = "black"))+
  # axis text
  theme(axis.text.x = element_text(colour = "black", face = "bold", size = 10))+
  theme(axis.text.y = element_text(colour = "black", face = "bold", size = 10))+
  # axis label style
  theme(axis.title.x = element_text(colour = "black",face = "bold",size = 10))+
  theme(axis.title.y = element_text(colour = "black",face = "bold",size = 10))+
  # making points
  geom_point(mapping=aes(x=sample_df_PCOA$PCoA1, y=sample_df_PCOA$PCoA2,
                         color=factor(sample_df_PCOA$Row.names)), size=2)+
  # colour
  scale_colour_manual(values = my_colours)+
  #point lables
  geom_text(data= sample_df_PCOA,
            x=sample_df_PCOA$PCoA1, y=sample_df_PCOA$PCoA2,
            mapping= aes(label = sample_df_PCOA$Row.names),
            size=1.5, vjust=-1)+
  # Legend None
  theme(legend.position = "none")+
  #guides(fill=guide_legend(ncol = 2))+
  # removing legend title
  # theme(legend.title=element_blank())+
  # theme(legend.key.height = unit(0.3,"cm"), legend.key.width = unit(0.4,"cm"))+
  # theme(legend.text = element_text(size = 8))+
  # x and y axis label
  xlab(Axis_1_value)+
  ylab(Axis_2_value)+
  #
  ggtitle("Weighted Unifrac Principal Coordinate Analysis")

# saving plot in pdf
pdf("weighted_unifrac_PCoA_2.pdf", width = 10, height = 10, paper = "a4r")
plot(my_plot2)
dev.off()

# saving plot as image
tiff("weighted_unifrac_PCoA_2.tif", width = 8, height = 6, units = "in", res = 250)
plot(my_plot2)
dev.off()

# saving plot as html widget
my_plot_2 <-ggplotly(my_plot2)
htmlwidgets::saveWidget(as_widget(my_plot_2), "weighted_unifrac_PCoA_2.html")
### End of script
