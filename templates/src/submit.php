<?php

$date = $_POST['date'];

$time = $_POST['time'];

$timestamp = $date.$time;



function getAuthToken($timestamp)
{

    $data = array("timestamp" => $timestamp);

    $headers = array("Content-Type: application/json", "Accept: application/json");

    $ch = curl_init("http://localhost/saveTimeStamp.php");
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);

    $result = json_decode(curl_exec($ch),true);

    if (isset($token_data['access_token'])) {
        return $token_data['access_token'];
    } else{
        return false;
    }
}
