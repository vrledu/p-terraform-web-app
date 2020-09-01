<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: access");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Credentials: true");
header('Content-Type: application/json');
include('database.php');

$input = json_decode(urldecode(file_get_contents('php://input')), true);

$timestamp = $input['timestamp'];


$sql = "insert into timestamp (timestamp) value ('$timestamp')";

$result = mysqli_query($c, $sql);

if($result)
echo json_encode($result);
else
print_r(mysqli_error($c));
