#  Task 3 : Server Script of Shiny App 

#install.packages("tm")  # for text mining
#install.packages("SnowballC") # for text stemming
#install.packages("wordcloud") # word-cloud generator 
#install.packages("RColorBrewer") # color palettes

# Load the required libraries
library(shiny)
library(dplyr)
library(stringr)
library("tm")
library("SnowballC")
library("wordcloud")
library("RColorBrewer")
library(ggplot2)


#Define server logic required to filter and display siltered sentences ,draw a Barchart & Wordcloud

shinyServer(function(input,output){
	Dataset<-reactive({
		if(is.null(input$file)) 
		  { return (NULL)}
		else{
			#input$File will be NULL initially,After the user selects 
			#and uploads a file ,it will be a dataframe with 'name',
			#'size','type', and 'datapath' columns.The 'datapath' 
			#column will contain the local file names where the data can be found

			infile<-input$file
			Dataset<-as.data.frame(read.csv(infile$datapath,header=TRUE,sep=","))
		return(Dataset)
		}
	})
	
# List of given keywords 
	keywords<-reactive({
		if(length(strsplit(input$keyword,',')[[1]])==0){return(NULL)}
		else{
			return(strsplit(input$keyword,',')[[1]])
		}
	})
	
	# Filtering the sentences -Extracting the sentences which contain any one of the given keywords
	sentence.data <- reactive({
	  v2 <- unlist(strsplit(keywords(), ","))
	  res1 <- Dataset()$Reviews[Reduce(`|`, lapply(v2, grepl, x = Dataset()$Reviews))]
	  
	})
	
	#Rendering the filtered sentences onto UI 
	output$keywords <- renderTable({ sentence.data() })
	
	#Frequency of the list of keywords
	barplot.data <- reactive({
	  # Load the data as a corpus
	  Reviewdocs <- Corpus(VectorSource(	sentence.data()))
	  # Preprocessing of the input corpus
	  transtoSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
	  Reviewdocs <- tm_map(Reviewdocs, transtoSpace, "/")
	  Reviewdocs <- tm_map(Reviewdocs, transtoSpace, "@")
	  Reviewdocs <- tm_map(Reviewdocs, transtoSpace, "\\|")
	  # Convert the input text(reviews) to lower case
	  Reviewdocs <- tm_map(Reviewdocs, content_transformer(tolower))
	  # Remove numbers from the given input text
	  Reviewdocs <- tm_map(Reviewdocs, removeNumbers)
	  # Remove stopwords(english) from the given text
	  Reviewdocs <- tm_map(Reviewdocs, removeWords, stopwords("english"))
	  # Remove punctuations
	  Reviewdocs <- tm_map(Reviewdocs, removePunctuation)
	  # Stripe or remove extra white spaces
	  Reviewdocs <- tm_map(Reviewdocs, stripWhitespace)
	  #TermDocumentMatrix to find the frequencies of words
	  revdtm <- TermDocumentMatrix(Reviewdocs)
	  revdtm <- revdtm[rownames(revdtm)%in%unlist(strsplit(keywords(), ",")),]
	  revm <- as.matrix(revdtm)
	  revvec <- sort(rowSums(revm),decreasing=TRUE)
	  barplot.data <- data.frame(word = names(revvec),freq=as.integer(revvec))
	  return(barplot.data)
	 
	})
	
 #Rendering frequency data as Barchart
	output$freq_plot = renderPlot({ 
	  if (!is.null(barplot.data())) {
	    barplot( barplot.data()$freq,names.arg= barplot.data()$word,xlab="Keyword",ylab="Frequency",col="blue",    
	          main="WordFrequency chart",border="red", las=2,cex.names=0.75)
	  }
	  else
	    print("No Data")
	    
	})
	
	#Rendering frequency data as wordcloud
	set.seed(120)
	output$word_cloud = renderPlot({ 
	  wordcloud(words = barplot.data()$word, freq = barplot.data()$freq,min.freq=1,
	           max.words=100, random.order=FALSE, rot.per=0.35, 
	            colors=brewer.pal(8, "Dark2"))
	})

	
})


