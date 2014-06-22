library(shiny)
library(ggplot2)
library(grid)

# cumulative values across all throws
totalThrows <- 1
totalHits <- 1
piVals <- c()

# calculate points to use for drawing the dart board outline
circleData <- function(center=c(0,0), diameter=2, npoints=100){
    r = diameter / 2
    tt <- seq(0, 2*pi, length.out=npoints)
    xx <- center[1] + r * cos(tt)
    yy <- center[2] + r * sin(tt)
    data.frame(x=xx, y=yy)
}

# prepare and store the data for plotting the dart board outline
board <- circleData()
border <- data.frame(x=c(-1,1,1,-1,-1), y=c(-1,-1,1,1,-1))

# throw numDarts number of darts and get the coordinates where they hit
throwDarts <- function(numDarts) {
    xvals <- runif(numDarts, min=-1, max=1)
    yvals <- runif(numDarts, min=-1, max=1)
    data.frame(x=xvals, y=yvals, typ=rep(1, numDarts))
}

# count the number of hits (point lies within the unit circle)
countHits <- function(throws) {
    xvals <- throws$x
    yvals <- throws$y
    
    distvals <- sqrt(xvals*xvals + yvals*yvals)
    sum(distvals <= 1)
}

# calculate pi based on the fact that number of hits would be 
# propertional to the area of the circle.
calcPi <- function(hits, throws) {
    return (4*hits/throws)
}

# plot the dart board and show the points where the darts hit
plotBoard <- function(throws) {
    ggplot(data=board, aes(x,y)) + geom_path() + 
        geom_path(data=border, aes(x,y)) + 
        geom_point(data=throws, aes(x,y,color='red',alpha=0.25)) + 
        xlim(-1, 1) + ylim(-1, 1) + 
        theme_bw() + 
        theme(legend.position="none", 
              panel.grid=element_blank(),
              panel.border=element_blank()) + 
        labs(x=NULL, y=NULL) + 
        scale_x_continuous(breaks=NULL) + scale_y_continuous(breaks=NULL) + 
        annotate("text", x=0, y=0, size=5, fontface="bold", label="Dart Board")
}

# calculate the value of pi based on all the throws till now
calcLargePi <- function(nHits, nThrows) {
    totalThrows <<- totalThrows + nThrows
    totalHits <<- totalHits + nHits
    calcPi(totalHits, totalThrows)
}

# plot a trend showing how the calculated value of pi converges to the actual value
plotPiVals <- function(largePi) {
    piVals <<- append(piVals, largePi)
    qplot(seq_along(piVals), piVals) +
        labs(x=NULL, y="calculated pi") + stat_smooth(se=F) + 
        geom_hline(aes(yintercept=pi)) +
        theme_bw()
}

shinyServer(
    function(input, output) {
        nThrows <- reactive({as.numeric(input$numDarts)})
        throws <- reactive({throwDarts(nThrows())})
        nHits <- reactive({countHits(throws())})
        
        pivalSmall <- reactive({calcPi(nHits(), nThrows())})
        pivalLarge <- reactive({calcLargePi(nHits(), nThrows())})
        
        output$dartBoard <- renderPlot({print(plotBoard(throws()))})
        output$piVals <- renderPlot({print(plotPiVals(pivalLarge()))})
        output$piSmall <- renderText({pivalSmall()})
        output$piLarge <- renderText({pivalLarge()})
    }
)
