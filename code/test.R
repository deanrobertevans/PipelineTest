require(mailR)
library(httr)
library(tidyverse)
library(geojsonsf)
library(sf)
library(magrittr)


# Input parameters
username <- "kbapipeline"
password <- Sys.getenv("KBA_PIPELINE_PASS")
address <- "Restricted/FeatureServer/4"
spatial <- F

# Get token
response <- httr::POST("https://gis.natureserve.ca/portal/sharing/rest/generateToken",
                       body = list(username=username, password=password, referer=":6443/arcgis/admin",f="json"),
                       encode = "form")
token <- content(response)$token

# Get GeoJSON
url <- parse_url("https://gis.natureserve.ca/arcgis/rest/services")
url$path <- paste(url$path, paste0("EBAR-KBA/", address, "/query"), sep = "/")
url$query <- list(where = "OBJECTID >= 0",
                  outFields = "*",
                  returnGeometry = "true",
                  f = "geojson")
request <- build_url(url)
response <- VERB(verb = "GET",
                 url = request,
                 add_headers(`Authorization` = paste("Bearer ", token)))
data <- content(response, as="text") %>%
  geojson_sf()

# If non-spatial, drop geometry
if(!spatial){
  data %<>% st_drop_geometry()
}

# Get number of species
NSpecies <- nrow(data)

send.mail(from = "pipeline@deanrobertevans.ca",
          to = c("devans@birdscanada.org","deanevans1992@gmail.com"),
          subject = "KBA Canada Pipeline",
          body = paste0("There are ",NSpecies, " species in the KBA-EBAR Database. This message was generated automattically based on the CronR scheduler."),
          smtp = list(host.name = "live.smtp.mailtrap.io", port = 587,
                      user.name = "api",
                      passwd = Sys.getenv("MAILTRAP_PASS"), ssl = TRUE),
          authenticate = TRUE,
          send = TRUE)


