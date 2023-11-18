# IF Parcel Job V1 For QB-Core

Dont Rename It

Put this snippet inside qb-core/shared/jobs.lua

```
['parcel'] = {
		label = 'Parcel',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
            ['0'] = {
                name = 'Collector',
                payment = 50
            },
        },
	},
```
And
Put this snippet inside qb-cityhall/config.lua ---> On Line No.10 Only If You Are Using Qb-Cityhall. If You
Are Using Different Cityhall Then You Have To Find The Location And Put It There :D
```
["parcel"] = {["label"] = "Parcel Collector", ["isManaged"] = false},

```
JOIN DISCORD FOR SUPPORT- https://discord.gg/BSU6Zqsg2n

ENJOY :D
