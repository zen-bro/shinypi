library(shiny)
library(ggplot2)

shinyUI(pageWithSidebar(
    
    headerPanel(HTML("Shiny &pi; Calculator")),
    
    sidebarPanel(        
        sliderInput('numDarts', 'Number of Darts', min=100, max=10000,
                    value=500, step=10, round=0),
        hr(),
        p(HTML("This is a Monte Carlo Simulation game to approximate the value of &pi;. All you have to do to play is throw darts!")),
        p(HTML(paste("The circular dart board on the right has a radius of 1 and it is mounted on a square of side 2.",
          "Move the slider to choose the number of darts to throw at the board."))),
        p(HTML(paste("The ratio of the darts landing on the dart board will be in the ratio of its area compared to the total area,",
          "which is &pi;/4. That's the fact we use to calculate &pi;!"))),
        p(HTML("Throwing more darts give a more accurate the value of &pi;."))
    ),
    mainPanel(
        plotOutput('dartBoard', width=600, height=600)
    )
))
