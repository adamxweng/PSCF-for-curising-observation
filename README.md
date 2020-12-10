# PSCF-for-curising-observation
An R script for applying PSCF on curising observation/PSCF算法运用于走航观测.

Atmospheric pollutant observation on mobile platforms, which is also known as cruising observation has been gaining lots of popularity. Instrumentations or sensors are usually installed on electronic vehicles (EV), drones or aircrafts. This type of observation is not constrained by a fixed location, which can largely enhance geographical resolution.

The temporal resolution of those instrumentations or sensors installed on the mobile platform is fairly high (e.g. signal per second). With a large quantity of data collected, there is a need for constructing a meaningful statistics from the data.

Usually, cruising observation is more likely under the effect of a sudden and irregular emission. For instance, Detecting a spike of concentration in a particular location does not guarantee a similar level of concentration will be detected repeatedly. Therefore, using a simple average approach to represent the general concentration level of different locations could be problematic.

Here, I share my R script on how to apply potential source contribution function (PSCF) to indicate what regions (i.e. grid cells) may have consistent high pollution level. The weighting calibration method I used can be found in the study of Xu and Akhtar (2010). You can also adjust or apply your own weighting scales from the lines 81 to 91 of the R script.

The script can generate dummy data in Beijing. The general format of the data must contain columns of longitude, latitude and concentration level of a particular pollutant.

Feel free to use the script! Please acknowledge me when commercialize this approach. If any chances for future cooperation, please let me know. Cheers.
