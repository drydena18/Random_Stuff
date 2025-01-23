################################### SECTION 1: GETTING STARTED [start] #######################################################################
##--------------------------------- Quick NOTES ---------------------------------------------------------------

## ---- You can write comments and titles (like I have here) using # 
# Any comment ALWAYS needs to start with a # - i try to be consistent with my patterns of ##

# to run commands you press command + enter (mac) or cntrl + enter (windows)

## ---- You must always install packages before you use them #install.packages("package_name")

## ---- Collapse or expand the r script
# use ALT + o (windows) or comd + option + o (mac) to collapse sections
# to reopen - Edit/Folding/expand all

## ---- Keep your folders organized! 

## <- is called and assignment arrow. We use this to tell R we want 'save' the variable to the environment 

##--------------------------------- Directory Path ---------------------------------------------------------------
getwd()

##--------------------------------- Importing Data ---------------------------------------------------------------
## ---- data from a package
library(palmerpenguins)  #install.packages("palmerpenguins")
data <- penguins

#try clicking on the NAME of dataset in the environment - you can scroll through like excel

## ---- csv
raw_penguins <- read.csv("data/penguins.csv") #try changing the name (the left side of the arrow)

## ---- SPSS
library(haven)   #install.packages("haven")
data_spss <- read_sav("data/penguins.sav")  # import spss file

## ---- R data
#you WILL make mistakes in R - this will give you warning/error messages that are weird.. .. The next code will give you and error - why?
#hint what folder is this data in?

load("data/messy_names.Rdata") # example of loading R data

##--------------------------------- Remove variables from your environment ---------------------------------------------------------------
rm(raw_penguins, data) #alternatively, you can just remove the code above or comment it out..

##--------------------------------- Cleaning Variable Names (if applicable) ---------------------------------------------------------------

# In R - you should name your variables and datasets in consistent ways. 
#snake_case = most common (no capitals, no spaces)

## ---- get names of variables in dataset
names(messy_names)

## ---- clean names
library(janitor)
messy_names <- clean_names(messy_names)
names(messy_names)

#Session/restart R 

################################### SECTION 2: DATA WRANGLING[start] #######################################################################
data <- read.csv("data/penguins.csv") 
names(data)

##--------------------------------- Indexing (selecting) base R ---------------------------------------------------------------
## ---- Selecting 1 variable
data$species
#try selecting a different variable - notice as you type, R will try and guess - you can click on the variable if it pops up
data$bill_depth_mm

## ---- Selecting multiple variable
## ---- By number
# you can select rows and columns like this: data[rows,col] e.g 
data[1:4 , 2:3] #select rows 1 to 4 for columns 2 and 3
data[ , 1:3] #select all the rows for the first three columns

data[ ,c(7,9)] #select column 7 and 9 - c() stands for 'combine'

## ---- By name
data[ , c("species", "sex")]

#play around with these commands!

##--------------------------------- Indexing (selecting) tidyverse ---------------------------------------------------------------
## ---- Select command
library(tidyverse)
#piping command - %>% think of this as saying 'and then':  Cmd(contrl) + shift + m 
data %>%  
  select(1, 2) #index number - first and second column

data %>% 
  select(sex, species)  #column name

bill <- data %>% 
  select(species, starts_with("bill"))

##--------------------------------- Filter (rows)  ---------------------------------------------------------------
new_data <- data %>% 
  filter(year == 2008) 

chunky_penguins <- data %>% 
  filter(body_mass_g >= 4000) 

female_data <- data %>% 
  filter(sex == "female") 

##--------------------------------- Data Types (IMPORTANT)  ---------------------------------------------------------------
library(dplyr)
str(data) #structure of the data

## ---- ALWAYS convert nominal (categorical) data -> factor
data$species <- factor(data$species) 
data$island <- factor(data$island) 
data$sex <- factor(data$sex) 

class(data$species) 
str(data)

## ---- SIDE EXAMPLE - if the data are coded as numbers, but should be categories, here is how you can change it
#lets add a fake variable to our dataset 
data$friendly <- c(rep(1, 200),rep(2, 144)) #add the value 1 to the first 200 rows, add the value 2 to the next 144
str(data)

#Then convert friendly to a factor:
data$friendly <- factor(data$friendly, levels = c(1:2), labels = c("friendly","not_friendly"))
data$friendly

##--------------------------------- Missing data ---------------------------------------------------------------
##--- Columns with Missing values
colSums(is.na(data))

## ---- Visualize missing pattern
library(mice)
(miss <- md.pattern(data, rotate.names = TRUE))    ## visualize missings (mice package) 
# 333 participants who have zero missing data
# 9 participants who are missing on sex
# 2 participants who are missing on bill length/depth, flipper length, body mass and sex

##--- subject with ANY missing data
(miss_data <- data %>%
    filter_all(any_vars(is.na(.)))) #extra brackets around the command just mean 'print the output to the console as well'
#dot means - do this for all the variables 

# create variable for people missing on more than one variable.
data$miss <- as.numeric(rowSums(is.na(data)))

data <- data %>%
  filter(miss <= 1)

#try removing anyone with missing data
data <- data %>%
  filter(miss < 1)

md.pattern(data, rotate.names = TRUE)

#remove the missing data variable - useless now
data <- data %>% 
  select(-miss)

##--------------------------------- Descriptive ---------------------------------------------------------------
## ---- Entire dataset
library(psych)
describe(data) #central tendency, range, skew, kurtosis 

mean(data$bill_length_mm)
median(data$body_mass_g)
sd(data$body_mass_g)

## ---- Frequency 
table(data$sex)

library(sjmisc) #install.packages("sjmisc")
frq(data$sex)

##--------------------------------- Reliability ---------------------------------------------------------------
dat <- read.csv("http://www2.hawaii.edu/~georgeha/Handouts/SchoolSurvey.csv")
#fake questionare - how energetic school professionals felt on an afternoon 

dat %>%  
  select(starts_with("Lik")) %>% 
  psych::alpha(check.keys=TRUE) 

#chronbachs alpha = .81 good reliability.

##--------------------------------- Creating Composites  ---------------------------------------------------------------
dat <- dat %>% 
  mutate(energy_comp = rowMeans(data.frame(Lik1, Lik2, Lik3, Lik4, Lik5))) 

#quick check if you want
(5 + 5 + 4 + 3 + 2)/5 

mean(dat$energy_comp)
##--------------------------------- Recode into new variable  ---------------------------------------------------------------
## ---- create a variable that splits people into low energy (less than 2) and high energy (2 and higher)
dat<-dat %>%
  mutate(energry_group = case_when(energy_comp < 2  ~ 1, 
                                   energy_comp >= 2  ~ 2))

dat$energry_group<- factor(dat$energry_group,  levels = c(1:2), labels = c("low energy", "high energy"))  

dat %>% 
  frq(energry_group)

## ---- Median Split 
dat<-dat %>% 
  mutate(energry_split = case_when(energy_comp <= median(energy_comp) ~ 1,  #people less or eq to the mean get a 1 
                                   energy_comp  > median(energy_comp) ~ 2)) # people greater than the mean get a 2

##--------------------------------- Group means  ---------------------------------------------------------------
dat %>% 
  summarise(mean(energy_comp), .by = Teacher)

##---------------------------------Save dataset in spss ---------------------------------------------------------------
library(haven)
write_sav(data, "output/workshop_data_2025-01-23.sav") #note when you import this back in, you need to chage the data types again

##---------------------------------Save dataset as .Rdata (recommend) ---------------------------------------------------------------
save(data, file = "output/workshop_data_2025-01-23.Rdata") # do not need to change anyting

#restart R
################################### SECTION 2: DATA VISUALIZATION (start) #######################################################################
load("output/workshop_data_2025-01-23.Rdata")
str(data)

##---------------------------------  Simple plots (minimal edits) ---------------------------------------------------------------
library(ggplot2) #install.packages("ggplot2")

## ---- HISTOGRAM 
ggplot(data, aes(x = body_mass_g)) +  # describe how data should be mapped to features of the plot
  geom_histogram()

## ---- BAR PLOT 
ggplot(data, aes(x = island)) +
  geom_bar() 

## ---- option that gives %
library(sjPlot)
plot_frq(data$island)  #xlab("Island")

## ---- BOX PLOTS
#one variable
boxplot(data$body_mass_g) 

ggplot(data, aes(y = body_mass_g, x = "")) +
  geom_boxplot()

#two variables
ggplot(data, aes(y = body_mass_g, x = island)) +
  geom_boxplot()

## ---- VIOLIN PLOTS

#one variable
ggplot(data, aes(y = body_mass_g, x = "")) +
  geom_violin()

#two variables
ggplot(data, aes(y = body_mass_g, x = island)) +
  geom_violin()

##---------------------------------  EDIT GRAPHS ---------------------------------------------------------------
## ---- Colors
#change the colors: https://r-charts.com/color-palettes/
# you can also type the color name instead of code e.g., "blue"

#directly specify the color
ggplot(data, aes(x = body_mass_g)) + 
  geom_histogram(color="black", fill="#D7A7C7") 

#another example
ggplot(data, aes(y = body_mass_g, x = island)) +
  geom_boxplot(color = "darkblue", fill = "#CADAF1") 

#color the plot based on a variable
ggplot(data, aes(y = body_mass_g, x = island, fill = island)) + 
  geom_boxplot() 

#CHANGE color the plot based on a variable
ggplot(data, aes(y = body_mass_g, x = island, fill = island)) + 
  geom_boxplot() + 
  scale_fill_manual(values = c("#993F00", "steelblue", "#D7A7C7")) 
#ylim(0,100) this changes the y scale if needed

## ---- Themes
library(ggthemes) #install.packages("ggthemes")
library(ggpubr) #install.packages("ggpubr")
#https://statisticsglobe.com/ggthemes-package-r
#https://ggplot2.tidyverse.org/reference/ggtheme.html
##Great options: theme_clean, theme_bw, theme_calc, theme_light, theme_classic, theme_minimal, theme_pubr

ggplot(data, aes(y = body_mass_g, x = island)) + 
  geom_boxplot(fill = "purple") +
  theme_bw() #try changing the theme to one of the "Great options" i suggest above

#change colours and themes
ggplot(data, aes(y = body_mass_g, x = island, fill = island)) + 
  geom_boxplot()  +
  theme_bw(base_size = 20) + #make the base font bigger
  scale_fill_manual(values = c("#993F00", "steelblue", "#D7A7C7"))

## ---- Facet wrap (split graphs into different plots to see different groups individually)
ggplot(data, aes(x = island , fill = island)) + 
  geom_bar(color = "black") +
  facet_wrap(~sex) +
  theme_bw(base_size = 20)

## ----  Barplot (count) with grouping variable
library(see) 
ggplot(data, aes(x = island, fill = sex)) +
  geom_bar(color = "black") + # position = position_dodge()
  theme_modern()+ 
  scale_fill_manual(values = c("#993F00", "steelblue")) +
  labs(x = "Groups", y = "Count")

##--------------------------------- Bar graph for comparing means (note: there are better visualization options)  ---------------------------------------------------------------
#https://cran.r-project.org/web/packages/ggsci/vignettes/ggsci.html
library(ggpubr)
library(ggsci)

## ---- Simple plot
ggbarplot(data, x = "sex", y = "bill_length_mm", fill = "sex", add = "mean_ci")  %>% 
  ggpar() 

## ---- Edited
(bar_plot<- ggbarplot(data, x = "sex", y = "bill_length_mm", fill = "sex", add = "mean_ci")  %>% 
    ggpar(xlab = "Sex", ylab = "Bill Length") +
    theme_bw(base_size = 20) +
    scale_fill_npg(guide = "none") +
    scale_x_discrete(labels = c("Female", "Male")))

##--------------------------------- Violin plots ---------------------------------------------------------------

## ---- edited
(violin_plot <- ggplot(data, aes(y = body_mass_g, x = island, fill = island)) +
  geom_violin() +
  theme_modern() +
  scale_fill_manual(values = c("#426600","#BF8082","steelblue")) +
  stat_summary(fun = "mean", geom = "point", col="black", size = 3, shape = 24, fill = "red" )+
  theme(legend.position = "none") +
  coord_flip() + 
  xlab("") + ylab("Body Mass"))

## ---- FUN Violin plots 
library(ggstatsplot)

## ---- simple plot
(vio_plot <- ggbetweenstats(data = data, x = island, y = body_mass_g,
                         messages = FALSE, results.subtitle = FALSE, pairwise.display = "none"))

## ---- edited 
(vio_plot <- ggbetweenstats(data = data, x = island, y = body_mass_g,ylab = "Body Mass", xlab = "Island",
                          messages = FALSE, results.subtitle = FALSE,pairwise.display = "none")  +
    theme_light(base_size = 20) +
    theme(legend.position="none")) 

##--------------------------------- pirateplot ---------------------------------------------------------------
library(yarrr)   #https://cran.r-project.org/web/packages/yarrr/vignettes/pirateplot.html           

pirateplot(body_mass_g ~ island, data = data, inf.method = "ci")

??pirateplot 

##--------------------------------- FUN Raincloud plots ---------------------------------------------------------------
#https://github.com/RainCloudPlots/RainCloudPlots
library(ggrain)
library(see)

## ---- simple plot
ggplot(data, aes(x = island, y = body_mass_g , fill = island)) + 
  geom_rain()

## ---- edited
ggplot(data, aes(x = island, y = body_mass_g , fill = island)) + 
  geom_rain(alpha = .5,
            point.args = list(aes(color = island), alpha = .5, size = 2.5)) +
  xlab("") + ylab("Body Mass") +
  theme_classic(base_size = 20) +
  scale_color_manual(values = c("#426600","#BF8082","steelblue")) +
  scale_fill_manual(values =  c("#426600","#BF8082","steelblue")) +
  theme(legend.position="none") + 
  coord_flip()
 
#ggsave(file = "output/fig1_2025-01-23.tiff",width = 8, height=6)

##--------------------------------- Line Plots ---------------------------------------------------------------

## ---- One variable across time/condition
## ---- Simple
ggline(data, x = "year", y = "body_mass_g", add = "mean_ci") 
 
## ---- Edited
ggline(data, x = "year", y = "body_mass_g", add = "mean_ci") %>% 
  ggpar(ylim = c(2000,6000),  ylab = "Body Mass") #WEIRD.. 

#integer = decimals
class(data$year)
data$year <- as.numeric(data$year)
class(data$year)
#edit again
ggline(data, x = "year", y = "body_mass_g", add = "mean_ci", 
       group = "sex", color = "sex", legend = "right",) %>% 
  ggpar(ylim = c(2000,6000),  ylab = "Body Mass",  legend.title = "Sex") +
  scale_x_discrete(labels = c("2007", "2008", "2009"))
 
##--------------------------------- Scatterplot ---------------------------------------------------------------
## ---- Two continuous variables
ggplot(data, aes(x = body_mass_g, y = bill_length_mm)) + 
  geom_point()  

## ---- Two continuous variables (colour by sex) 
ggplot(data, aes(x = body_mass_g, y = bill_length_mm, color = sex)) + 
  geom_point(alpha=0.7) +
  theme_modern() + 
  labs(x = "Body Mass", y = "Bill Length")

## ---- Two continuous variables + grouping var
(scatterplot <- ggplot(data, aes(x = body_mass_g, y = bill_length_mm, color = sex)) +
    geom_point(alpha = 0.6) +
    geom_smooth(method = lm, se = TRUE) + 
    theme_modern() +
    labs(x = "Body Mass", y = "Bill Length") +
    scale_color_manual(values = c("#009292", "#9999FF")))

## ---- Interactive plot
library(plotly)
ggplotly(scatterplot) 

#Make sure you are looking at the "Plots" menu, not the "Viewer" menu to see this plot
(scatterplot <- ggplot(data, aes(x = body_mass_g, y = bill_length_mm, color = sex)) + 
    geom_point(alpha = 0.6) +
    geom_smooth(method = lm, se = TRUE) + 
    theme_bw() +
    facet_wrap(~sex) + #create separate plots for sex
    labs(x = "Body Mass", y = "Bill Length") +
    scale_color_manual(values = c("#009292", "#9999FF")))

## ---- Grouped Scatter plot with density plots
library(ggpubr)
ggscatterhist(
  data, x = "body_mass_g", y = "bill_length_mm",
  color = "species", size = 3, alpha = 0.6,
  palette = c("#00AFBB", "#E7B800", "#FC4E07"),
  margin.params = list(fill = "species", color = "black", size = 0.4))  

##--------------------------------- Correlation Table ---------------------------------------------------------------
library(rstatix)
cor_vars <- data %>% #select variables to include in the corrplot and change the names
  select(bill_depth_mm, bill_length_mm, flipper_length_mm, body_mass_g) %>%  
  rename('Bill Depth' = 1,                  
         'Bill Length' = 2,
         'Flipper Length' = 3, 
         'Body Mass' = 4)

## ---- Tab_corr
(cor_matrix <- cor(cor_vars, use = "complete.obs"))

## ---- simple
tab_corr(cor_matrix, triangle = "lower")

## ---- ApaTable
library(apaTables)
apa.cor.table(cor_vars, filename = "output/cor_table_apa.doc" )

##--------------------------------- Correlation Plots ---------------------------------------------------------------
#https://cran.r-project.org/web/packages/corrplot/vignettes/corrplot-intro.html
library(corrplot)
(cor_matrix <- cor(cor_vars, use="complete.obs"))

## ---- ggcorplot example
library(ggcorrplot)
(corplot <- ggcorrplot(cor_matrix, hc.order = FALSE, type = "lower",
                     lab = TRUE, colors = c("red", "white", "#6D9EC1"), show.diag = TRUE, 
                     lab_col = "black"))

################################### SECTION 3: ANALYSES [start] #######################################################################
##--------------------------------- Importing data (.Rdata)---------------------------------------------------------------
load("output/workshop_data_2025-01-23.Rdata")
str(data)

##--------------------------------- Independent samples t-test ---------------------------------------------------------------
## ---- Do males and females differ on body mass?
library(tidyverse)
library(car) #https://remi-theriault.com/blog_table
options(scipen = 999) # this gets  rid of scientific notation

## ---- Mean of Self-esteem by sex
data %>% 
  summarise(mean(body_mass_g), .by = sex)

## ----levenes test (is the variance similar?)
leveneTest(body_mass_g ~ sex, data = data, center = mean) # Levene’s test center = mean is the "original levenes test"; this matches spss
# significant = significantly different

## ---- run the independent samples t-test
with(data, t.test(body_mass_g ~ sex, var.equal = FALSE)) # if unequal, will preform welsh's test

## ---- Visualize
library(ggstatsplot)
library(ggthemes)  #https://statisticsglobe.com/ggthemes-package-r
(violin_plot <- ggbetweenstats(data = data, x = sex, y = body_mass_g, ylab = "Body Mass", xlab = "Sex",
                             messages = FALSE, results.subtitle = FALSE)  +  
    theme_base()) 

## ---- Run the paired samples t-test
#(paired_t_test<-with(data, t.test(esteem.comp.1.00, esteem.comp.4.00, paired = TRUE)))

##--------------------------------- ANOVA ---------------------------------------------------------------
library(car) #https://remi-theriault.com/blog_table
library(apaTables)
(original_contrasts <- options("contrasts")) #compares treatment against a reference
options(contrasts = c("contr.sum", "contr.poly")) # matches settings in spss

## ---- anova model
aov_model <- with(data, aov(body_mass_g ~ species)) 
#note to make this an anocva - just + variables e.g. species + sex
(anova_results <- car::Anova(aov_model, type=3))# type 3 = type 3 SS

## ---- apa table
apa.aov.table(aov_model, table.number = 2, filename = "output/anova_table_apa.doc", type = 3, conf.level = 0.95)  #expects lm input    

#posthoc tests
library(tidyverse)
library(broom)
library(tidyr)
library(rempsyc) #pretty T table 
library(flextable)

## ---- Tukey hsd 
(tukey_test <- emmeans::emmeans(aov_model,specs = pairwise ~ species,adjust = "tukey")) 
confint(tukey_test, level = 0.95)$contrasts

## ---- Bonferoni
(bonf_test <- emmeans::emmeans(aov_model,specs = pairwise ~ species,adjust = "bonf")) 
confint(bonf_test, level = 0.95)

# Reset to original contrasts
options(contrasts=unname(unlist(original_contrasts)))
options("contrasts") #check

##---------------------------------  Linear Regression ---------------------------------------------------------------
library(broom)
options(scipen = 999)

lm_model <- lm(body_mass_g ~ bill_length_mm + bill_depth_mm, data = data) #unstandardized beta at presented.

library(performance)
check_model(lm_model)

library(sjPlot)
lm_model %>% 
  tab_model(show.std = TRUE) #digits = 3,   show.intercept = FALSE

summary(lm_model) #anov for model is presented in writing below

##### ---- effects plot  
plot_model(lm_model, type = "pred", terms = "bill_length_mm") 
# watch scale!

plot_model(lm_model, type = "pred", terms = "bill_length_mm") +
  scale_y_continuous(limits = c(2000, 6000)) +
  theme_base()

plot_model(lm_model, type = "pred", terms = "bill_depth_mm") +
  scale_y_continuous(limits = c(2000, 6000)) +
  theme_base()

#APA table
library(apaTables)
apa.reg.table(lm_model, filename = "output/regression_results.doc") #automatically calculates standardized betas

#plot the overall model
plot_model(lm_model, show.values = TRUE, type = "std", vline = "darkgrey") + 
  theme_bw()


#things to know:  r will automatically dummy code a factor variable

#if you want to do an interaction:  esteem.comp.1.00*age  - this would give you the interaction and two main effects

##--------------------------------- Interactive plots examples ---------------------------------------------------------------
#https://www.datanovia.com/en/blog/gganimate-how-to-create-plots-with-beautiful-animation-in-r/
#https://r-graph-gallery.com/287-smooth-animation-with-tweenr.html
library(gapminder)
library(ggplot2)
library(gganimate)
library(gifski)

# Make a ggplot, but add frame=year: one image per year
ggplot(gapminder, aes(gdpPercap, lifeExp, size = pop, colour = country)) +
  geom_point(alpha = 0.7, show.legend = FALSE) +
  scale_colour_manual(values = country_colors) +
  scale_size(range = c(2, 12)) +
  scale_x_log10() +
  facet_wrap(~continent) +
  # Here comes the gganimate specific bits
  labs(title = 'Year: {frame_time}', x = 'GDP per capita', y = 'life expectancy') +
  transition_time(year) +
  ease_aes('linear')

# libraries:
library(ggplot2)
library(tidyverse)
library(gganimate)
library(babynames)
library(hrbrthemes)
library(viridis)

# Keep only 3 names
don <- babynames %>% 
  filter(name %in% c("Ashley", "Patricia", "Helen")) %>%
  filter(sex == "F")

# Plot
don %>%
  ggplot( aes(x = year, y = n, group = name, color = name)) +
  geom_line() +
  geom_point() +
  scale_color_viridis(discrete = TRUE) +
  ggtitle("Popularity of American names in the previous 30 years") +
  theme_ipsum() +
  ylab("Number of babies born") +
  transition_reveal(year)
