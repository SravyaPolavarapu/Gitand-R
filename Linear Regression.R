installed.packages()

# List all "attached" or loaded packages.
search()      

# You "attach" a package to make it's functions available, 
# functions to import data  from other systems.
library(foreign)

# Install the ggplot2 package for it's plotting capability.
if (!require("ggplot2")){
  install.packages("ggplot2")
}

# Then load the package.
library("ggplot2")
search()

### A Simple Regression Example   

# Look at the data sets that come with the package.
data(package = "ggplot2")$results

# Make diamonds dataset available using the data() function.
data(diamonds, package = "ggplot2")

# Create a listing of all objects in the "global environment". Look for "diamonds" in the results.
ls()

# Now investigate the structure of diamonds, a data frame with 53,940 observations
str(diamonds)

# Print the first few rows.
head(diamonds) 

# Print the last 6 lines.  
tail(diamonds)

# Find out what kind of object it is.
class(diamonds) 

# Look at the dimension of the data frame.
dim(diamonds)

### Plots in R       

# Create a random sample of the diamonds data.
diamondSample <- diamonds[sample(nrow(diamonds), 5000),]
dim(diamondSample)

# R has three systems for static graphics: base graphics, lattice and ggplot2.  
# This example uses ggplot2

# Set the font size so that it will be clearly legible.
theme_set(theme_gray(base_size = 18))

# In this sample you use ggplot2.
ggplot(diamondSample, aes(x = carat, y = price)) +
  geom_point(colour = "blue")

# Add a log scale.
ggplot(diamondSample, aes(x = carat, y = price)) +
  geom_point(colour = "blue") +
  scale_x_log10()

# Add a log scale for both scales.
ggplot(diamondSample, aes(x = carat, y = price)) +
  geom_point(colour = "blue") +
  scale_x_log10() +
  scale_y_log10()

### Linear Regression in R 

# Now, build a simple regression model, examine the results of the model and plot the points and the regression line.  

# Build the model. log of price explained by log of carat. This illustrates how linear regression works. Later we fit a model that includes the remaining variables

model <- lm(log(price) ~ log(carat) , data = diamondSample)       

# Look at the results.     
summary(model) 
# R-squared = 0.9334, i.e. model explains 93.3% of variance

# Extract model coefficients.
coef(model)
coef(model)[1] 
exp(coef(model)[1]) # exponentiate the log of price, to convert to original units

# Show the model in a plot.
ggplot(diamondSample, aes(x = carat, y = price)) +
  geom_point(colour = "blue") +
  geom_smooth(method = "lm", colour = "red", size = 2) +
  scale_x_log10() +
  scale_y_log10()

### Regression Diagnostics 

# It is easy to get regression diagnostic plots. The same plot function that plots points either with a formula or with the coordinates also has a "method" for dealing with a model object.   


# Look at some model diagnostics.
# check to see Q-Q plot to see linearity which means residuals are normally distributed

par(mfrow = c(2, 2)) # Set up for multiple plots on the same figure.
plot(model, col = "blue") 
par(mfrow = c(1, 1)) # Rest plot layout to single plot on a 1x1 grid


### The Model Object 

# Finally, let's look at the model object. R packs everything that goes with the model, e.g. the formula and results into the object. You can pick out what you need by indexing into the model object.
str(model)
model$coefficients  # note this is the same as coef(model)

# Now fit a new model including more columns
model <- lm(log(price) ~ log(carat) + ., data = diamondSample) # Model log of price against all columns

summary(model)
# R-squared = 0.9824, i.e. model explains 98.2% of variance, i.e. a better model than previously



# Create data frame of actual and predicted price

predicted_values <- data.frame(
  actual = diamonds$price, 
  predicted = exp(predict(model, diamonds)) # anti-log of predictions
)

# Inspect predictions
head(predicted_values)

# Create plot of actuals vs predictions
ggplot(predicted_values, aes(x = actual, y = predicted)) + 
  geom_point(colour = "blue", alpha = 0.01) +
  geom_smooth(colour = "red") +
  coord_equal(ylim = c(0, 20000)) + # force equal scale
  ggtitle("Linear model of diamonds data")
