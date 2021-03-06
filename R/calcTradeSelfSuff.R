#' Calculate food/material self sufficiencies
#' 
#' Calculates regional self sufficiences from FAO data as
#' production/domestic_supply.
#' 
#' 
#' @return Self sufficiences
#' @author Ulrich Kreidenweis
#' @seealso \code{\link{calcOutput}}, \code{\link{calcFAOmassbalance}}
#' @examples
#' 
#' \dontrun{ 
#' a <- calcTradeSelfSuff()
#' }
#' 
calcTradeSelfSuff <- function() {
  
  massbalance<-calcOutput("FAOmassbalance",aggregate = F)
  # add missing products
  newproducts<-c("betr","begr","scp")
  massbalance[,,newproducts]<-0
  k_trade<-findset("k_trade")
  massbalance<-massbalance[,,k_trade]
  
  self_suff <- massbalance[,,"production.dm"]/massbalance[,,"domestic_supply.dm"]
  self_suff <- collapseNames(self_suff)
  self_suff[is.nan(self_suff)] <- 0
  self_suff[self_suff == Inf] <- 1
  self_suff[,,newproducts]<-1
  
  ### Manual fix for self sufficiency in timber production in Middle east and Japan
  mapppnig <- toolGetMapping(type = "regional",name = "h12.csv")
  mea_list <- subset(mapppnig,mapppnig$RegionCode=="MEA")
  ## ARCHIVED VERSION - 
  ## https://web.archive.org/web/20200525075439/http://www.jatan.org/eng/japan-e.html
  ## https://web.archive.org/web/20200525120517/http://www.fao.org/3/Y2199E/y2199e10.htm
  self_suff["JPN",,findset("kforest")]                <- 0.40 ## Magpiesets need update it should be kforestry
  self_suff[mea_list$CountryCode,,findset("kforest")] <- 0.05 ## Magpiesets need update it should be kforestry
  
  weight <- massbalance[,,"domestic_supply.dm"]
  weight <- collapseNames(weight)
  weight[is.nan(weight)] <- 0
  weight[,,newproducts]<-1
  
  out <- toolHoldConstantBeyondEnd(self_suff)
  weight <- toolHoldConstantBeyondEnd(weight)
  #fading out the self sufficiency until 2050.
  #out<-convergence(origin = self_suff,aim = 1,start_year = "y2010",end_year = "y2050",type = "s")
    
  return(list(x=out,
              weight=weight,
              unit="ratio",
              description="countries' self sufficiencies in agricultural production. Production/Domestic supply")
  )
}