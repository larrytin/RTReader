$(function() {
	$('.file_upload_warper').mouseover(function() {
		$('.upload_button').attr('src', 'images/button_select_rollover.png');
	}).mouseout(function() {
		$('.upload_button').attr('src', 'images/button_select_normal.png');
	}).mousedown(function() {
		$('.upload_button').attr('src', 'images/button_select_pressed.png');
	}).mouseup(function() {
		$('.upload_button').attr('src', 'images/button_select_normal.png');
	});
	
	$("#newfile").change(function() {
		$("span.file_text").text($("#newfile").val());
	});
	
	$("a.submit").click(function() {
		$("#upload_form").submit();
	});
});