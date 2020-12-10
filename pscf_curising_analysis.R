library(RColorBrewer)
library(leaflet)
library(raster)
library(reshape2)


# creating a dummy data
lon <- rnorm(10000, mean=116.3, sd=0.5) 
lat <- rnorm(10000, mean=39.9, sd=0.5) 
pollutantA <- rnorm(10000, mean=1000, sd=200) 

dummpydata <- data.frame(lon,lat,pollutantA)



PSCF_INteractive_Visualize <- function(inputdata,gridsizevalue,quantile_setting,name_of_variable){
  
  #defining grid size
  gridsize <- gridsizevalue #written in degree
  
  
  #declaring boundary of fishnet 
  
  upleftLon <- min(inputdata$lon) - 0.05 
  upleftlat <- max(inputdata$lat) + 0.1
  downrightlon <- max(inputdata$lon) + 0.15
  downrightlat <- min(inputdata$lat) - 0.1
  
  #creating fishnet
  
  lonseq <- seq(upleftLon, downrightlon, gridsize) 
  latseq <- seq(downrightlat, upleftlat, gridsize)
  
  
  
  
  
  Fishnet_For_PSCF <- as.data.frame(expand.grid(lonseq,latseq))
  
  colnames(Fishnet_For_PSCF) <- c("lon","lat")
  
  Fishnet_For_PSCF$minlon <- Fishnet_For_PSCF$lon-(gridsize/2)
  Fishnet_For_PSCF$minlat <- Fishnet_For_PSCF$lat-(gridsize/2)
  Fishnet_For_PSCF$maxlon <- Fishnet_For_PSCF$lon+(gridsize/2)
  Fishnet_For_PSCF$maxlat <- Fishnet_For_PSCF$lat+(gridsize/2)
  
  
  
  
  Fishnet_For_PSCF$pointsize <- rep(0,length(Fishnet_For_PSCF[,1]),1)
  Fishnet_For_PSCF$var_quantile_point <- rep(0,length(Fishnet_For_PSCF[,1]),1)
  Fishnet_For_PSCF$weighting <- rep(0,length(Fishnet_For_PSCF[,1]),1)
  
  
  #getting the quantile
  quan <- quantile((inputdata[,colnames(inputdata) == name_of_variable]),quantile_setting,na.rm = T)
  
  for ( i in seq(1,length(Fishnet_For_PSCF[,1]),1) ){
    
    subdata <- inputdata[ (inputdata$lon < Fishnet_For_PSCF$maxlon[i]) & 
                            (inputdata$lon > Fishnet_For_PSCF$minlon[i]) &
                            (inputdata$lat > Fishnet_For_PSCF$minlat[i]) &
                            (inputdata$lat < Fishnet_For_PSCF$maxlat[i]), ]
    
    pointnumber <- length(subdata[,1])
    
    Fishnet_For_PSCF$pointsize[i] <- pointnumber
    
    subdata_quantile <- subdata[subdata[,colnames(subdata) == name_of_variable] > quan,]
    var_point_number <- length(subdata_quantile[,1])
    
    Fishnet_For_PSCF$var_quantile_point[i] <- var_point_number
    
    
  }
  
  avg_pointsize <- mean(Fishnet_For_PSCF$pointsize,na.rm = T)
  
  # define the weighting
  
  for ( i in seq(1,length(Fishnet_For_PSCF[,1]),1) ){
    if( Fishnet_For_PSCF$pointsize[i]  > (2 * avg_pointsize)  ){
      Fishnet_For_PSCF$weighting[i] <- 1
    }else if( ((Fishnet_For_PSCF$pointsize[i] > avg_pointsize) & (Fishnet_For_PSCF$pointsize[i] < (2*avg_pointsize))) | (Fishnet_For_PSCF$pointsize[i] == (2*avg_pointsize)) ){
      Fishnet_For_PSCF$weighting[i] <- 0.75
      
    }else if( ((Fishnet_For_PSCF$pointsize[i] > (0.5 *avg_pointsize)) & (Fishnet_For_PSCF$pointsize[i] < (avg_pointsize))) | (Fishnet_For_PSCF$pointsize[i] == (avg_pointsize)) ){
      Fishnet_For_PSCF$weighting[i] <- 0.5
    }else if( ((Fishnet_For_PSCF$pointsize[i] > 0) & (Fishnet_For_PSCF$pointsize[i] < (0.5 * avg_pointsize))) | (Fishnet_For_PSCF$pointsize[i] == (0.5 * avg_pointsize)) ){
      Fishnet_For_PSCF$weighting[i] <- 0.15
    }
    
  }
  
  Fishnet_For_PSCF$PSCF <- (Fishnet_For_PSCF$var_quantile_point / Fishnet_For_PSCF$pointsize) * Fishnet_For_PSCF$weighting
  
  Fishnet_For_PSCF$PSCF[is.infinite(Fishnet_For_PSCF$PSCF)] <- NA # if pointsize is zero, PSCF will be infinite

  
  
  rastertest <- rasterFromXYZ(Fishnet_For_PSCF[,c("lon","lat","PSCF")], 
                              crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs" # define the projection
  )
  
  pal <- colorNumeric(colorRamps::matlab.like(8),Fishnet_For_PSCF$PSCF,na.color ="transparent" )
  
  # visualizing using leaflet
  
  m <- leaflet(rastertest) %>%
    addTiles(
      'http://webrd02.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}',
      tileOptions(tileSize=256, minZoom=9, maxZoom=17),
      attribution = '&copy; <a href="http://ditu.amap.com/">¸ßµÂµØÍ¼</a>'
    ) %>%
    addRasterImage(rastertest, colors = pal, opacity = 0.5) %>%
    setView(median(Fishnet_For_PSCF$lon),median(Fishnet_For_PSCF$lat), zoom = 10) %>%
   
    addLegend("topright", pal = pal, values = Fishnet_For_PSCF$PSCF,
              title = paste(name_of_variable," PSCF",sep = ""),
              opacity = 1
    )
  
  m
  
}

PSCF_INteractive_Visualize(dummpydata, #input data
                           0.25, # grid size
                           0.8, # quantile
                           "pollutantA" # variable name
                           )
