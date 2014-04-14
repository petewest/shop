jQuery(function() {
	jQuery('body').on('change', "input[data-submit-on-change=true],select[data-submit-on-change=true]", function(e) {
		var $this=jQuery(this);
		$this.parents('form').submit();
	});
});
