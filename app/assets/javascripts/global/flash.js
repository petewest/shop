function dismiss_flash() {
	jQuery(".alert-dismissable").slideToggle(function() { jQuery(this).remove(); });
}

function dismiss_flash_timeout(time) {
	timer=time || 5000;
	setTimeout(dismiss_flash, timer);
}
