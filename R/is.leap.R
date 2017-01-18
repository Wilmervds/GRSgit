
is.leap <- function(x) {
  if(class(x) != "numeric"){
    return('Error: argument of class numeric expected')
  } 
  if(x < 1600){
    return('That year is out of the valid range')
  }
  return(((x %% 4 == 0) & (x %% 100 != 0)) | (x %% 400 == 0))
}
