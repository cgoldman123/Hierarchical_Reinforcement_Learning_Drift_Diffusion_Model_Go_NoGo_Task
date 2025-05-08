library(corrplot)
library(Hmisc)
library(tidyverse)
library(glue)
library(BayesFactor)

corrplotplus <- function(
  db, rows, cols, 
  R.cex=1.0, R.vjust=-0.1, R.hjust=0.0, R.col="black", lab.size=1,lab.color='darkred',
  use.BF=TRUE, BF.cex=0.6, BF.vjust=0.35, BF.hjust=0.0, BF.col="black", replace.BF.with.p=FALSE,
  use.sig=TRUE, sig.cex=1.3, sig.vjust=-0.35, sig.hjust=0.15, sig.col="red", sig.method = "p-value",
  include.R.diagonal=TRUE,
  p.adjust.method=NA,       # anything within p.adjust.methods()
  p.adjust.direction=NA,     # c('rows', 'columns', 'all')
  cluster.method=NULL,  #c('complete', 'ward.D', 'single', 'average')
  cluster.n=0,
  rename.dict=list(),
  type = "pearson"
  ) {
  cgrid = rcorr(as.matrix(db), type=type)
  
  if (xor((p.adjust.method %>% is.na), (p.adjust.direction %>% is.na))) {
    stop(paste0(
      glue("p.adjust.method={p.adjust.method}, p.adjust.direction={p.adjust.direction}"),
      "Both must be NA or both must be set"
    ))
  }
  
  if (!is.na(p.adjust.method)) {
    if (p.adjust.direction == "rows") {
      for (r in rows) {
        cgrid$P[r, cols] = p.adjust(cgrid$P[r, cols], method = p.adjust.method)
      }
    } else if (p.adjust.direction == "cols") {
      for (c in cols) {
        cgrid$P[rows, c] = p.adjust(cgrid$P[rows, c], method = p.adjust.method)
      }
    } else if (p.adjust.direction == "all") {
      cgrid$P[rows, cols] = p.adjust(cgrid$P[rows, cols], method = p.adjust.method)
    } else {
      stop(glue("p.adjust.direction = {p.adjust.direction} is an invalid value!"))
    }
  }
  
  if (!is.null(cluster.method) && (diff(dim(cgrid$r[rows, cols])) != 0)) {
    stop("Matrix needs to be square to cluster!")
  }
  
  M = cgrid$r[rows, cols]
  
  renamer <- function(name, dict) {
    if (name %in% names(dict)) {
      dict[[name]]
    } else {
      name
    }
  }
  
  rownames(M) = row.names(cgrid$r[rows, cols]) %>% sapply(renamer, dict=rename.dict) %>% unname
  colnames(M) = colnames(cgrid$r[rows, cols]) %>% sapply(renamer, dict=rename.dict) %>% unname
  
  corrplot(M,
    method = "color", 
    tl.col = lab.color,
    tl.cex = lab.size,
    order=if(cluster.method %>% is.null) NULL else "hclust",
    hclust.method = cluster.method,
    addrect = cluster.n,
    cl.ratio = 0.2 
  )
  
  rnames = cgrid$r[rows, cols] %>% row.names
  cnames = cgrid$r[rows, cols] %>% colnames
  
  if (!is.null(cluster.method)) {
    order = corrMatOrder(cgrid$r[rows, cols], order = "hclust", hclust.method = cluster.method)
    
    rnames = rnames[order]
    cnames = cnames[order]
  }
  
  ny = rnames %>% length
  
  for (rn in rnames) {
    y = which(rn == rnames)[[1]]
    for (cn in cnames) {
      x = which(cn == cnames)[[1]]
      
      if (use.BF && rn != cn) {
        if (replace.BF.with.p) {
          p = cgrid$P[rn, cn] %>% round(., 2)
          
          if (p %>% is.na %>% `!`) {
            if (p < 0.001) {
              p = "p < 0.001"
            } else {
              p = glue("p = {p}")
            }
            
            bf = str_pad(p, 5, side = "left", pad = " ")
            text(x + BF.hjust, 1 + (ny - y) - BF.vjust, bf, cex=BF.cex, font=2, col=BF.col)
          }
        } else {
          bf = correlationBF(db[[rn]], db[[cn]])
          bf = bf@bayesFactor$bf %>% exp %>% round(., 2)
          
          if (bf %>% is.na %>% `!`) {
            if (bf > 100) {
              bf = "BF > 100"
            } else {
              bf = glue('BF: {bf}')
            }
            
            text(x + BF.hjust, 1 + (ny - y) - BF.vjust, bf, cex=BF.cex, font=2, col=BF.col)
          }
        }
      }
      
      if (use.sig && rn != cn) {
        if (sig.method == "p-value") {
          p = cgrid$P[rn, cn] %>% round(., 2)
          
          if (p %>% is.na %>% `!`) {
            if (p <= 0.001) {
              p = "***"
            } else if (p <= 0.01) {
              p = "**"
            } else if (p <= 0.05) {
              p = "*"
            } else {
              p = ""
            }
            
            lab = str_pad(p, 5, side = "left", pad = " ")
            text(x + sig.hjust, 1 + (ny - y) - sig.vjust, cex=sig.cex, lab, font=2, col=sig.col)
          }
        } else if (sig.method == "BF") {
          bf = correlationBF(db[[rn]], db[[cn]])
          bf = bf@bayesFactor$bf %>% exp %>% round(., 2)
          
          if (bf %>% is.na %>% `!`) {
            if (bf > 100) {
              bf = "****"
            } else if (bf > 30) {
              bf = "***"
            } else if (bf > 10) {
              bf = "**"
            } else if (bf > 3) {
              bf = "*"
            } else {
              bf = ""
            }
            
            lab = str_pad(bf, 5, side = "left", pad = " ")
            text(x + sig.hjust, 1 + (ny - y) - sig.vjust, cex=sig.cex, lab, font=2, col=sig.col)
          }
        }
      }
      
      r = cgrid$r[rn, cn] %>% round(., 2)
      
      if (include.R.diagonal || rn != cn) {
        text(x + R.hjust, 1 + (ny - y) - R.vjust, r, cex=R.cex, font=2, col=R.col)
      }
    }
  }
}

# database_corr = read.csv('./database_corr.csv')
# database_corr_erps = read.csv('./database_corr_erps.csv')
# instead of:
#   mycor <- rcorr(as.matrix(database_corr[,c(2:34)]), type="pearson")
#   corrplot(mycor$r[1:5,1:5], insig = "pch",method = "color", addCoef.col="black", number.cex=1.8,tl.col = "darkred",cl.ratio = 0.2, cl.align = "r")
# do:
#   corrplotBF(database_corr[,c(2:34)], 1:5, 6:15)

