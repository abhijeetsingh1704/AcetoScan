getwd()

list.files()

suppressPackageStartupMessages(library("phyloseq"))
suppressPackageStartupMessages(library("ggplot2"))
suppressPackageStartupMessages(library("plotly"))
suppressPackageStartupMessages(library("RColorBrewer"))
suppressPackageStartupMessages(library("randomcoloR"))
suppressPackageStartupMessages(library("plyr"))
suppressPackageStartupMessages(library("dplyr"))


  ######
OTU_data<- read.delim("FTHFS_OTU_table_R.txt", sep = "\t", header = T)
head(OTU_data)
class(OTU_data) 

# 
OTU_data_subset <- OTU_data[,-1]
OTU_data_subset
OTU_data_subset_mat <- as.matrix(OTU_data_subset, sep = "\t", header =T)
OTU_data_subset_mat

row.names(OTU_data_subset_mat) <- paste0("OTU_",1:nrow(OTU_data_subset_mat))
OTU_data_subset_mat

OTU_data_subset_mat_table <- otu_table(OTU_data_subset_mat, taxa_are_rows = T)
OTU_data_subset_mat_table

######
TAX_data <- read.table("FTHFS_TAX_table_R.txt", sep = "\t", header = T)
head(TAX_data)
class(TAX_data)

#
TAX_data_subset <- TAX_data[,-1]
TAX_data_subset
TAX_data_subset_mat <- as.matrix(TAX_data_subset)
TAX_data_subset_mat

row.names(TAX_data_subset_mat) <- paste0("OTU_",1:nrow(TAX_data_subset_mat))
TAX_data_subset_mat

TAX_data_mat_table <- tax_table(TAX_data_subset_mat)
TAX_data_mat_table


#

ps <- phyloseq(OTU_data_subset_mat_table,TAX_data_mat_table)
ps


#
sample_names(ps)
nsamples(ps)
ntaxa(ps)

#
ps_table <- table(tax_table(ps)[,"Phylum"],exclude = NULL)
ps_table


# Compute prevalence of each feature, store as data.frame
prevalence_dataframe <- apply(X = otu_table(ps),
                              MARGIN = ifelse(taxa_are_rows(ps), yes = 1, no = 2),
                              FUN = function(x){sum(x > 0)})
prevalence_dataframe

# Add taxonomy and total read counts to this data.frame
prevalence_dataframe <- data.frame(Prevalence = prevalence_dataframe,
                                   TotalAbundance = taxa_sums(ps),
                                   tax_table(ps))
prevalence_dataframe

#Compute the mean prevalences and total abundance of the features in each phylum
prevalence_table <- plyr::ddply(prevalence_dataframe, "Phylum", function(df1){
  data.frame(mean_prevalence=mean(df1$Prevalence),total_abundance=sum(df1$TotalAbundance,na.rm = T),stringsAsFactors = F)
})


#visualize the total and average prevalance 
prevalence_table


#save the prevalance table as text file
write.table(prevalence_table, "prevalence_table_normalized.txt", sep = "\t",row.names = TRUE)

#Count the number of sequence variants (SVs) which will be included in study
# to mention in manuscript
ntaxa(ps)

#Get the number of phylum and genus would be present
number_of_Phylum <- length(get_taxa_unique(ps, taxonomic.rank = "Phylum"))
number_of_Class <- length(get_taxa_unique(ps, taxonomic.rank = "Class"))
number_of_Order <- length(get_taxa_unique(ps, taxonomic.rank = "Order"))
number_of_Family <- length(get_taxa_unique(ps, taxonomic.rank = "Family"))
number_of_Genus <- length(get_taxa_unique(ps, taxonomic.rank = "Genus"))
number_of_Species <- length(get_taxa_unique(ps, taxonomic.rank = "Species"))
#check the numbers
number_of_Phylum
number_of_Class
number_of_Order
number_of_Family
number_of_Genus
number_of_Species

##Calculate abundance of different ranks
##use filtered phylum file
#   taxonomy table   
tax.tab <- data.frame(tax_table(ps))
tax.tab

#function for the modification of OTU table

ModifyTax <- function(x,ind){
  #   xth row in the dataframe
  #   ind taxonomy level to change
  if(is.na(x[ind])){
    nonNa <- which(!is.na(x[-ind]))
    maxNonNa <- max(nonNa)
    x[ind] <- paste(x[maxNonNa],".",x[ind])
  }else{x[ind] <- x[ind]}
}

######################  Phylum Absolute abundance

Phylum_Absolute_abundance <-plot_bar(ps, fill="Phylum") + 
  theme(legend.position = "bottom") + 
  theme(axis.text.x = element_text(colour = "black", angle = 45, hjust = 1, vjust = 1, face = "bold"))+
  theme(legend.key.height = unit(0.3,"cm"), legend.key.width = unit(0.4,"cm"))+
  theme(strip.text.x = element_text(size = 10, colour = "black",face = "bold"))+
  theme(strip.text.x = element_text(margin = margin(0.025,0,0.025,0, "cm")))+
  theme(axis.text.x = element_text(colour = "black", angle = 45, hjust = 1, vjust = 1, face = "bold", size = 8))+
  theme(axis.text.y = element_text(colour = "black", angle = 0, hjust = 1, size = 8, face = "bold"))+
  theme(axis.line.y.left = element_line(colour = "black"))+
  theme(axis.line.x.bottom = element_line(colour = "black"))+
  theme(axis.line.x.top = element_line(colour = "black"))+
  theme(axis.title.x = element_text(colour = "black", face = "bold", size = 12))+
  theme(axis.title.y = element_text(colour = "black", face = "bold", size = 10))+
  
  ylab("Absolute Abundance (counts)")

Phylum_Absolute_abundance

# save plot as pdf
pdf("Barplot_Phylum_Absolute_abundance.pdf", width = 28, height = 18, paper = "a4r")
plot(Phylum_Absolute_abundance)
dev.off()

# save plot as html widget
#Phylum_Absolute_abundance_gg <- ggplotly(Phylum_Absolute_abundance)
#htmlwidgets::saveWidget(as_widget(Phylum_Absolute_abundance_gg), "Barplot_Phylum_Absolute_abundance.html")

#transformation of the sample counts of a taxa abundance matrix according 
#to the function/Normalizing
ps_transformed <- transform_sample_counts(ps, function(x) x/sum(x)*100)
ps_transformed

# psmelt command for melting and merging the phyloseq classes, 
#to be used for graphics in ggplot2
ps_transformed_psmelt <- psmelt(ps_transformed)
#visualize the melted and merged file which has minor phylum
ps_transformed_psmelt


#this command is to convert the numeric attributes of phylum 
#information in melted-merged file to convert into characters, 
#thus easier to merge the minor phylum information for abundance calculation
ps_transformed_psmelt$Phylum <- as.character(ps_transformed_psmelt$Phylum)



#plotting the data in bar plot, colour should be according to the number of phylym you wanted to plot in the graph
ps_transformed_psmelt_ggplot <- ggplot(data=ps_transformed_psmelt, 
                                                   aes(x=Sample, y=Abundance, fill=Phylum)) + 
  geom_bar(aes(), stat="identity", position="stack")+ 
  
  scale_fill_manual(values = distinctColorPalette(length(unique(ps_transformed_psmelt))))+
  
  theme(legend.position = "bottom")+
  guides(fill=guide_legend(nrow=3))+
  
  theme(axis.text.x = element_text(colour = "black", angle = 45, hjust = 1, vjust = 1, face = "bold"))+
  theme(axis.text.y = element_text(colour = "black", hjust = 1, vjust = 1, face = "bold"))+
  
  theme(axis.title.x = element_text(colour = "black", face = "bold", size = 10))+
  theme(axis.title.y = element_text(colour = "black", face = "bold", size = 10))+
  
  theme(legend.key.height = unit(0.3,"cm"), legend.key.width = unit(0.4,"cm"))+
  theme(strip.text.x = element_text(size = 10, colour = "black",face = "bold"))+
  theme(strip.text.x = element_text(margin = margin(0.025,0,0.025,0, "cm")))+
  
  theme(axis.line.y.left = element_line(colour = "black"))+
  theme(axis.line.x.bottom = element_line(colour = "black"))+
  theme(axis.line.x.top = element_line(colour = "black"))


ps_transformed_psmelt_ggplot


################################################

########################## VISUALIZATION PART / MAKING MAIN PLOTS
#Kingdom level
Kingdom_level <-tax_glom(ps, taxrank="Kingdom", is.na("Kingdom"))
#visualise the filtered taxa at Kingdom level
Kingdom_level
#transform the taxa(Kingdom) information in the 100% stacked table
Kingdom_level_transformed <- transform_sample_counts(Kingdom_level, function(x) {x/sum(x)}*100)
#melting the transforming Kingdom data
Kingdom_level_transformed_psmelt <- psmelt(Kingdom_level_transformed)
#converting the Kingdom information as character
Kingdom_level_transformed_psmelt$Kingdom <- as.character(Kingdom_level_transformed_psmelt$Kingdom)
#PLOT THE KINGDOM GRAPH
Kingdom_level_transformed_psmelt_barplot <- ggplot(data=Kingdom_level_transformed_psmelt, 
                                                   aes(x=Sample, y=Abundance, fill=Kingdom))+ 
  
  theme(legend.position = "bottom")+
  theme(axis.text.x = element_text(angle = 45, hjust = 1, colour = "black", face = "bold"))+
  theme(axis.text.y = element_text(colour = "black"))+
  geom_bar(aes(fill=Kingdom), linetype="blank", stat="identity",position="stack")+
  theme(legend.position = "bottom")+
  theme(axis.text.x = element_text(colour = "black", angle = 45, hjust = 1, vjust = 1, face = "bold"))+
  theme(axis.text.y = element_text(colour = "black", hjust = 1, vjust = 1, face = "bold"))+
  
  theme(axis.title.x = element_text(colour = "black", face = "bold", size = 10))+
  theme(axis.title.y = element_text(colour = "black", face = "bold", size = 10))+
  
  theme(legend.key.height = unit(0.4,"cm"), legend.key.width = unit(0.4,"cm"))+
  theme(strip.text.x = element_text(size = 10, colour = "black",face = "bold"))+
  theme(strip.text.x = element_text(margin = margin(0.025,0,0.025,0, "cm")))+
  
  theme(axis.line.y.left = element_line(colour = "black"))+
  theme(axis.line.x.bottom = element_line(colour = "black"))+
  theme(axis.line.x.top = element_line(colour = "black"))
  
  
#visualize the kingdom plot
Kingdom_level_transformed_psmelt_barplot


#####################################################################
####
#Phylum level
#   replace the NA taxonomy with the highest known taxonomy
tax_table(ps)[,2] <- apply(tax.tab,1,ModifyTax,ind=2)
# prepare the phylum level data file
phylum_level <-tax_glom(ps, taxrank="Phylum", is.na("Phylum"))
#visualise the filtered taxa at phylum level
phylum_level
#transform the taxa(phylum) information in the 100% stacked table
phylum_level_transformed <- transform_sample_counts(phylum_level, function(x) {x/sum(x)}*100)
#melting the transforming phylum data
phylum_level_transformed_psmelt <- psmelt(phylum_level_transformed)
#converting the phylum information as character
phylum_level_transformed_psmelt$Phylum <- as.character(phylum_level_transformed_psmelt$Phylum)
#https://www.r-bloggers.com/how-to-expand-color-palette-with-ggplot-and-rcolorbrewer/
#count the number of phylum which will be in plot
Total_Phylum_numbers_for_plot <- length(unique(phylum_level_transformed_psmelt$Phylum))
Total_Phylum_numbers_for_plot

#
phylum_level_barplot <- 
  
  ggplot(data=phylum_level_transformed_psmelt, aes(x=Sample, y=Abundance, fill=Phylum))+ 
  
  
  geom_bar(aes(fill=Phylum), linetype="blank", stat="identity",position="stack")+
  scale_fill_manual(values = distinctColorPalette(length(unique(phylum_level_transformed_psmelt))))+
  
  
  theme(legend.position = "bottom")+
  guides(fill=guide_legend(nrow=3))+
  
  theme(axis.text.x = element_text(colour = "black", angle = 45, hjust = 1, vjust = 1, face = "bold"))+
  theme(axis.text.y = element_text(colour = "black", hjust = 1, vjust = 1, face = "bold"))+
  
  
  theme(axis.title.x = element_text(colour = "black", face = "bold", size = 10))+
  theme(axis.title.y = element_text(colour = "black", face = "bold", size = 10))+
  
  ylab("Relative Abundance (%)")+
  
  theme(legend.key.height = unit(0.3,"cm"), legend.key.width = unit(0.4,"cm"))+
  theme(strip.text.x = element_text(size = 10, colour = "black",face = "bold"))+
  theme(strip.text.x = element_text(margin = margin(0.025,0,0.025,0, "cm")))+
  
  theme(axis.line.y.left = element_line(colour = "black"))+
  theme(axis.line.x.bottom = element_line(colour = "black"))+
  theme(axis.line.x.top = element_line(colour = "black"))+
  theme(legend.title=element_text(size=10, face = "bold", colour = "black"))

#

phylum_level_barplot

#saving plot in pdf
pdf("phylum_level_Barplot.pdf", width = 28, height = 18, paper = "a4r")
plot(phylum_level_barplot)
dev.off()

#saving plot as html widget
#barplot_phylum<-ggplotly(phylum_level_barplot)
#htmlwidgets::saveWidget(as_widget(barplot_phylum), "Barplot_phylum.html")

#####################################################################################################


#Class level
#   replace the NA taxonomy with the highest known taxonomy
tax_table(ps)[,3] <- apply(tax.tab,1,ModifyTax,ind=3)
## prepare the class level data file
class_level <-tax_glom(ps, taxrank="Class", NArm = T)
#print class level data file info
class_level
#transform
class_level_transformed <- transform_sample_counts(class_level, function(x) {x/sum(x)}*100)
#melting the transforming class data
class_level_transformed_psmelt <- psmelt(class_level_transformed)
#converting the class information as character
class_level_transformed_psmelt$Class <- as.character(class_level_transformed_psmelt$Class)
#merge the class with abundance less than 1
class_level_transformed_psmelt$Class[class_level_transformed_psmelt$Abundance < 0.25] <- "x-Minor class (<0.25)"
#count the number of phylum which will be in plot
Total_Class_numbers_for_plot <- length(unique(class_level_transformed_psmelt$Class))
Total_Class_numbers_for_plot

#Plot the bar-plot at class level
class_level_barplot <- 
  ggplot(data=class_level_transformed_psmelt, aes(x=Sample, y=Abundance, fill=Class))+
  
  
  geom_bar(aes(fill=Class), linetype="blank", stat="identity",position="stack")+
  scale_fill_manual(values = distinctColorPalette(length(unique(class_level_transformed_psmelt$Class))))+
  
  theme(legend.position = "bottom")+
  guides(fill=guide_legend(nrow=5))+
  guides(fill=guide_legend(title = "Class", title.position = "top", title.theme = element_text(face = "bold")))+
  
  theme(axis.text.x = element_text(colour = "black", angle = 45, hjust = 1, vjust = 1, face = "bold"))+
  theme(axis.text.y = element_text(colour = "black", hjust = 1, vjust = 1, face = "bold"))+
  
  theme(axis.title.x = element_text(colour = "black", face = "bold", size = 10))+
  theme(axis.title.y = element_text(colour = "black", face = "bold", size = 10))+
  
  theme(legend.key.height = unit(0.3,"cm"), legend.key.width = unit(0.4,"cm"))+
  theme(strip.text.x = element_text(size = 10, colour = "black",face = "bold"))+
  theme(strip.text.x = element_text(margin = margin(0.025,0,0.025,0, "cm")))+
  
  theme(axis.line.y.left = element_line(colour = "black"))+
  theme(axis.line.x.bottom = element_line(colour = "black"))+
  theme(axis.line.x.top = element_line(colour = "black"))+
  
  ylab("Relative Abundance (%)")

class_level_barplot

#saving plot in pdf
pdf("class_level_Barplot.pdf", width = 28, height = 18, paper = "a4r")
plot(class_level_barplot)
dev.off()

#saving plot as html widget
#barplot_class<-ggplotly(class_level_barplot)
#htmlwidgets::saveWidget(as_widget(barplot_class), "Barplot_class.html")

#####################################################################################################

#Order level
#   replace the NA taxonomy with the highest known taxonomy
tax_table(ps)[,4] <- apply(tax.tab,1,ModifyTax,ind=4)
# prepare the order level data file
order_level <-tax_glom(ps, taxrank="Order", is.na("Order"))
#print order level data file info
order_level
#transform
order_level_transformed <- transform_sample_counts(order_level, function(x) {x/sum(x)}*100)
#melting the transforming order data
order_level_transformed_psmelt <- psmelt(order_level_transformed)
#converting the order information as character
order_level_transformed_psmelt$Order <- as.character(order_level_transformed_psmelt$Order)
#merge the order with abundance less than 1
order_level_transformed_psmelt$Order[order_level_transformed_psmelt$Abundance < 0.25] <- "x-Minor order(<0.25)"
#count the number of phylum which will be in plot
Total_Order_numbers_for_plot <- length(unique(order_level_transformed_psmelt$Order))
Total_Order_numbers_for_plot

#Plot the bar-plot at order level
order_level_barplot <- 
  ggplot(data=order_level_transformed_psmelt, aes(x=Sample, y=Abundance, fill=Order))+ 
  
  
  geom_bar(aes(fill=Order), linetype="blank", stat="identity",position="stack")+
  scale_fill_manual(values = distinctColorPalette(length(unique(order_level_transformed_psmelt$Order))))+
  
  theme(legend.position = "bottom")+
  guides(fill=guide_legend(nrow=5))+
  guides(fill=guide_legend(title = "Order", title.position = "top", title.theme = element_text(face = "bold")))+
  
  theme(axis.text.x = element_text(colour = "black", angle = 45, hjust = 1, vjust = 1, face = "bold"))+
  theme(axis.text.y = element_text(colour = "black", hjust = 1, vjust = 1, face = "bold"))+
  
  theme(axis.title.x = element_text(colour = "black", face = "bold", size = 10))+
  theme(axis.title.y = element_text(colour = "black", face = "bold", size = 10))+
  
  theme(legend.key.height = unit(0.3,"cm"), legend.key.width = unit(0.4,"cm"))+
  theme(strip.text.x = element_text(size = 10, colour = "black",face = "bold"))+
  theme(strip.text.x = element_text(margin = margin(0.025,0,0.025,0, "cm")))+
  
  theme(axis.line.y.left = element_line(colour = "black"))+
  theme(axis.line.x.bottom = element_line(colour = "black"))+
  theme(axis.line.x.top = element_line(colour = "black"))+
  
  ylab("Relative Abundance (%)")

order_level_barplot

#saving plot in pdf
pdf("order_level_Barplot.pdf", width = 28, height = 18, paper = "a4r")
plot(order_level_barplot)
dev.off()

#saving plot as html widget
#barplot_order<-ggplotly(order_level_barplot)
#htmlwidgets::saveWidget(as_widget(barplot_order), "Barplot_order.html")
#

################################################################################################

#Family level
#   replace the NA taxonomy with the highest known taxonomy
tax_table(ps)[,5] <- apply(tax.tab,1,ModifyTax,ind=5)
## prepare the family level data file
family_level <-tax_glom(ps, taxrank="Family", is.na("Family"))
#print family level data file info
family_level
#transform
family_level_transformed <- transform_sample_counts(family_level, function(x) {x/sum(x)}*100)
#melting the transforming family data
family_level_transformed_psmelt <- psmelt(family_level_transformed)
#converting the family information as character
family_level_transformed_psmelt$Family <- as.character(family_level_transformed_psmelt$Family)
#merge the family with abundance less than 1
family_level_transformed_psmelt$Family[family_level_transformed_psmelt$Abundance < 0.5] <- "x-Minor family(<0.5)"

#count the number of phylum which will be in plot
Total_Family_numbers_for_plot <- length(unique(family_level_transformed_psmelt$Family))
Total_Family_numbers_for_plot

#Plot the bar-plot at family level
family_level_barplot <- ggplot(data=family_level_transformed_psmelt, aes(x=Sample, y=Abundance, fill=Family))+ 
  
  geom_bar(aes(fill=Family), linetype="blank", stat="identity",position = "stack")+
  
  
  scale_fill_manual(values = distinctColorPalette(length(unique(family_level_transformed_psmelt$Family))))+
  
  theme(legend.position = "bottom")+
  guides(fill=guide_legend(title = "Family", title.position = "top", title.theme = element_text(face = "bold")))+
  
  theme(axis.text.x = element_text(colour = "black", angle = 45, hjust = 1, vjust = 1, face = "bold"))+
  theme(axis.text.y = element_text(colour = "black", hjust = 1, vjust = 1, face = "bold"))+
  
  theme(axis.title.x = element_text(colour = "black", face = "bold", size = 10))+
  theme(axis.title.y = element_text(colour = "black", face = "bold", size = 10))+
  
  theme(legend.key.height = unit(0.2,"cm"), legend.key.width = unit(0.3,"cm"))+
  
  theme(strip.text.x = element_text(size = 10, colour = "black",face = "bold"))+
  theme(strip.text.x = element_text(margin = margin(0.025,0,0.025,0, "cm")))+
  
  theme(axis.line.y.left = element_line(colour = "black"))+
  theme(axis.line.x.bottom = element_line(colour = "black"))+
  theme(axis.line.x.top = element_line(colour = "black"))+
  
  ylab("Relative Abundance (%)")

#
family_level_barplot

#saving plot in pdf
pdf("family_level_Barplot.pdf", width = 28, height = 18, paper = "a4r")
plot(family_level_barplot)
dev.off()

#saving plot as html widget
#barplot_family<-ggplotly(family_level_barplot)
#htmlwidgets::saveWidget(as_widget(barplot_family), "Barplot_family.html")


############################################################################################################

#heatmapping for abundance more than 0.5%
family_level_transformed_forheatmap <- transform_sample_counts(family_level, function(x) x / sum(x)*100 )

family_level_transformed_forheatmap_morethan0.5 <- filter_taxa(family_level_transformed_forheatmap, function(x) sum(x) > 0.5, TRUE)


Heatmap_family<-plot_heatmap(family_level_transformed_forheatmap_morethan0.5, 
                             
                             taxa.label = "Family", title = "Family level heatmap (> 0.5 % abundance)",
                             low = "grey80",high = "grey10",na.value = "white")+ 
  
  
  
  theme(strip.text.x = element_text(size = 10, colour = "black",face = "bold"))+
  theme(strip.text.x = element_text(margin = margin(0.025,0,0.025,0, "cm")))+
  
  theme(legend.position = "right")+
  theme(legend.text = element_blank())+
  theme(legend.title = element_text(face = "bold", size = 10))+
  
  theme(axis.text.x = element_text(colour = "black", angle = 45, hjust = 1, vjust = 1, face = "bold", size = 8))+
  theme(axis.text.y = element_text(colour = "black", angle = 0, hjust = 1, face = "bold", size = 7))+
  
  theme(axis.line.y.left = element_line(colour = "black"))+
  theme(axis.line.x.bottom = element_line(colour = "black"))+
  theme(axis.line.x.top = element_line(colour = "black"))+
  
  theme(axis.title.x = element_text(colour = "black", face = "bold", size = 8))+
  theme(axis.title.y = element_text(colour = "black", face = "bold", size = 10))

Heatmap_family 

#saving plot in pdf
pdf("Heatmap_family.pdf", width = 28, height = 18, paper = "a4r")
plot(Heatmap_family)
dev.off()

#saving plot as html widget
#family_heatmap<-ggplotly(Heatmap_family)
#htmlwidgets::saveWidget(as_widget(family_heatmap), "Family_Heatmap.html")

#############################################################################################################################

#Genus level
#   replace the NA taxonomy with the highest known taxonomy
tax_table(ps)[,6] <- apply(tax.tab,1,ModifyTax,ind=6)
# prepare the genus level data file
genus_level <-tax_glom(ps, taxrank="Genus",is.na("Genus"))
#print genus level data file info
genus_level
#transform
genus_level_transformed <- transform_sample_counts(genus_level, function(x) {x/sum(x)}*100)
#melting the transforming genus data
genus_level_transformed_psmelt <- psmelt(genus_level_transformed)
#converting the genus information as character
genus_level_transformed_psmelt$Genus <- as.character(genus_level_transformed_psmelt$Genus)
#merge the genus with abundance less than 1
genus_level_transformed_psmelt$Genus[genus_level_transformed_psmelt$Abundance < 0.5] <- "x-Minor genus(<0.5)"

#count the number of phylum which will be in plot
Total_Genus_numbers_for_plot <- length(unique(genus_level_transformed_psmelt$Genus))
Total_Genus_numbers_for_plot

#Plot the bar-plot at genus level
genus_level_barplot <- ggplot(data=genus_level_transformed_psmelt, 
                              aes(x=Sample, y=Abundance, fill=Genus))+ 
  
  geom_bar(aes(color=Genus, fill=Genus), linetype="blank", stat="identity",position="stack")+
  
  
  
  scale_fill_manual(values = distinctColorPalette(length(unique(genus_level_transformed_psmelt$Genus))))+
  
  theme(legend.position = "bottom")+
  guides(fill=guide_legend(title = "Genus", title.position = "top", title.theme = element_text(face = "bold")))+
  
  theme(axis.text.x = element_text(colour = "black", angle = 45, hjust = 1, vjust = 1, face = "bold"))+
  theme(axis.text.y = element_text(colour = "black", hjust = 1, vjust = 1, face = "bold"))+
  
  theme(axis.title.x = element_text(colour = "black", face = "bold", size = 10))+
  theme(axis.title.y = element_text(colour = "black", face = "bold", size = 10))+
  
  theme(legend.key.height = unit(0.3,"cm"), legend.key.width = unit(0.3,"cm"))+
  theme(strip.text.x = element_text(size = 10, colour = "black",face = "bold"))+
  theme(strip.text.x = element_text(margin = margin(0.025,0,0.025,0, "cm")))+
  
  theme(axis.line.y.left = element_line(colour = "black"))+
  theme(axis.line.x.bottom = element_line(colour = "black"))+
  theme(axis.line.x.top = element_line(colour = "black"))+
  
  ylab("Relative Abundance (%)")


genus_level_barplot

#saving plot in pdf
pdf("genus_level_Barplot.pdf", width = 28, height = 18, paper = "a4r")
plot(genus_level_barplot)
dev.off()

#saving plot as html widget
#barplot_genus<-ggplotly(genus_level_barplot)
#htmlwidgets::saveWidget(as_widget(barplot_genus), "Barplot_genus.html")
  
###########

#heatmapping for abundance more than 0.5%
genus_level_transformed_forheatmap <- transform_sample_counts(genus_level, function(x) x / sum(x)*100 )

genus_level_transformed_forheatmap_morethan0.5 <- filter_taxa(genus_level_transformed_forheatmap,function(x) sum(x) > 0.5, TRUE)

Heatmap_Genus <-plot_heatmap(genus_level_transformed_forheatmap_morethan0.5, 
                             
                             taxa.label = "Genus",
                             low="gainsboro", high="dim gray", na.value="white",
                             title="Genus level heatmap (> 0.5 % abundance)")+ 
  
  theme(strip.text.x = element_text(size = 10, colour = "black",face = "bold"))+
  theme(strip.text.x = element_text(margin = margin(0.025,0,0.025,0, "cm")))+
  
  theme(legend.position = "right")+
  theme(legend.title = element_text(face = "bold", size = 10))+
  theme(legend.text = element_blank())+
  
  theme(axis.text.x = element_text(colour = "black", angle = 45, hjust = 1, vjust = 1, face = "bold", size = 10))+
  theme(axis.text.y = element_text(colour = "black", angle = 0, hjust = 1, size = 7, face = "bold"))+
  
  theme(axis.line.y.left = element_line(colour = "black"))+
  theme(axis.line.x.bottom = element_line(colour = "black"))+
  theme(axis.line.x.top = element_line(colour = "black"))+
  
  theme(axis.title.x = element_text(colour = "black", face = "bold", size = 8))+
  theme(axis.title.y = element_text(colour = "black", face = "bold", size = 12))

Heatmap_Genus

#saving plot in pdf
pdf("Heatmap_Genus.pdf", width = 28, height = 18, paper = "a4r")
plot(Heatmap_Genus)
dev.off()

#saving plot as html widget
#Genus_Heatmap<-ggplotly(Heatmap_Genus)
#htmlwidgets::saveWidget(as_widget(Genus_Heatmap), "Genus_Heatmap.html")

####################################################################################################

######################
#Species level
#   replace the NA taxonomy with the highest known taxonomy
tax_table(ps)[,7] <- apply(tax.tab,1,ModifyTax,ind=7)
# prepare the Species level data file
Species_level <-tax_glom(ps, taxrank="Species",is.na("Species"))
#print Species level data file info
Species_level
#transform
Species_level_transformed <- transform_sample_counts(Species_level, function(x) {x/sum(x)}*100)
#melting the transforming Species data
Species_level_transformed_psmelt <- psmelt(Species_level_transformed)
#converting the Species information as character
Species_level_transformed_psmelt$Species <- as.character(Species_level_transformed_psmelt$Species)
#merge the Species with abundance less than 1
Species_level_transformed_psmelt$Species[Species_level_transformed_psmelt$Abundance < 0.5] <- "x-Minor Species(<0.5)"

#count the number of phylum which will be in plot
Total_Species_numbers_for_plot <- length(unique(Species_level_transformed_psmelt$Species))
Total_Species_numbers_for_plot

#Plot the bar-plot at Species level
Species_level_barplot <- ggplot(data=Species_level_transformed_psmelt, 
                                aes(x=Sample, y=Abundance, fill=Species))+ 
  geom_bar(aes(color=Species, fill=Species), linetype="blank", stat="identity",position="stack")+
  
  scale_fill_manual(values = distinctColorPalette(length(unique(Species_level_transformed_psmelt$Species))))+
  
  theme(legend.position = "bottom")+
  guides(fill=guide_legend(title = "Species", title.position = "top", title.theme = element_text(face = "bold")))+
  
  theme(axis.text.x = element_text(colour = "black", angle = 45, hjust = 1, vjust = 1, face = "bold"))+
  theme(axis.text.y = element_text(colour = "black", hjust = 1, vjust = 1, face = "bold"))+
  
  theme(axis.title.x = element_text(colour = "black", face = "bold", size = 10))+
  theme(axis.title.y = element_text(colour = "black", face = "bold", size = 10))+
  
  theme(legend.key.height = unit(0.3,"cm"), legend.key.width = unit(0.3,"cm"))+
  theme(strip.text.x = element_text(size = 10, colour = "black",face = "bold"))+
  theme(strip.text.x = element_text(margin = margin(0.025,0,0.025,0, "cm")))+
  
  theme(axis.line.y.left = element_line(colour = "black"))+
  theme(axis.line.x.bottom = element_line(colour = "black"))+
  theme(axis.line.x.top = element_line(colour = "black"))+
  
  ylab("Relative Abundance (%)")


Species_level_barplot

#saving plot in pdf
pdf("Species_level_Barplot.pdf", width = 28, height = 18, paper = "a4r")
plot(Species_level_barplot)
dev.off()

#saving plot as html widget
#barplot_Species<-ggplotly(Species_level_barplot)
#htmlwidgets::saveWidget(as_widget(barplot_Species), "Barplot_Species.html")

########

#heatmapping for abundance more than 0.5%
Species_level_transformed_forheatmap <- transform_sample_counts(Species_level, function(x) x / sum(x)*100 )

Species_level_transformed_forheatmap_morethan0.5 <- filter_taxa(Species_level_transformed_forheatmap,function(x) sum(x) > 0.5, TRUE)

Heatmap_Species <-plot_heatmap(Species_level_transformed_forheatmap_morethan0.5, 
                               
                               taxa.label = "Species",
                               low="gainsboro", high="dimgrey", na.value="white",
                               title="Species level heatmap (> 0.5 % abundance)")+ 
  theme(strip.text.x = element_text(size = 10, colour = "black",face = "bold"))+
  theme(strip.text.x = element_text(margin = margin(0.025,0,0.025,0, "cm")))+
  
  theme(legend.position = "right")+
  theme(legend.title = element_text(face = "bold", size = 10))+
  theme(legend.text = element_blank())+
  
  theme(axis.text.x = element_text(colour = "black", angle = 45, hjust = 1, vjust = 1, face = "bold", size = 10))+
  theme(axis.text.y = element_text(colour = "black", angle = 0, hjust = 1, size = 7, face = "bold"))+
  
  theme(axis.line.y.left = element_line(colour = "black"))+
  theme(axis.line.x.bottom = element_line(colour = "black"))+
  theme(axis.line.x.top = element_line(colour = "black"))+
  
  theme(axis.title.x = element_text(colour = "black", face = "bold", size = 8))+
  theme(axis.title.y = element_text(colour = "black", face = "bold", size = 12))

Heatmap_Species

#saving plot in pdf
pdf("Heatmap_Species.pdf", width = 28, height = 18, paper = "a4r")
plot(Heatmap_Species)
dev.off()

#saving plot as html widget
#Species_Heatmap<-ggplotly(Heatmap_Species)
#htmlwidgets::saveWidget(as_widget(Species_Heatmap), "Species_Heatmap.html")
######################


