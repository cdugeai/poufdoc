// Add an item to the Add-on menu, under a sub-menu whose name is set automatically.
function onOpen(e) {
  let menuPoufdoc = DocumentApp.getUi().createMenu("🎩 Poufdoc").addItem("Configuration", "sayHello");

  let menuFiles2 = DocumentApp.getUi().createMenu("🪄 Ajout de figures");
  let menu_covid = DocumentApp.getUi().createMenu("📈 Données du COVID-19");
  menu_covid.addItem("Cas de COVID-19 dans le monde", "addFig1")
  menu_covid.addItem("Cas de COVID-19 en France", "addFig2")
  menuFiles2.addSubMenu(menu_covid)

  let menu_emploi = DocumentApp.getUi().createMenu("🗃️ Métiers du numérique");
  menu_emploi.addItem("Offres par Type de contrat", "addFig3")
  menu_emploi.addItem("Répartition des offres par métier", "addFig4")
  menu_emploi.addItem("Répartition des offres par nature de l'emploi", "addFig5")
  menu_emploi.addItem("Répartition des offres par organisme", "addFig6")
  menu_emploi.addItem("Répartition des offres par versant de la fonction publique", "addFig7")
  menu_emploi.addItem("Répartition géographique des offres (carte)", "addFig8")
  menuFiles2.addSubMenu(menu_emploi)

  menuPoufdoc.addSubMenu(menuFiles2);
  menuPoufdoc.addToUi();
  
}

function sayHello() {
  console.log('hello')
}

function ask(){

  let fileconf = getFileConfig();
  var ui = DocumentApp.getUi();

  let text = fileconf.files.map(ff => ff.figures).flat().map((f,i,_) => (i+1)+" - "+f.name).join('\n') + "\n\n"

  var response = ui.prompt('Choix de la figure', text, ui.ButtonSet.OK).getResponseText();
  let allFiles = fileconf.files.map(ff => ff.figures).flat()
  Logger.log(fileconf.files.map(ff => ff.figures))
  Logger.log(allFiles)
  Logger.log(response)
  addImage(allFiles[Number(response)-1].url)
  
}

function getConfig() {
  return {
    files_addr: "https://raw.githubusercontent.com/cdugeai/poufdoc/main/plugin/config/list-files.yml"
  }
}

function showSidebar(){
  // Display a sidebar with custom HtmlService content.
  var htmlOutput = HtmlService
    .createHtmlOutputFromFile('index')
    .setTitle('Poufdoc');
  DocumentApp.getUi().showSidebar(htmlOutput);
}

function getFileConfig() {
  return mockFileConfig();
}

function test() {
  addImage();
  
}

let addFig1 = async () => {await addImage("https://raw.githubusercontent.com/CovidTrackerFr/covidtracker-data/master/images/charts/cases.jpeg")}
let addFig2 = async () => {await addImage("https://raw.githubusercontent.com/CovidTrackerFr/covidtracker-data/master/images/charts/france/dashboard_jour.jpeg")}
let addFig3 = async () => {await addImage("https://raw.githubusercontent.com/cdugeai/poufdoc/main/data/img/Offres%20par%20Type%20de%20contrat.png")}
let addFig4 = async () => {await addImage("https://github.com/cdugeai/poufdoc/blob/main/data/img/Re%CC%81partition%20des%20offres%20par%20me%CC%81tier.png?raw=true")}
let addFig5 = async () => {await addImage("https://github.com/cdugeai/poufdoc/blob/main/data/img/Re%CC%81partition%20des%20offres%20par%20nature%20de%20l'emploi.png?raw=true")}
let addFig6 = async () => {await addImage("https://github.com/cdugeai/poufdoc/blob/main/data/img/Re%CC%81partition%20des%20offres%20par%20organisme.png?raw=true")}
let addFig7 = async () => {await addImage("https://github.com/cdugeai/poufdoc/blob/main/data/img/Re%CC%81partition%20des%20offres%20par%20versant%20de%20la%20fonction%20publique.png?raw=true")}
let addFig8 = async () => {await addImage("https://github.com/cdugeai/poufdoc/blob/main/data/img/R%C3%A9partition%20g%C3%A9ographique%20des%20offres%20(carte).png?raw=true")}

async function addImage(url) {
  //let url="https://raw.githubusercontent.com/CovidTrackerFr/covidtracker-data/master/images/charts/france/dashboard_jour.jpeg"
   const tempImage = await UrlFetchApp.fetch(url)
   const image = tempImage.getBlob();
   const docBody = DocumentApp.getActiveDocument().getBody()
   const inlineImage = docBody.appendImage(image);
   inlineImage.setHeight(300).setWidth(400);    //.setLinkUrl(url)
}

function mockFileConfig() {
  return {
  "files": [
    {
      "namespace": {
        "name": "Données du COVID-19",
        "shortName": "covid",
        "description": ""
      },
      "figures": [
        {
          "name": "Cas de COVID-19 dans le monde",
          "shortName": "covid-world",
          "url": "https://raw.githubusercontent.com/CovidTrackerFr/covidtracker-data/master/images/charts/cases.jpeg"
        },
        {
          "name": "Cas de COVID-19 en France",
          "shortName": "covid-france",
          "url": "https://raw.githubusercontent.com/CovidTrackerFr/covidtracker-data/master/images/charts/france/dashboard_jour.jpeg"
        }
      ]
    },
    {
      "namespace": {
        "name": "Objets trouvés par la SNCF en gare",
        "shortName": "sncf-objets",
        "description": ""
      },
      "figures": [
        {
          "name": "Objets trouvés en Gare de Paris Saint-Lazare",
          "shortName": "sncf-objets-saint-lazare",
          "url": "todo"
        },
        {
          "name": "Objets trouvés en Gare de Paris Montparnasse",
          "shortName": "sncf-objets-montparnasse",
          "url": "todo"
        }
      ]
    }
  ]
}
}
