s = input()
result = ""
for i in range(len(s)):
    duplicate = False

    for j in range(len(result)):
        if s[i] == result[j]:
            duplicate = True
            break

    if duplicate == False:
        result = result + s[i]

print(result)