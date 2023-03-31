# 03-30

## Liens utiles

Quelques lien vers des outils utiles:

- Explore data.gouv: https://explore.data.gouv.fr/
- SSPCloud: https://datalab.sspcloud.fr



## Données à générer:

Pour le premier cas d'usage, on aimerait étudier les données de [Place de l'emploi public](https://place-emploi-public.gouv.fr/) dont les données sont disponibles sur data.gouv (dataset [les-offres-diffusees-sur-la-place-de-lemploi-public](https://www.data.gouv.fr/fr/datasets/les-offres-diffusees-sur-la-place-de-lemploi-public/), et [lien direct du CSV](https://static.data.gouv.fr/resources/les-offres-diffusees-sur-la-place-de-lemploi-public/20230327-080020/offres-datagouv-20230326.csv)). 

On voudrait générer les figures et des indicateurs suivants dans un premier temps:


1. Indicateurs:
  - Nombre d'offres
  - Nombre d'offres numériques (domaine::numérique)
  - Variation du nombre d'offres (par rapport à une période antérieure)
  
2. Graphiques:
  - carte des offres numériques pour chaque département
  - Répartition des offres par Nature de contrat (CDI, CDD de 2 ans, de 6 mois, d'1 an etc.)
  - Répartition par employeur (regroupement par ministère)

Ce qu'il serait intéressant de faire est de créer des indicateurs qui traduisent **l'évolutivité des données**. Pour cela, on pourrait afficher **l'évolution** des valeurs d'indicateurs **par rapport à une période passée** (semaine/mois précédents).

## Tech

- On arrive à déposer des figures sur le stockage [Minio](https://min.io/) du [SSP Cloud](https://datalab.sspcloud.fr). Par exemple, https://minio.lab.sspcloud.fr/cdugeai/public/dinum.png est bien accessible publiquement
- :warning: Point d'attention sur le dataset de "Place de l'emploi public": l'url du dataset va varier. En effet, lorsqu'un nouveau fichier de mise à jour est ajouté sur datagouv, le nouveau fichier contient la date de dernière mise à jour dans son nom, ce qui fait varier son son URL d'accès. Le fichier précédent est lui supprimé



