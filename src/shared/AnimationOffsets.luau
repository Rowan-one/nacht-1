return {
	UnarmedIdle = {
		RootJoint = { Offset = CFrame.Angles(0, 0, math.rad(-10)) },
		Neck = { Offset = CFrame.Angles(0, 0, math.rad(10)) },
	},

	LightPunch = {
		RootJoint = {
			Offset = CFrame.Angles(math.rad(15), 0, math.rad(-25)),
			Peak = 0.2
		},
		Neck = { Offset = CFrame.Angles(math.rad(-10), 0, math.rad(10)), Peak = 0.2 }
	},

	Dash = {
		RootJoint = { Offset = CFrame.Angles(0, 0, math.rad(10)) },
	}
}
