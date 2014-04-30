jQuery(function() {
	jQuery('body').on('click', "[data-fields-for-collection]", function(e) {
		e.preventDefault();
		var $this=jQuery(this);
		var html_to_add=$this.attr("data-fields-for-html").replace(/dummy_id/g, new Date().getTime());
		var target=$this.attr("data-fields-for-collection") +  '_list';
		jQuery('#' + target).append(JSON.parse(html_to_add));
	});
});
