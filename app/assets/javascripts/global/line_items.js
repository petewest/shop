jQuery(function() {
	jQuery('body').on('change', "input[data-submit-on-change=true],select[data-submit-on-change=true]", function(e) {
		var $this=jQuery(this);
		//add a flag to say which input submitted us
		$this.after("<input type='hidden' name='submitted_from' value='" + this.name + "' />");
		$this.parents('form').submit();
	});
});
