library(readr)
library(dplyr)
library(stringr)
library(ggplot2)

library(aws.s3)


url <- "https://www.data.gouv.fr/fr/datasets/r/e215cdb4-4995-4420-9650-8490a79f71df"
download.file(url, "dataset_emplois.csv")

df <- read_delim("dataset_emplois.csv", delim =";")

df_num <- df %>% filter(str_detect(Métier , "Data engineer|Data Scientist|Analyste de données|Administratrice de bases de données|Analyste des données" )) %>%
  mutate(`Organisme de rattachement` = ifelse(str_detect(`Organisme de rattachement`, "Ministère des Armées"), "Ministère des Armées", `Organisme de rattachement` ))

nat_contrat <- group_by(df_num, `Nature de contrat`) %>% 
  reframe(., count=n()) %>% 
  arrange(., desc(count)) 

graph_1 <- ggplot(data=nat_contrat, aes(x=reorder(`Nature de contrat`,count), y=count)) +
  geom_bar(aes(y=count, fill=`Nature de contrat`), stat="identity", width=0.5)+
  labs(x= 'Nature de contrat', y = "Nombre d\'offres proposées")

ggsave("myplot.png")

put_object(file = "myplot.png", object = "myplot.png", bucket = "projet-poufdoc", region = "")
