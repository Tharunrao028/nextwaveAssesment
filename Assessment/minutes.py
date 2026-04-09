def convert_minutes(total_minutes):
    hours = total_minutes // 60
    minutes = total_minutes % 60

    result = ""

    if hours > 0:
        if hours == 1:
            result += "1 hr "
        else:
            result += f"{hours} hrs "

    if minutes > 0:
        if minutes == 1:
            result += "1 minute"
        else:
            result += f"{minutes} minutes"

    return result.strip()

print(convert_minutes(130))  
print(convert_minutes(110))  