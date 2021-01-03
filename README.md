# Zmanim API

## Polar Notes

Close enough to the poles, during summer in that hemisphere, the value of `jewish_twilight_end` may be "none". In this case, the Jewish date might be "indeterminate" from sunset until the end of the day, local time. If the script also couldn't determine your local time zone, it uses UTC. The combination of these two things might produce really weird results.

## Execution Notes

Requires python 3.6, 3.7, or 3.8. Does not work on 3.9 yet due to numpy/llvmlite issues. The Github Action only supports python 3.6, so that's the recommended version right now.
