<?php

if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
    $forwarded_for = $_SERVER['HTTP_X_FORWARDED_FOR'];
    if ($forwarded_for) {
        $forwarded_for = explode(',', $forwarded_for);
        $forwarded_for = end($forwarded_for);
        $forwarded_for = trim($forwarded_for);
        $_SERVER['REMOTE_ADDR'] = $forwarded_for;
    }
}

if (isset($_SERVER['HTTP_X_FORWARDED_PROTO'])) {
    if ($_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') {
        $_SERVER['HTTPS'] = true;
    }
}
