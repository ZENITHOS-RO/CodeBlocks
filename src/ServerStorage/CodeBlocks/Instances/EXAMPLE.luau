return {
	compileTo = { "workspace:exampleScript" },
	codes = { --GROUP.LINE.TABLINE... // 1.1 // INSERT core:variables.string INTO 1.1;1 // ;INPUTS
		[1] = {
			position = { 250, 600 }, -- X,Y Offset only! (Starting Position, default to First Block when on Wildcard)
			[1] = {
				block = "core:variables.local",
				data = {
					inputs = {
						[1] = { selected = "any" },
						[2] = { value = nil },
						[3] = { input = "var1" },
					},
					stack = {
						[1] = { --1.1.FLOOR(1).COLUMN(1)
							[1] = { --1.1.1.1
								block = "core:flow.print",
								data = {
									inputs = {
										[1] = { value = nil },
									},
								},
							},
						}
					},

					--analysis = {} (won't be included if no analysis is present, to reduce ram space.)
				},
			},
		},
	},
}