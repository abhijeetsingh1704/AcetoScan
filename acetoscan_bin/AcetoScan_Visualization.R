#!/usr/bin/env Rscript

# File: AcetoScan_Visualization.R
# Last modified: son Juni 2, 2019  19:19
# Sign: Abhi

otu_file <- "FTHFS_OTU_table_R.txt"
tax_file <- "FTHFS_TAX_table_R.txt"

getwd()

# Load required packages
suppressPackageStartupMessages(library("phyloseq"))
suppressPackageStartupMessages(library("ggplot2"))
suppressPackageStartupMessages(library("plotly"))
suppressPackageStartupMessages(library("RColorBrewer"))
suppressPackageStartupMessages(library("plyr"))
suppressPackageStartupMessages(library("dplyr"))

######
OTU_data <- read.delim(otu_file, sep = "\t", header = TRUE)
head(OTU_data)
class(OTU_data) 

# 
OTU_data_subset <- OTU_data[, -1]
OTU_data_subset
OTU_data_subset_mat <- as.matrix(OTU_data_subset, sep = "\t", header = TRUE)
OTU_data_subset_mat

row.names(OTU_data_subset_mat) <- paste0("OTU_", 1:nrow(OTU_data_subset_mat))
OTU_data_subset_mat

OTU_data_subset_mat_table <- otu_table(OTU_data_subset_mat, taxa_are_rows = TRUE)
OTU_data_subset_mat_table

######
TAX_data <- read.table(tax_file, sep = "\t", header = TRUE)
head(TAX_data)
class(TAX_data)

#
TAX_data_subset <- TAX_data[, -1]
TAX_data_subset
TAX_data_subset_mat <- as.matrix(TAX_data_subset)
TAX_data_subset_mat

row.names(TAX_data_subset_mat) <- paste0("OTU_", 1:nrow(TAX_data_subset_mat))
TAX_data_subset_mat

TAX_data_mat_table <- tax_table(TAX_data_subset_mat)
TAX_data_mat_table

# Making phyloseq object from the tax table and OTU table
ps <- phyloseq(OTU_data_subset_mat_table, TAX_data_mat_table)
# Save infor of phyloseq object
sink("Phyloseq_object_processing_info.txt")
paste("phyloseq_object: ")
print(ps)
sink()

# Visualize phyloseq object details
#sample_names(ps)
#nsamples(ps)
#ntaxa(ps)

# phylum detail
ps_table <- table(tax_table(ps)[, "Phylum"], exclude = NULL)
# save phylum detail
sink("Phyloseq_object_processing_info.txt", append = T)
paste("=======================")
paste("phyloseq_phylum_table: ")
print(ps_table)
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
sink("Phyloseq_object_processing_info.txt", append = T)
paste("=======================")
paste("Phylum_prevalence_table: ")
print(prevalence_table)
sink()

# Write the details of taxa to file
sink("Phyloseq_object_processing_info.txt", append = T)
paste("=======================")
paste("number_of_Phylum: ", length(get_taxa_unique(ps, taxonomic.rank = "Phylum")))
paste("number_of_Class: ", length(get_taxa_unique(ps, taxonomic.rank = "Class")))
paste("number_of_Order: ", length(get_taxa_unique(ps, taxonomic.rank = "Order")))
paste("number_of_Family: ", length(get_taxa_unique(ps, taxonomic.rank = "Family")))
paste("number_of_Genus: ", length(get_taxa_unique(ps, taxonomic.rank = "Genus")))
paste("number_of_Species: ", length(get_taxa_unique(ps, taxonomic.rank = "Species")))
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
my_colours = unlist(mapply(brewer.pal, colour_palette$maxcolors, rownames(colour_palette)))

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

# saving Total_Phylum_numbers_in_absolute abundance_barplot
sink("Phyloseq_object_processing_info.txt", append = T)
paste("=======================")
paste("Total Phylum numbers in absolute abundance_barplot: ", length(get_taxa_unique(ps, taxonomic.rank = "Phylum")))
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
    scale_fill_manual(values = my_colours)+
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

# saving Phylum number in phylum level barplot
sink("Phyloseq_object_processing_info.txt", append = T)
paste("=======================")
paste("Phylum number in phylum level barplot: ", length(unique(phylum_level_transformed_psmelt$Phylum)))
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
class_level_transformed_psmelt$Class[class_level_transformed_psmelt$Abundance < 0.25] <- "x-Minor class (<0.25)"

# Class level barplot
Class_level_barplot <- ggplot(data = class_level_transformed_psmelt,
        aes(x = Sample, y = Abundance, fill = Class)) +
    geom_bar(aes(fill = Class), linetype = "blank", stat = "identity", position = "stack") +
    scale_fill_manual(values = my_colours)+
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

# saving Class numbers in Class level barplot
sink("Phyloseq_object_processing_info.txt", append = T)
paste("=======================")
paste("Class number in Class level barplot (> 0.25 %): ", length(unique(class_level_transformed_psmelt$Class)))
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
order_level_transformed_psmelt$Order[order_level_transformed_psmelt$Abundance < 0.25] <- "x-Minor order(<0.25)"

# Order level barplot
Order_level_barplot <- ggplot(data = order_level_transformed_psmelt,
        aes(x = Sample, y = Abundance, fill = Order)) + 
    geom_bar(aes(fill=Order), linetype = "blank", stat = "identity", position = "stack") +
    scale_fill_manual(values = my_colours)+
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

# saving Order number in order level barplot
sink("Phyloseq_object_processing_info.txt", append = T)
paste("=======================")
paste("Order number in order level barplot (> 0.25 %): ", length(unique(order_level_transformed_psmelt$Order)))
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
family_level_transformed_psmelt$Family[family_level_transformed_psmelt$Abundance < 1] <- "x-Minor family(<1)"

# Family level barplot
Family_level_barplot <- ggplot(data = family_level_transformed_psmelt,
        aes(x = Sample, y = Abundance, fill = Family)) + 
    geom_bar(aes(fill = Family), linetype = "blank", stat = "identity", position = "stack") +
    scale_fill_manual(values = my_colours)+
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

# saving Family number in family level barplot
sink("Phyloseq_object_processing_info.txt", append = T)
paste("=======================")
paste("Family number in family level barplot(> 1 %): ", length(unique(family_level_transformed_psmelt$Family)))
sink()

#saving plot as html widget
barplot_family<-ggplotly(Family_level_barplot)
htmlwidgets::saveWidget(as_widget(barplot_family), "4_Family_barplot.html")


############################################################################################################

#heatmapping for abundance more than 1%
family_level_transformed_forheatmap <- transform_sample_counts(family_level, function(x) x / sum(x)*100 )

family_level_transformed_forheatmap_morethan1 <- filter_taxa(family_level_transformed_forheatmap, function(x) sum(x) > 1, TRUE)

Heatmap_family <- plot_heatmap(family_level_transformed_forheatmap_morethan1, 
    taxa.label = "Family", title = "Family level (> 1 %)",
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
genus_level_transformed_psmelt$Genus[genus_level_transformed_psmelt$Abundance < 1] <- "x-Minor genus(<1)"

# Genus level barplot
Genus_level_barplot <- ggplot(data = genus_level_transformed_psmelt, 
        aes(x = Sample, y = Abundance, fill = Genus)) + 
    geom_bar(aes(color = Genus, fill = Genus), linetype = "blank", stat = "identity", position = "stack") +
    scale_fill_manual(values = my_colours)+
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
                                                               
# saving Genus number in genus level barplot
sink("Phyloseq_object_processing_info.txt", append = T)
paste("=======================")
paste("Genus number in genus level barplot(> 1 %): ", length(unique(genus_level_transformed_psmelt$Genus)))
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
Species_level_transformed_psmelt$Species[Species_level_transformed_psmelt$Abundance < 5] <- "x-Minor Species(<5)"

# Species level barplot
Species_level_barplot <- ggplot(data = Species_level_transformed_psmelt, 
        aes(x = Sample, y = Abundance, fill = Species)) + 
    geom_bar(aes(color = Species, fill = Species), linetype = "blank", stat = "identity", position = "stack") +
    scale_fill_manual(values = my_colours)+
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
 
# saving Species number in species level barplot
sink("Phyloseq_object_processing_info.txt", append = T)
paste("=======================")
paste("Species number in species level barplot(> 5%): ", length(unique(Species_level_transformed_psmelt$Species)))
sink()                                                             

# saving plot as html widget
barplot_Species<-ggplotly(Species_level_barplot)
htmlwidgets::saveWidget(as_widget(barplot_Species), "6_Species_barplot.html")

########

# heatmapping for abundance more than 5%
Species_level_transformed_forheatmap <- transform_sample_counts(Species_level, function(x) x / sum(x)*100 )

Species_level_transformed_forheatmap_morethan5 <- filter_taxa(Species_level_transformed_forheatmap, function(x) sum(x) > 5, TRUE)

Heatmap_Species <-plot_heatmap(Species_level_transformed_forheatmap_morethan5, 
        taxa.label = "Species",
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

# saving plot as html widget
Species_Heatmap<-ggplotly(Heatmap_Species)
htmlwidgets::saveWidget(as_widget(Species_Heatmap), "6_Species_heatmap.html")
######################


### End of script
