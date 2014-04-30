jQuery(function() {
	jQuery('body').on('click', "[data-modal-target]", function(e) {
		e.preventDefault();
		e.stopImmediatePropagation();
		var $this=jQuery(this);
		var url=$this.attr("href");
		var $modal=jQuery($this.attr("data-modal-target"));
		$modal.attr("data-modal-ajax-target", url);
		$modal.modal('show');
	});

	jQuery('body').on('show.bs.modal','[data-modal-ajax-target]', function(e) {
		var $this=jQuery(this);
		var targetURL=$this.attr("data-modal-ajax-target");
		var currentURL=$this.attr("data-modal-ajax-current");
		if (targetURL!=currentURL) {
			jQuery.ajax({
							url: targetURL,
							data: {modal: true},
							dataType: "html",
							context: this
			}).done(function(data) {
				var $this=jQuery(this);
				$this.find(".modal-content").html(data);
				$this.attr("data-modal-ajax-current", targetURL);
			}).fail(function(jqXHR, status, error) {
				alert("Error communicating with server, please try again.\nStatus: "+status);
				jQuery(this).modal('hide');
			});
		}
	});

	jQuery('body').on('click', "[data-fields-for-collection]", function(e) {
		e.preventDefault();
		var $this=jQuery(this);
		var html_to_add=$this.attr("data-fields-for-html").replace(/dummy_id/g, new Date().getTime());
		var target=$this.attr("data-fields-for-collection") +  '_list';
		jQuery('#' + target).append(JSON.parse(html_to_add));
	});
});
