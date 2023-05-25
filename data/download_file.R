## Code pour télécharger le ouvrir le jeu de données
library(readr)

url <- "https://www.data.gouv.fr/fr/datasets/r/e215cdb4-4995-4420-9650-8490a79f71df"

download.file(url, "direct_dl/dataset_emplois.csv")



df <- read_delim("direct_dl/dataset_emplois.csv", delim = ";")
