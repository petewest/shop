jQuery(function() {
	jQuery('body').on('change', "input[name='line_item[quantity]']", function(e) {
		$this=jQuery(this);
		$total_field=jQuery("#" + $this.attr("data-total-field"));
		$total_field.html(parseInt(this.value)*parseFloat($this.attr("data-item-cost")));
});
});
