# Aim     : Task 3 : User Interface of Shiny App 
# Input   : The Corpus File and List of Keywords
# Output  : Statistical analysis of input keywords and its visualizations

#Importing the required libraries
library("shiny")

#Define UI for application 
shinyUI(fluidPage(
	#Title of the Application
	titlePanel("Task-3: Shiny-App"),
	
	#Sidebar with fileinput and textinput for uploading the input reviews file 
	#textinput for set of input keywords
	sidebarPanel(
		fileInput("file","Upload input data file(csv file with header))"),
		textInput('keyword',label="Enter list of keywords with comma separated to extract")
	),

	#To show overview,plot and wordcloud of frequencies of keywords
	mainPanel(
		tabsetPanel(type="tabs",
			    tabPanel("Overview",
			             h4(p("Data input")),
			             p("This app supports only comma separated values (.csv) data file. CSV data file should have header",align="justify"),
			             p("Please refer to the link below for sample csv file."),
			             a(href="https://github.com/ambt2009/11920048-TABA-Assignment-/blob/master/DataSet/TABA_Task3_Shiny_SampleData.csv","Sample Input Data File"),   
			             br(),
			             h4('Usage of this App'),
			             p('To use this app, click on', 
			                span(strong("Browse button and select the input file (csv file with header)")),
			               'to uppload and enter an array of keywords with comma separated in the text Input')),
			    tabPanel("Keyword Filtered Corpus",h4("Keyword Filtered Table"),tableOutput("keywords")),
			    tabPanel("Frequency Plots",h4("Frequency Ditribution Plots"),plotOutput("freq_plot")),
			    tabPanel("Word cloud",h4("Word cloud"),plotOutput("word_cloud"))
			             
		  )
	)
	)
)



