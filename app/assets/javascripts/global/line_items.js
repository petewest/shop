jQuery(function() {
	jQuery('body').on('change', "input[data-submit-on-change=true]", function(e) {
		$this=jQuery(this);
		$this.parents('form').submit();
	});
});
