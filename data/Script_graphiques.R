# Liste des packages nécessaires
packages <- c("sf", "readr", "dplyr","tidyr","stringr","ggplot2")

# Vérifier si les packages sont installés, sinon les installer
for (package in packages) {
  if (!require(package, character.only = TRUE)) {
    install.packages(package, dependencies = TRUE)
    if (!require(package, character.only = TRUE)) {
      stop(paste("Impossible d'installer le package", package))
    }
  }
}

library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(aws.s3)
library(sf)

url <- "https://www.data.gouv.fr/fr/datasets/r/e215cdb4-4995-4420-9650-8490a79f71df"
download.file(url, "dataset_emplois.csv")

df <- read_delim("dataset_emplois.csv", delim =";")

#recup donnÃ©es gÃ©ospatiales dÃ©partements
url2 <- "https://france-geojson.gregoiredavid.fr/repo/regions.geojson"
# url2 <- "https://france-geojson.gregoiredavid.fr/repo/departements.geojson"
download.file(url2, "contour-des-departements.geojson")

df_dep <- st_read("contour-des-departements.geojson")
df_dep <- df_dep %>% filter(code %in% c("11","24","27","28","32","44","52","53","75","76","84","93","94"))

df_num <- df %>% filter(str_detect(Métier , "Data engineer|Data Scientist|Analyste de données|Administratrice de bases de données|Analyste des données" )) %>%
  mutate(`Organisme de rattachement` = ifelse(str_detect(`Organisme de rattachement`, "Ministère des Armées"), "Ministère des Armées", `Organisme de rattachement` ))


# 1er graphique 
graph_1 <- df_num %>% replace_na(list(`Nature de contrat` = "Non renseigné")) %>%
  mutate(Type = case_when(`Nature de contrat` == 'Non renseigné' ~ `Durée du contrat`,
                          `Nature de contrat` != 'Non renseigné' ~ `Nature de contrat`)) %>% 
  mutate(`Type de contrat` = case_when(Type == '3 mois' | Type == '2 mois' | Type == '6 mois' | Type == 'CDD de 6 mois' |
                                         Type == '1 mois' | Type == '4 mois' ~ "CDD de moins de 6 mois",
                                       Type == "12 mois" | Type == "CDD d'1 an" | Type == '10 mois' | Type == '12 moins' |
                                         Type == "7 mois" | Type == "1 an" ~ "CDD de 6 mois à 1 an",
                                       Type == 'CDD de 2 ans' | Type == '19 mois' | Type == '24 mois' | Type == '2 ans' ~ "CDD de 1 à 2 ans",
                                       Type == '36 mois' | Type == '3 ans' | Type == '48 mois' | Type == '45 mois' |
                                         Type == 'CDD de 3 ans' ~ "CDD de plus de 2 ans",
                                       Type == 'CDI' ~ 'CDI') ) %>% 
  replace_na(list(`Type de contrat` = 'Non renseigné')) %>% 
  ggplot(aes(x = reorder(`Type de contrat`, -table(`Type de contrat`)[`Type de contrat`]), fill = `Type de contrat`)) +
  geom_bar(width = 0.3) + labs(x = "Type de contrat", y = "Nombre d'offres proposées", caption = 'Source : data.gouv') + 
  theme_classic() +
  theme(axis.text.x=element_text(angle=50, hjust=1), plot.title = element_text(hjust = 0.5), legend.position = 'none', text = element_text(family = 'Marianne', face = 'bold', size = 12)) +
  scale_fill_manual(values = c("Non renseigné" = '#000091' , "CDD de plus de 2 ans" = '#6a6af4' ,
                                          "CDD de 6 mois à 1 an" = '#cacafb', "CDI" = '#6a6af4', "CDD de 1 à 2 ans" = '#272747',
                                          "CDD de moins de 6 mois" = '#e3e3fd' )) +
  ggtitle("Répartition des offres publiées par type de contrat") 

ggsave("R�partition des offres par type de contrat.png")

put_object(file = "graph1.png", object = "graph1.png", bucket = "sgruarin", region = "")

# 2�me graphique 
graph_2 <- filter(df_num, !is.na(Versant))  %>%
  ggplot(aes(x = reorder(Versant, -table(Versant)[Versant]), fill = Versant)) +
  geom_bar(width = 0.3,color = "#000091" , fill="#cacafb" ) +
  labs(x = "Versant de la fonction publique", y = "Nombre d'offres proposées") +
  theme_classic() +
  theme(legend.position = "none", text=element_text(family="Marianne", face="bold", size=12),axis.text.x=element_text(angle=50, hjust=1), plot.title = element_text(hjust = 0.5))

ggsave("graph2.png")

#put_object(file = "graph2.png", object = "graph2.png", bucket = "sgruarin", region = "")

# 3�me graphique
nb_orga <- df_num %>%  group_by(`Organisme de rattachement`) %>% tally(sort = TRUE) %>% slice(1:5)

graph_3 <- ggplot(nb_orga, aes(x="", y=n, fill=`Organisme de rattachement`)) +
  geom_bar(stat="identity", width=1) +
  scale_fill_manual(values = c("#c9191e", "#fcbfbf", "#f95c5e", "#5e2a2b", "#e1000f")) + 
  coord_polar("y", start=0) +
  geom_text(aes(label = paste0(n)), position = position_stack(vjust=0.5)) + theme_void() + 
  theme(text = element_text(family = 'Marianne', face = 'bold', size = 12)) + 
  ggtitle("Représentation des cinq organismes les plus demandeurs") +
  labs(caption = 'Source : data.gouv')

ggsave("graph3.png")

#put_object(file = "graph3.png", object = "graph3.png", bucket = "sgruarin", region = "")

# 4ème graphique
nature_emploi <- df_num %>%  group_by(`Nature de l'emploi`) %>% tally(sort = TRUE) %>% slice(1:2)


graph_4 <- ggplot(nature_emploi, aes(x="", y=n, fill=`Nature de l'emploi`)) +
  geom_bar(stat="identity", width=1) +
  scale_fill_manual(values = c("#cacafb", "#000091")) + 
  coord_polar("y", start=0) +
  geom_text(aes(label = paste0(n)), position = position_stack(vjust=0.5)) + theme_void() +
  theme(plot.title = element_text(hjust = 0.5),  text = element_text(family = 'Marianne', face = 'bold', size = 12)) + 
  ggtitle("Répartition des offres par nature de l'emploi") + labs(caption = "Source : data.gouv")

ggsave("graph4.png")

#put_object(file = "graph4.png", object = "graph4.png", bucket = "nfour", region = "")

# Graphique 5

# SynthÃ©tise par dÃ©partement le nbre d'offres
df_geo <- df_num %>% dplyr::mutate(`Departement` = str_extract(df_num$`Localisation du poste`, "[[:alpha:]]+")) %>% drop_na(`Departement`) %>% 
  dplyr::group_by(`Departement`) %>% dplyr::summarise(`Nombre d'offres` = n())

# Charge les donnÃ©es gÃ©ographiques des dÃ©partements franÃ§ais
map_fr <- map_data("france") %>% group_by(region) %>% slice(1)


# Fusionne les donnÃ©es géographiques et les donnÃ©es d'offres
map_fr <- merge(map_fr, df_geo, by.x = "region", by.y = "Departement", all.x = TRUE)

# graph
graph5 <- ggplot() + geom_sf(data = df_dep, size = 0.5, color = "black", fill = "white") +
  geom_point(data = map_fr, aes(x=long, y = lat, size = `Nombre d'offres`), color = "blue" ) +
  theme_void() + 
  ggtitle("Répartition géographique du nombre d'offres") +
  theme(plot.title = element_text(hjust = 0.5))

ggsave("graph5.png")

#put_object(file = "graph5.png", object = "graph5.png", bucket = "sgruarin", region = "")

# Graphique 6 

valeur <- nrow(df_num)

graph6 <- ggplot(data.frame(x = 0, y = 0), aes(x, y)) +
  geom_blank() +
  annotate("text", x = 0.5, y = 0.5, label = valeur, size = 15, fontface = "bold", color = "#000091", vjust = 3.5, hjust = 2.5) +
  annotate("text", x = 0.35, y = 0.35, label = "Nombre d'offres publiées cette semaine", size = 6, color = "#7b7b7b", vjust = 3.5, hjust = 0.7) +
  theme_void()

ggsave(graph6.png)

#put_object(file = "graph6.png", object = "graph6.png", bucket = "sgruarin", region = "")


# Graphique 7 

graph_7 <- df_num %>%  replace_na(list(`Métier` = "Non renseigné")) %>%
  ggplot(aes(y = reorder(`Métier`, -table(`Métier`)[`Métier`]), fill = `Métier`)) +
  geom_bar() +
  labs(x = "Métier", y = "Nombre d'offres proposées", caption = 'Source : data.gouv')+
  scale_fill_manual(values = c("#cacafb", "#000091", "#6a6af4", "#f5f5fe", "#e3e3fd", "#313178", "#1b1b35")) +
  ggtitle("Répartition des offres publiées par métier") +
  theme_classic() +
  theme(legend.position = "none", text=element_text(family="Marianne", face="bold", size=12)) 


ggsave("graph7.png")

#put_object(file = "graph7.png", object = "graph7.png", bucket = "nfour", region = "")