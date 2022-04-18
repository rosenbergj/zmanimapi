# Zmanim API

## Query parameters

The API currently lives at [https://api.zmanapi.com/](https://api.zmanapi.com/).

| Parameter | Required | Value |
|-------|-------|-------|
| lat | yes | latitude in degrees<br/>(Positive = North, Negative = South) |
| lon | yes | longitude in degrees<br/> (Positive = East, Negative = West) |
| chagdays | yes | How many days of yom tov for Sukkot/Pesach/Shavuot<br/>(Must be 1 or 2) |
| offset | no | How many minutes before (negative) or after (positive) right now we should pretend to be |

## Response

A successful call will result in HTTP 200, with the response body consisting of a JSON object, with all interesting values inside the "results" object, much like with api.sunrise-sunset.org.

All times are in ISO8601 format, with a time zone included that has been predicted from the specified latitude and longitude.

| Item | Meaning | Possible values | Notes |
|-------|-------|-------|-------|
| now | time now | ISO8601 datetime | |
| sunrise | time of today's sunrise | ISO8601 datetime, `"upallday"`, or `"downallday"` | may be in past or future |
| sunset | time of today's sunset | ISO8601 datetime, `"upallday"`, or `"downallday"` | may be in past or future |
| jewish_twilight_end | time of today's nightfall, when sun is 8.5 degrees below the horizon in the evening | ISO8601 datetime or `"none"` | may be in past or future |
| sun_now | current position of sun | `"notyetup"`, `"up"`, `"twilight"`, or `"down"` | `"twilight"` always indicates post-sunset, never pre-sunrise. Also, see "Polar Notes" below. |
| hebrew_date_today | the date on the Hebrew calendar of today before sunset | `"DD Monthname, YYYY"` | Months are all 1 word; Adar is rendered as "Adar" or "Adar1" or "Adar2" |
| hebrew_date_tonight | the date on the Hebrew calendar of tonight after nightfall | `"DD Monthname, YYYY"` | Months are all 1 word; Adar is rendered as "Adar" or "Adar1" or "Adar2" |
| hebrew_date_now | the date on the Hebrew calendar as of now | `"DD Monthname, YYYY"`, or `"indeterminate"` during twilight | Months are all 1 word; Adar is rendered as "Adar" or "Adar1" or "Adar2" |
| shabbat_or_yom_tov_today | whether it is either shabbat or yom tov today before sunset | `true` or `false` | |
| shabbat_or_yom_tov_tonight | whether it is either shabbat or yom tov tonight after nightfall | `true` or `false` | |
| shabbat_or_yom_tov_now | whether it is either shabbat or yom tov right now | `true` or `false` | `true` during twilight at either start or end of shabbat / yom tov |

## Example

Request: `https://api.zmanapi.com/?lat=38.898&lon=-77.037&chagdays=1`

Response:

```json
{
  "results": {
    "now": "2022-04-18T15:21:18-04:00",
    "sunrise": "2022-04-18T06:27:05-04:00",
    "sunset": "2022-04-18T19:48:28-04:00",
    "jewish_twilight_end": "2022-04-18T20:29:45-04:00",
    "sun_now": "up",
    "hebrew_date_today": "17 Nisan, 5782",
    "hebrew_date_tonight": "18 Nisan, 5782",
    "hebrew_date_now": "17 Nisan, 5782",
    "shabbat_or_yom_tov_today": false,
    "shabbat_or_yom_tov_tonight": false,
    "shabbat_or_yom_tov_now": false
  }
}
```

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


## Other weird time notes

The API might have slightly incorrect ideas of what constitutes "today" when you're close to the start or end of Daylight Saving Time A.K.A. Summer Time. For example, when it's after 11:00pm on the night before the start of DST in the spring, the API will already be telling you about the next day's sunrise and sunset, even though normally it won't do that until after midnight.

## Execution Notes

Tested in python 3.9.
