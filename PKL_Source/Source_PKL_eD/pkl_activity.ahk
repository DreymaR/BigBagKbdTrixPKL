activity_ping(mode = 1) {
	activity_main(mode, 1)
}

activity_setTimeout(mode, timeout) {
	activity_main(mode, 2, timeout)
}

activity_main(mode = 1, ping = 1, value = 0) {
	static mode1ping := 0
	static mode2ping := 0
	static mode1timeout := 0
	static mode2timeout := 0
	if ( ping == 1 ) {
		mode%mode%ping := A_TickCount
	} else if ( ping == 2 ) {
		mode%mode%timeout := value
	}
	return

	activityTimer:
	if ( mode1timeout > 0 && A_TickCount - mode1ping > mode1timeout * 60000 ) {
		if ( not A_IsSuspended ) {
			gosub toggleSuspend
			activity_ping( 2 )
			return
		}
	}
	if ( mode2timeout > 0 && A_TickCount - mode2ping > mode2timeout * 60000 ) {
		gosub ExitPKL
		return
	}
	return
}
