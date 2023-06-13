library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(aws.s3)


url <- "https://www.data.gouv.fr/fr/datasets/r/e215cdb4-4995-4420-9650-8490a79f71df"
download.file(url, "dataset_emplois.csv")

df <- read_delim("dataset_emplois.csv", delim =";")

df_num <- df %>% filter(str_detect(Métier , "Data engineer|Data Scientist|Analyste de données|Administratrice de bases de données|Analyste des données" )) %>%
  mutate(`Organisme de rattachement` = ifelse(str_detect(`Organisme de rattachement`, "Ministère des Armées"), "Ministère des Armées", `Organisme de rattachement` ))

# 1er graphique 
graph_1 <- df_num %>%  replace_na(list(`Nature de contrat` = "Non renseigné")) %>%
  ggplot(aes(x = reorder(`Nature de contrat`, -table(`Nature de contrat`)[`Nature de contrat`]), fill = `Nature de contrat`)) +
  geom_bar(width = 0.3) + labs(x = "Nature de contrat", y = "Nombre d'offres proposées") + 
  theme(axis.text.x=element_text(angle=50, hjust=1), plot.title = element_text(hjust = 0.5)) +
  ggtitle("Répartition des offres publiées par nature de contrat") 

ggsave("graph1.png")

put_object(file = "graph1.png", object = "graph1.png", bucket = "sgruarin", region = "")

# 2ème graphique 
graph_2 <- df_num %>% ggplot(aes(x = reorder(Versant, -table(Versant)[Versant]), fill = Versant)) +
  geom_bar(width = 0.3) +
  labs(x = "Nature de la fonction publique", y = "Nombre d'offres proposées") + 
  theme(axis.text.x=element_text(angle=50, hjust=1), plot.title = element_text(hjust = 0.5)) +
  ggtitle("Répartition des offres publiées par nature de la fonction publique") 

ggsave("graph2.png")

put_object(file = "graph2.png", object = "graph2.png", bucket = "sgruarin", region = "")

# 3ème graphique
nb_orga <- df_num %>%  group_by(`Organisme de rattachement`) %>% tally(sort = TRUE) %>% slice(1:5)


graph_3 <- ggplot(nb_orga, aes(x="", y=n, fill=`Organisme de rattachement`)) +
  geom_bar(stat="identity", width=1) +
  coord_polar("y", start=0) +
  geom_text(aes(label = paste0(n)), position = position_stack(vjust=0.5)) + theme_void() +
  ggtitle("Représentation des cinq organisme les plus demandeurs")


ggsave("graph3.png")

put_object(file = "graph3.png", object = "graph3.png", bucket = "sgruarin", region = "")


