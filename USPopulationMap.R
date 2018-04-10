library(dplyr)

# population of US leaflet map

ogrListLayers("http://eric.clst.org/assets/wiki/uploads/Stuff/gz_2010_us_040_00_20m.json")

USSTATES <- readOGR("http://eric.clst.org/assets/wiki/uploads/Stuff/gz_2010_us_040_00_20m.json") %>%
  st_as_sf()

# read in future population
POP <- read.csv("https://uva-demographics.github.io/main-site/maps/data/2016-11-13-us-estimates-projections.csv", header=TRUE)  %>% 
  rename(NAME = name)

States_Pop <- dplyr::left_join(USSTATES,POP,"NAME" = "NAME")  %>%
  dplyr::select(NAME,CENSUSAREA,pop2010,pop2020,pop2030,pop2040)

States_Pop$pop2040bucket <- factor(
  cut(as.numeric(States_Pop$pop2040), c(500000,1000000,5000000,10000000,20000000,40000000,90000000)),
  labels = c("Less than 1000000", "1000000 to 5000000", "5000000 to 10000000","10000000 to 20000000","20000000 to 40000000", "More than 40000000")
)

pop2040bucketPal <- colorFactor(c("#f3e79b", "#fac484", "#f8a07e", "#eb7f86", "#ce6693", "#a059a0", "#5c53a5"), States_Pop$pop2040bucket)

pop2040 <- leaflet(States_Pop) %>% addProviderTiles(providers$CartoDB.DarkMatter) %>%
  setView(-102.725219, 41.453873, zoom = 3) %>% 
  addPolygons( data = States_Pop,
               fillColor = ~pop2040bucketPal(pop2040bucket),
               weight = 0.8,
               opacity = 0.6,
               smoothFactor = 0.1,
               #color = ~crimeBucketPal(crimebucket),
               color = "white",
               fillOpacity = 0.8,
               label = ~paste0("Population of 2040: ", pop2040),
               highlight = highlightOptions(
                 fillColor = "orange",
                 fillOpacity = 1)) %>%
  addLegend(pal = pop2040bucketPal, 
            values = ~pop2040bucket, 
            position = "bottomright", 
            title = "Estimated Population in 2040",
            opacity = 1)

pop2040

# *** EXPORT TO THE WEB ***

saveWidget(pop2040, file="USpopulation.html", selfcontained=TRUE)



