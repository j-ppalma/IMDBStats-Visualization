
library(ggplot2)
library(viridis)
library(dplyr)
library(stringr)
library(plotly)
library(DT)
library(forcats)
library(RCurl)

function(input, output) {
  #################DATAFRAMA VIS1###################
  
  #df1<-read.csv(text=getURL("https://raw.github.com/j-ppalma/IMDBStats-Visualization/blob/main/Dataset/titles.csv"))
  urlfile<-"https://raw.github.com/j-ppalma/IMDBStats-Visualization/main/Dataset/titles.csv"
  df0<-read.csv(urlfile)
  datafilter<-reactive({
     df1<-df0[str_detect(df0$genres,input$genre),]
     df1 <- df1%>%
       arrange(desc(imdb_score)) %>%
       head(n = 20L)
     })
   global <- reactiveValues(selectedValTable = "Click a Row to View the Movie/Show Description.", 
                            selectedBar = "The Walking Dead")
  
  
   #################Value Box1###################
   
  numVotes<-reactive({
    votes<-df0%>% filter(title==global$selectedBar)%>%select( imdb_votes)
    votes[1,"imdb_votes"]
  })
   output$votes <- renderValueBox({valueBox(numVotes(), "IMDB Votes",color = "red",
                                            icon =icon("thumbs-up", lib = "glyphicon"),width = 12)})
   #################Value Box2###################
   
   numScore<-reactive({
     score<-df0%>% filter(title==global$selectedBar)%>%select(imdb_score)
     score[1,"imdb_score"]
   })
  output$score <- renderValueBox({valueBox(numScore(), "IMDB Value",color = "yellow",
                                             icon =icon("thumbs-up", lib = "glyphicon"),width = 12)})
   
   
   output$text <- renderUI({
     req(global$selectedBar)
     textInput(inputId = "label", label = "IMDB Votes & Values Of The Selected Bar Element:", value = global$selectedBar)
   })
   
   
   #################Visualization 1###################
   
   
  output$plot1<-
    renderPlot({
      asd<-datafilter()
      asd<-asd%>%mutate(title = fct_reorder(title, desc(imdb_score)))
      observeEvent(input$plot1_click, {
        global$selectedBar <- asd$title[round(input$plot1_click$y)]
        })
    ggplot(asd, aes(y=title, x=imdb_score, fill=type,color="", width=.75)) +
      geom_bar(stat="identity")+scale_fill_manual(values = c("#feb24c", "#f03b20"))+
    scale_color_manual(values = "black")+theme_bw()+
      theme(title = element_text(size=10),axis.text.x = element_text(size = 7),
            axis.text.y = element_text(size = 10))+
      ggtitle(paste("The 20",{input$genre},"best rated Movies/Shows"))+ ylab(NULL)+
      xlab(NULL)+guides(color = FALSE)
    
    })
  

  #################Dataframe 2###################
   df2<-df0 %>% select(-id,-description,-imdb_id)
   
  #################Visualization 2################
   observeEvent(input$mytable_rows_selected, {
      desc<-df0%>%filter(grepl(df2[input$mytable_rows_selected,1],title,fixed = TRUE))%>%select(description)
     global$selectedValTable<-substring(desc,1)

   })
   
   output$description = renderPrint({
    global$selectedValTable
   })
   output$mytable = renderDataTable(
     df2,selection="single"
   
   )
   
   #################Dataframe 3###################
   df3<-df0 %>% filter(type=="SHOW")%>% 
     select(title,seasons,tmdb_popularity,imdb_score,tmdb_score,imdb_votes)
   df3<-na.omit(df3) 
   df4<-df3
   df4<-df4%>% select(-title)%>%group_by(seasons)%>%
     summarize(n = n())
   df4$seasons[df4$seasons >= 9] <- "more than 9"  
   df4$seasons<-paste(df4$seasons," seasons")
   output$plot3<-
     renderPlotly({
   plot3 <- plot_ly(df4, labels = ~seasons, values = ~n, type = 'pie',textposition = 'inside',textinfo = 'label+percent',
                    showlegend=FALSE,marker=list(colors = RColorBrewer::brewer.pal(9, "Spectral")))
   plot3 <- plot3 %>% layout(title = 'Amount Of Series By Number Of Seasons',
                             width = 500, height = 500,
                         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))%>%
     event_register("plotly_click")
   
 
   plot3
    })
   
   output$Pieclick <- renderPlot({
     d <- event_data("plotly_click")$pointNumber
     x<-if(is.null(d))10 else as.numeric(d)
     
     if(x==10){
    df5<-df3%>%filter(seasons>=x)
    titl<-"more than 10"
   }else{
     df5<-df3%>%filter(seasons==x+1)
     titl<-x+1
   }
     df5<-df5%>%
       arrange(desc(tmdb_popularity)) %>%
       head(n = 10L)
     
     ggplot(df5, aes(y=title, x=tmdb_popularity, fill=title)) +
       geom_bar(stat="identity")+theme_minimal()+coord_polar()+                                              # Change color brewer palette
       scale_fill_brewer(palette = "Spectral")+ xlab(NULL)+ ylab(NULL)+
       geom_text(aes(x = 0, label = title),position = position_dodge(width=0.9),  size=5) +
       theme(axis.text.y = element_blank(),legend.position = "none",title = element_text(size=13))+ggtitle(paste("The 10 Most Popular Series Of The Slice Selected.(",titl,")"))+
       scale_x_continuous(breaks = seq(0, 1000, by=100), limits=c(0,1000))

     
     
   })
   
   
   

}