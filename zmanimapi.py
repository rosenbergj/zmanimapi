#!/usr/bin/env python3 -u

import datetime
import pytz
from timezonefinder import TimezoneFinder
from convertdate import hebrew
import ephem
import json

def jewish_holiday(date, chagdays=1):
    if (chagdays != 1 and chagdays != 2):
        raise ValueError("chagdays must be 1 or 2")
    if (date[1] == 7 and date[2] < 3):
        # Rosh Hashanah
        return True
    if (date[1] == 7 and date[2] == 10):
        # Yom Kippur
        return True
    if (date[1] == 7 and date[2] == 15):
        # Sukkot, day 1
        return True
    if (date[1] == 7 and date[2] == 22):
        # Shemini Atzeret
        return True
    if (date[1] == 1 and date[2] == 15):
        # Pesach, day 1
        return True
    if (date[1] == 1 and date[2] == 21):
        # Pesach, day 7
        return True
    if (date[1] == 3 and date[2] == 6):
        # Shavuot
        return True
    if chagdays == 2:
        if (date[1] == 7 and date[2] == 16):
            # Sukkot, day 2
            return True
        if (date[1] == 7 and date[2] == 23):
            # Simchat Torah
            return True
        if (date[1] == 1 and date[2] == 16):
            # Pesach, day 2
            return True
        if (date[1] == 1 and date[2] == 22):
            # Pesach, day 8
            return True
        if (date[1] == 3 and date[2] == 7):
            # Shavuot, day 2
            return True
    return False

def hebrew_monthname(thedate):
    months = {True: ("", "Nisan", "Iyar", "Sivan", "Tammuz", "Av", "Elul", "Tishrei", "Heshvan", "Kislev", "Tevet", "Shevat", "Adar1", "Adar2"), False: ("", "Nisan", "Iyar", "Sivan", "Tammuz", "Av", "Elul", "Tishrei", "Heshvan", "Kislev", "Tevet", "Shevat", "Adar")}
    return months[hebrew.leap(thedate[0])][thedate[1]]

def do_the_things(lat, lon, chagdays=2):
    tf = TimezoneFinder()
    tzname = tf.timezone_at(lng=lon, lat=lat)
    try:
        tz = pytz.timezone(tzname)
    except pytz.exceptions.UnknownTimeZoneError:
        tz = pytz.timezone('UTC')

    now = datetime.datetime.now(tz=tz)
    noon = tz.localize(datetime.datetime(year=now.year, month=now.month, day=now.day, hour=12, minute=30))
    today = now.date()
    tomorrow = today + datetime.timedelta(days=1)

    # Get Hebrew calendar dates
    hebtoday = hebrew.from_gregorian(today.year, today.month, today.day)
    hebtomorrow = hebrew.from_gregorian(tomorrow.year, tomorrow.month, tomorrow.day)
    hebmonthtoday = hebrew_monthname(hebtoday)
    hebmonthtomorrow = hebrew_monthname(hebtomorrow)


    # Set up ephem info to determine sunset and nightfall
    herenow = ephem.Observer()
    herenow.lat, herenow.lon = lat*ephem.pi/180, lon*ephem.pi/180
    herenow.date = ephem.Date(now.astimezone(pytz.utc))
    herenoon = ephem.Observer()
    herenoon.lat, herenoon.lon = lat*ephem.pi/180, lon*ephem.pi/180
    herenoon.date = ephem.Date(noon.astimezone(pytz.utc))
    sun = ephem.Sun()

    # Determine "set" and "dark" for today (may be in the past)
    todayrise_eph = herenoon.previous_rising(sun)
    todayrise = pytz.utc.localize(todayrise_eph.datetime()).astimezone(tz)
    tonightset_eph = herenoon.next_setting(sun)
    tonightset = pytz.utc.localize(tonightset_eph.datetime()).astimezone(tz)
    oldhorizon = herenoon.horizon
    oldpressure = herenoon.pressure
    herenoon.pressure = 0
    # All horizon math is from top of sun disk
    # We need to take into account sun's radius, averaging .266 degrees
    herenoon.horizon = "-8.233" # middle of sun 8.5 deg
    try:
        tonightdark_eph = herenoon.next_setting(sun)
        tonightdark = pytz.utc.localize(tonightdark_eph.datetime()).astimezone(tz)
        tonightdark_txt = tonightdark.isoformat(timespec='seconds')
    except ephem.AlwaysUpError:
        tonightdark_txt = 'none'
    herenoon.horizon = oldhorizon
    herenoon.pressure = oldpressure

    # Status of sun
    if todayrise > now:
        sunnow = "notyetup"
    elif tonightset > now:
        sunnow = "up"
    elif (tonightdark_txt == 'none' or tonightdark > now):
        sunnow = "twilight"
    else:
        sunnow = "down"

    # Is it Shabbat or a holiday?
    shabbat_or_holiday_today = (today.isoweekday() == 6)
    if (jewish_holiday(date=hebtoday, chagdays=chagdays)):
        shabbat_or_holiday_today = True
    shabbat_or_holiday_tonight = (today.isoweekday() == 5)
    if (jewish_holiday(date=hebtomorrow, chagdays=chagdays)):
        shabbat_or_holiday_tonight = True

    # Combine hebdate logic and shabbat/holiday logic with sun up/down logic
    if (sunnow == "notyetup" or sunnow == "up"):
        shabbat_or_holiday_now = shabbat_or_holiday_today
        hebrew_date_now = "{} {}, {}".format(hebtoday[2], hebmonthtoday, hebtoday[0])
    elif (sunnow == "down"):
        shabbat_or_holiday_now = shabbat_or_holiday_tonight
        hebrew_date_now = "{} {}, {}".format(hebtomorrow[2], hebmonthtomorrow, hebtomorrow[0])
    elif (sunnow == "twilight"):
        shabbat_or_holiday_now = (shabbat_or_holiday_today or shabbat_or_holiday_tonight)
        hebrew_date_now = "indeterminate"
    else:
        raise ValueError("How is the sun not up or down or twilight?")

    # time for output
    to_return = {}
    to_return["results"] = {
        "sunrise": todayrise.isoformat(timespec='seconds'),
        "sunset": tonightset.isoformat(timespec='seconds'),
        "jewish_twilight_end": tonightdark_txt,
        "sun_now": sunnow,
        "hebrew_date_today": "{} {}, {}".format(hebtoday[2], hebmonthtoday, hebtoday[0]),
        "hebrew_date_tonight": "{} {}, {}".format(hebtomorrow[2], hebmonthtomorrow, hebtomorrow[0]),
        "hebrew_date_now": hebrew_date_now,
        "shabbat_or_yom_tov_today": shabbat_or_holiday_today,
        "shabbat_or_yom_tov_tonight": shabbat_or_holiday_tonight,
        "shabbat_or_yom_tov_now": shabbat_or_holiday_now,
    }

    return json.dumps(to_return)

def lambda_handler(event, context):
    query = event['queryStringParameters']
    output = do_the_things(lat=float(query['lat']), lon=float(query['lon']), chagdays=int(query['chagdays']))
    return {
        'statusCode': 200,
        'body': output
    }

if __name__ == "__main__":
   print(do_the_things())
