library(shinydashboard)
library(plotly)
library(magick)

header <- dashboardHeader(title = "IMDBStat")


sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("HomePage", tabName = "hp", icon = icon("home", lib = "glyphicon")),
    menuItem("IMDB Best Rated Movies/Shows", icon = icon("stats", lib = "glyphicon"), tabName = "vis1"),
    menuItem("IMDB Datatable", icon = icon("stats", lib = "glyphicon"), tabName = "vis2"),
    menuItem("Series Pie Charts", icon = icon("stats", lib = "glyphicon"), tabName = "vis3")
    
    
  )
)
body <- dashboardBody(  # Boxes need to be put in a row (or column)
  fluidRow(
    
    tabItems(
      tabItem(tabName = "hp",
              h2(align="center","IMDBStat - Data Visualization Assignment 4" ),
              box(width = "12",height="320",align="center",h4("IMDBStat is a dashboard that uses a IMDB dataset taken from kaggle, which will be available on the gitup, for the purpose of facilitating the analysis of the movies success or unsuccess and accessing some statistics in an easy way. Its was develloped as the assignment 4 of Data Visualization, it was made individually, and it would be great to have that in consideration while evaluating it."))
      ),
      tabItem(
        tabName = "vis1",
        h2(align="center","IMDB Best Rated Movies/Shows"),
        box(selectInput("genre", h3("Select genre:"), choices = list("Action" = "action","Animation"="animation",
                                                                     "Comedy"="comedy","Crime"="crime", "Drama" = "drama",
                                                                     "Documentation" = "documentation","European"="european",
                                                                     "Family"="family","Fantasy"="fantasy",
                                                                     "Horror"="horror","Music"="music","Romance"="romance",
                                                                     "Scifi"="scifi","Sport"="sport","Thriller"="thriller",
                                                                     "War"="war","Western"="western" ), selected = "action"),width = 4,height = 220),
        
      
      
        box(
          uiOutput("text"),
          valueBoxOutput("votes",width = 6),
          valueBoxOutput("score",width = 6),
          width = 8,
          height = 220
        ),
        box(plotOutput("plot1",height = 500,click = "plot1_click"),width = 12,height = 520)
    ),
    tabItem(
      tabName = "vis2",
      box(h2(align="center","IMDB Datatable",width=12),width = 6,height = 200,status = "danger", solidHeader = FALSE),
      box(
        h3(align="center","Description"),
        textOutput("description"),width = 6,height = 200,status = "danger", solidHeader = TRUE),
      basicPage(
        DT::dataTableOutput("mytable")
      )
      
    ),
    tabItem(
      tabName="vis3",
      box(h2(align="center","Shows Pie Chart",width=12),width = 12,height = 100,status = "danger", solidHeader = FALSE),
      box(plotlyOutput("plot3",height =500 ),width = 6,height = 520, align = "center"),
      box(plotOutput("Pieclick",width = 500,height=500),width = 6,height = 520,align="center" )
    )
    
    )
    
    
  ))


dashboardPage(
  skin="red",
  header,
  sidebar,
  body
  
)
