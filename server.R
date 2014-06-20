library(shiny)
library(ggplot2)
library(grid)

totalNumDarts <- 1
totalHits <- 1

throwDarts <- function(numDarts) {
    xvals <- runif(numDarts, min=-1, max=1)
    yvals <- runif(numDarts, min=-1, max=1)
    data.frame(x=xvals, y=yvals, typ=rep(1, numDarts))
}

calcPi <- function(throws) {
    numDarts <- nrow(throws)
    
    xvals <- throws$x
    yvals <- throws$y
    
    distvals <- sqrt(xvals*xvals + yvals*yvals)
    nhits <- sum(distvals <= 1)
    
    totalNumDarts <<- totalNumDarts + numDarts
    totalHits <<- totalHits + nhits
    
    return (4*nhits/numDarts)
}

circleData <- function(center=c(0,0), diameter=2, npoints=100){
    r = diameter / 2
    tt <- seq(0, 2*pi, length.out=npoints)
    xx <- center[1] + r * cos(tt)
    yy <- center[2] + r * sin(tt)
    data.frame(x=xx, y=yy)
}

plotBoard <- function(throws) {
    numDarts <- nrow(throws)
    
    xvals <- throws$x
    yvals <- throws$y
    
    board <- circleData()
    border <- data.frame(x=c(-1,1,1,-1,-1), y=c(-1,-1,1,1,-1))
    
    ggplot(board, aes(x,y,size=2)) + geom_path() + 
        geom_path(data=border, aes(x,y)) + 
        geom_point(data=throws, aes(x,y,color='red',alpha=0.25)) + 
        xlim(-1, 1) + ylim(-1, 1) + 
        theme_bw() + 
        theme(legend.position="none", 
              panel.grid=element_blank(),
              panel.border=element_blank()) + 
        labs(x=NULL, y=NULL) + 
        scale_x_continuous(breaks=NULL) + scale_y_continuous(breaks=NULL) + 
        annotate("text", x=0, y=-0.2, size=8, fontface="bold", label="This Round:") +
        annotate("text", x=0, y=-0.3, size=8, fontface="bold", label=paste(calcPi(throws))) +
        annotate("text", x=0, y=0.3, size=8, fontface="bold", label=paste("Over", totalNumDarts, "throws:")) +
        annotate("text", x=0, y=0.2, size=8, fontface="bold", label=paste(4*totalHits/totalNumDarts))
}

shinyServer(
    function(input, output) {
        output$dartBoard <- renderPlot({print(plotBoard(throwDarts(input$numDarts)))})
    }
)
