function dismiss_flash() {
	jQuery(".alert-dismissable").slideToggle(function() { jQuery(this).remove(); });
}

function dismiss_flash_timeout(time=5000) {
	setTimeout(dismiss_flash, time);
}
