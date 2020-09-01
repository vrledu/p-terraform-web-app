<!DOCTYPE html>
<html>
<head>
	<title></title>
	<style type="text/css">
		form {
		  display: block;
		  margin-left: auto;
		  margin-right: auto;
		  width: 40%;
		  background: #ADD8E6;
		  padding-top: 25px;
		  padding-bottom: 25px;
		}

		.inputdiv{
			margin-top: 10px;
			margin-bottom: 5px;
		}
	</style>
	<script type="text/javascript" src="jquery.min.js"></script>
</head>
<body>
	<div >
		<form method="post" >
			<div align="center">
				<div class="inputdiv">
					<input id="date" type="date" name="date" >
				</div>
				<div>
					<label>Hour</label>
					<input id="hour" type="text" name="hour" >
				</div>
				<div>
					<label>Minute</label>
					<input id="minutes" type="text" name="minutes" >
				</div>
				<div>
					<label>Seconds</label>
					<input id="seconds" type="text" name="seconds" >
				</div>
				<div>
					<input id="btSubmit" type="button" value="submit" name="Insert Timestamp">
				</div>
			</div>

		</form>
	</div>
</body>
<script type="text/javascript">
	$('#btSubmit').click(function(){
	 	var date = $('#date').val();
	 	var hour= $('#hour').val();
	 	var minutes= $('#minutes').val();
	 	var seconds= $('#seconds').val();

	 	var timeString = hour + ':' + minutes + ':'+seconds;
	 	var timestamp = date+' '+timeString;

	 	var data = {"timestamp" : timestamp};
	 	$.ajax({
	      url:'saveTimeStamp.php',
	      type:'POST',
	      dataType:'json',
	      data:JSON.stringify(data),
	    })//end of ajax
	    .done(function(result){
	    	if(result){
	    		alert('Success');
	    	}
	    })//end of done
	    .fail(function( xhr, status, errorThrown ) {
	      alert("Sorry, there was a problem!");
	      console.log("Error: " + errorThrown);
	      console.log("Status: " + status);
	      console.dir(xhr);
	    });//end of fail

	});
</script>
</html>
