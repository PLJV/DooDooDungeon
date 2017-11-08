require(rgdal)
require(raster)

# determine which FAA file from index.html is the most recent and download it.
f <- readLines("to_fetch.dat")

toFetch <- unlist(strsplit(f,split="DOF_"))
  toFetch <- toFetch[grepl(toFetch,pattern="zip")]
    toFetch <- unlist(strsplit(toFetch,split="[.]"))
      toFetch <- as.numeric(toFetch[!grepl(toFetch,pattern="zip")])

download.file(f[which(toFetch == max(toFetch))],destfile="faa_obs.zip")

cat(" -- decompressing ...")
unzip("faa_obs.zip")

toDelete <- list.files(pattern="Dat$|dat$")
  toDelete <- toDelete[!grepl(toDelete,pattern="DOF")]
    file.remove(toDelete)

f <- readLines("DOF.DAT",skip=4)

cat(" -- parsing FAA obstructions for windmills: ")
turbines <- data.frame()
for(i in 1:length(f)){
  j <- gsub(unlist((strsplit(f[i],split=" "))),pattern="N|W",replacement="")
  # is this obstruction a windmill?
  if(sum(grepl(j,pattern="MILL"))>0){
    degMinSecN <- vector()
    degMinSecW <- vector()
          year <- vector()
           ors <- j[1]
    # because the exact field is never precisely known, we have to slowly iterate over all
    # fields to find the coordinates of the turbine
    for(k in 2:length(j)){
      if(!is.na(as.numeric(j[k]))){
        if(length(degMinSecN)<3){
          degMinSecN[length(degMinSecN)+1] <- as.numeric(j[k])
        } else if(length(degMinSecW)<3){
          degMinSecW[length(degMinSecW)+1] <- as.numeric(j[k])
        } else if(nchar(j[k])==7){
          year <- as.numeric(substr(j[k],1,4))
        }
      }
    }
    # now convert everything to decimal degrees and merge with our turbines data.frame
    lat <- degMinSecN[1] + degMinSecN[2]/60 + degMinSecN[3]/3600
    lon <- -1*(degMinSecW[1] + degMinSecW[2]/60 + degMinSecW[3]/3600)
    turbines <- rbind(turbines,data.frame(ors=ors,year=year,latitude=lat,longitude=lon))
    cat("+")
  }
}; cat("\n");

pts <- SpatialPointsDataFrame(coords=data.frame(x=turbines$longitude,y=turbines$latitude), data=data.frame(ors=turbines$ors,year=turbines$year))
  projection(pts) <- projection("+init=epsg:4326")

writeOGR(pts, ".", paste("wind_turbines_",toFetch[which(toFetch == max(toFetch))],sep=""), driver="ESRI Shapefile", overwrite=T)
