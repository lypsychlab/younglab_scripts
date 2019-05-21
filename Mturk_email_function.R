library(MTurkR)  
#Best to set up a temporary IAM access key ID and secret access key for this. 
Sys.setenv(AWS_ACCESS_KEY_ID="")
Sys.setenv(AWS_SECRET_ACCESS_KEY="")
contact(  
  subjects = c("Write subject header here"),  
  msgs = c("Include message body here
            "),  
  workers = c("Include list of Mturker IDs, separated by commas with no spaces")  
)  