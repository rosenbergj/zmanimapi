# Zmanim API

## Polar Notes

Close enough to the poles, during summer in that hemisphere, the value of `jewish_twilight_end` may be "none". In this case, the Hebrew date might be "indeterminate" from sunset until the end of the day, local time. If the script also couldn't determine your local time zone, it uses UTC. The combination of these two things might produce really weird results.

Here are some other details about values returned in areas that are particularly far north or south:

| Situation                                                                                               | Values                                                                                                                                                                                                                    |
|---------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Summer, sun does not set                                                                                | `sunrise`: "upallday"<br/> `sunset`: "upallday"<br/> `jewish_twilight_end`: "none"<br/> `sun_now`: "up"<br/> `hebrew_date_now`: always today's date, never tonight's date                                                 |
| Summer, sun does set but it never gets dark enough to see 3 stars                                       | `jewish_twilight_end`: "none"<br/> `sun_now`: changes from "twilight" to "notyetup" at midnight local time, never "down" (see note below)<br/> `hebrew_date_now`: always today's date or "indeterminate", never tonight's date |
| Winter, sun never rises but it does get high enough to prevent seeing 3 stars                           | `sunrise`: "downallday"<br/> `sunset`: "downallday"<br/> `jewish_twilight_end`: (the usual time)<br/> `sun_now`: "twilight" all morning/day, then "down"<br/> `hebrew_date_now`: always "indeterminate" or tonight's date |
| Winter, sun never rises or even gets high enough to prevent seeing 3 stars                              | `sunrise`: "downallday"<br/> `sunset`: "downallday"<br/> `jewish_twilight_end`: "none"<br/> `sun_now`: "down"<br/> `hebrew_date_now`: always tonight's date!                                                              |

Note: A day's sunset is defined as the next sunset after noon that day, assuming there is one in the next 24 hours or so. Similarly, a day's sunrise is defined as the last sunrise before noon that day, if it was in the previous 24 hours or so. That means, for example, that on July 27, 2021, in Tromsø, Norway, when the sun sets at 12:09am, rises at 1:32am, and sets again at 11:56pm, we do not count the 12:09am setting as that day's sunset. Therefore, we will incorrectly report that the sun is "notyetup" between midnight and 1:32am that day.


## Execution Notes

Requires python 3.6, 3.7, or 3.8. Does not work on 3.9 yet due to numpy/llvmlite issues. The Github Action only supports python 3.6, so that's the recommended version right now.
