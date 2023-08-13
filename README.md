# VNParking Requirements

create an iOS app that show the following information:
 - the carparks (carpark_number) that has highest and lowest available lots currently, from each carpark category displaying the available lots
 - poll the latest data every 60 seconds

carpark category* (based on total_lots)
 - small : less than 100 lots
 - medium : 100 lots or more, but less than 300 lots
 - big : 300 lots or more, but less than 400 lots
 - large : 400 lots or more

Do note that carpark_info is an array and there are cases that there are more than 1 object in the carpark_info array, for example, for carpark MP5M.

![unnamed](https://github.com/wlvoon93/VNParking/assets/8418334/0c192bf6-bc80-4e81-bcf7-9a971c75b193)

the total_lots for this car park (MP5PM) should the the total for all lot_types, which in this case 159+40+159 = 358, and 
the lots_available for this car park should be total of all lots_available, which in this case 16+0+0=16.

Please write the code in swift. There is no specific UI requirement, as long as all the information required is shown. Sample UI (dummy value) for your reference:

SMALL
HIGHEST (97 lots available)

HE12

LOWEST (1 lots available)

HE01,HE02,GE04

------------------------------------------
MEDIUM
HIGHEST (297 lots available)

VB02

LOWEST (0 lots available)

XE01, LP01

------------------------------------------
BIG
HIGHEST (390 lots available)

PO01

LOWEST (0 lots available)

FA-1, FA03, HO04

------------------------------------------
LARGE
HIGHEST (590 lots available)

MN01

LOWEST (0 lots available)

HE10,HE12,KE09
