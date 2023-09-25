// Add an item to the Add-on menu, under a sub-menu whose name is set automatically.
function onOpen(e) {
  let menuPoufdoc = DocumentApp.getUi().createMenu("Poufdoc").addItem("Configuration", "sayHello").addItem("Choix de la figure", "ask").addItem("Sidebar", "showSidebar");;

  let menuFiles = DocumentApp.getUi().createMenu("Figures");
  

  // For each namespace
  getFileConfig().files.forEach(item_ => {

    // Create menu for this namespace
    let menu_ns = DocumentApp.getUi().createMenu(item_.namespace.name);
    item_.figures.forEach(figure => {
      // Add figures to this new menu
      menu_ns.addItem(figure.name, "addImage('"+figure.url+"')")
    })
    // Add this menu as submenu of Poufdoc menu
    menuFiles.addSubMenu(menu_ns)
  })
  
  let menuDialog = DocumentApp.getUi().createMenu("Dialog");


  menuPoufdoc.addSubMenu(menuFiles);
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


async function addImage(url) {
  //let url="https://raw.githubusercontent.com/CovidTrackerFr/covidtracker-data/master/images/charts/france/dashboard_jour.jpeg"
   const tempImage = await UrlFetchApp.fetch(url)
   const image = tempImage.getBlob();
   const docBody = DocumentApp.getActiveDocument().getBody()
   const inlineImage = docBody.appendImage(image);
   inlineImage.setHeight(300).setWidth(200);    //.setLinkUrl(url)
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
